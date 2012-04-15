#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "pp"
require "date"

require "vasputils/incar.rb"
require "vasputils/outcar.rb"
require "vasputils/poscar.rb"
require "vasputils/kpoints.rb"


# vasp 実行ディレクトリ(入力・出力ファイルを含む)を扱うクラス
#
# MEMO
# interrupted? みたいなメソッドは作れない。
# 実行が開始したあと、その計算の状態が中断されているのか、
# 単に実行中でファイルが書き込まれている途中なのか、
# プログラムを実行しているプロセス自身以外は、外部からは判別がつかない。
#
# ルール
# try00 形式の postfix がついていることを前提とする。
# 00 の部分には CONTCAR を POSCAR にする手続きで連続して行う計算の番号を示す。
#
class VaspDir

	class InitializeError < Exception; end
	class ConvergedError < Exception; end
	class NotEndedError < Exception; end
	class LockedError < Exception; end
	class PostfixMismatchError < Exception; end


	LOCK_FILE = "lock"
	POSTFIX = /try(\d+)$/

	YET         = 0# - 未計算。
	STARTED     = 1# - 開始した。
	INTERRUPTED = 2# - 中断された。
	CONTINUED   = 3# - 終了し、次の計算を生成した。
	COMPLETED   = 4# - 終了し、収束した。

	attr_reader :mode
	#attr_reader :dir

	#INCAR 解析とかして、モードを調べる。
	#- 格子定数の構造最適化モード(ISIF = 3)
	#- 格子定数を固定した構造最適化モード(ISIF = 2)
	##- k 点探索モードは無理だろう。
	def initialize(dir_name)
		@dir = dir_name

		%w(INCAR KPOINTS POSCAR POTCAR).each do |file|
			infile = "#{@dir}/#{file}"
			raise InitializeError, infile unless FileTest.exist? infile
		end

		@incar = Incar.load_file("#{@dir}/INCAR")
		case @incar["IBRION"]
		when "-1"
			@mode = :single_point
		#when "1"
		#	@mode = :molecular_dynamics
		when "2"
			if (@incar["ISIF"] == "2")
				@mode = :geom_opt_atoms
			elsif (@incar["ISIF"] == "3")
				@mode = :geom_opt_lattice
			else
				@mode = :geom_opt
			end
		else
				@mode = nil
		end
	end

	# ディレクトリ名を返す。
	def name
		@dir
	end

	# 計算が過去に始まっていれば true を返す。
	# 終わっているかは判定しない。
	# 具体的には lock ファイルが存在すれば true を返す。
	#
	# MEMO
	# (mpi 経由で？)vasp を実行すると PI12345 とかいうファイルができるが、
	# これはたぶん起動してから若干のタイムラグが生じる。
	# このタイムラグ中に別のプロセスが同時に計算したらマズい。
	def started?
		return File.exist? lock_file
	end

	# 正常に終了していれば true を返す。
	# 実行する前や実行中、OUTCAR が完遂していなければ false。
	#
	# MEMO
	# PI12345 ファイルは実行中のみ存在し、終了後 vasp (mpi？) に自動的に削除される。
	def normal_ended?
		begin
			return Outcar.load_file("#{@dir}/OUTCAR")[:normal_ended]
		rescue Errno::ENOENT
			return false
		end
	end

	# normal_ended? が false なら false。
	# normal_ended? が true のうち、
	# 結果を使って次に計算すべきなら true を、そうでなければ false を返す。
	#
	# 計算すべき、の条件はモードによって異なる。
	#   NSW = 0 もしくは NSW = 1 のとき、必ず false。
	#   - :single_point     モードならば、常に false。
	#   - :geom_opt_lattice モードならば、ionic step が 2 以上なら true。
	#   - :geom_opt_atoms   モードならば、ionic step が NSW と同じなら true。
	#
	def to_be_continued?
		begin
			outcar = Outcar.load_file("#{@dir}/OUTCAR")
		rescue Errno::ENOENT
			return false
		end
		ionic_steps = outcar[:ionic_steps]
		return false unless outcar[:normal_ended]
		return false if @incar["NSW"].to_i <= 1
		if @mode == :geom_opt_lattice
			return ionic_steps != 1
		elsif @mode == :geom_opt_atoms
			return ionic_steps == @incar["NSW"].to_i
		else
			return false
		end
	end

	# vasp を投げる。
	# 計算実行時に lock を生成する。
	# もし既に lock が存在していれば、例外 VaspDirLockedError を
	# 投げる。
	# lock は作られっぱなしで、プログラムからは削除されない。
	# 通常、一度計算したらもう二度と計算しないし。
	#
	# MEMO
	# mpirun で投げる場合は
	# machinefile を生成しないとどのホストで計算するか、安定しない。
	# そのうち mpiexec from torque に対応するが、
	# まずは mpirun で動くように作る。
	def calculate
		raise LockedError if started?

		File.open(lock_file, "w") do |lock_io|
			lock_io.puts "HOST: #{ENV["HOST"]}"
			lock_io.puts "START: #{Time.now.to_s}"
			lock_io.flush

			num_cores = 4 if /^Se\d\d/ =~ ENV["HOST"]
			num_cores = 4 if /^Ge\d\d/ =~ ENV["HOST"]
			num_cores = 4 if /^Ga\d\d/ =~ ENV["HOST"]
			num_cores = 4 if /^At$/ =~ ENV["HOST"]
			num_cores = 2 if /^yggdrasil$/ =~ ENV["HOST"]

			# machines を生成
			File.open("#{@dir}/machines", "w") do |io|
				io.puts "localhost:#{num_cores}"
			end

			command = "cd #{@dir};" +
				"/usr/local/calc/mpich-1.2.7-ifc7/bin/mpirun " +
				"-np #{num_cores} " +
				"-machinefile machines " +
				"/usr/local/calc/vasp/vasp4631mpi" +
				"> stdout"

			if $TEST
				generated_files = [
					"CHG",
					"CHGCAR",
					"CONTCAR",
					"DOSCAR",
					"EIGENVAL",
					"IBZKPT",
					"OSZICAR",
					"OUTCAR",
					"PCDAT",
					"WAVECAR",
					"XDATCAR",
					"machines",
					"vasprun.xml",
					"lock",
				]
				generated_files.map!{|i| "#{@dir}/#{i}"}
				command = "touch #{generated_files.join(" ")}"
			end

			status = system command
			if status
				lock_io.puts "STATUS: normal ended."
			else
				lock_io.puts "STATUS: irregular ended, status #{$?}."
			end
		end
	end

	# 次の計算ディレクトリを作成し、
	# その VaspDir クラスで self を置き換える。
	# 計算が正常終了していなければ、例外 VaspDirNotEndedError を生じる。
	# 次の計算ディレクトリが既に存在していれば例外 Errno::EEXIST が投げられる。
	def next
		raise NotEndedError unless normal_ended?
		raise ConvergedError unless to_be_continued?
		#postfix = /try(\d+)$/
		POSTFIX =~ @dir
		try_num = $1.to_i
		next_dir = @dir.sub(POSTFIX, sprintf("try%02d", try_num + 1))
		Dir.mkdir next_dir
		FileUtils.cp( "#{@dir}/INCAR"  , "#{next_dir}/INCAR")
		FileUtils.cp( "#{@dir}/KPOINTS", "#{next_dir}/KPOINTS")
		FileUtils.cp( "#{@dir}/POTCAR" , "#{next_dir}/POTCAR")
		FileUtils.cp( "#{@dir}/CONTCAR", "#{next_dir}/POSCAR")
		initialize(next_dir)
	end

	# Postprocess.
	def teardown
		# Do nothing.
	end

	# Return number of electronic steps.
	def internal_steps
		return outcar[:electronic_steps] if outcar
		return 0
	end

	# Return number of ionic steps.
	def external_steps
		return outcar[:ionic_steps] if outcar
		return 0
	end

	# Return elapsed time.
	def elapsed_time
		return outcar[:elapsed_time] if outcar
		return 0.0
	end

	# 配下の OUTCAR を Outcar インスタンスにして返す。
	# 存在しなければ例外 Errno::ENOENT を返す。
	def outcar
		Outcar.load_file("#{@dir}/OUTCAR")
	end

	# 配下の CONTCAR を Cell2 インスタンスにして返す。
	# 存在しなければ例外 Errno::ENOENT を返す。
	def contcar
		Poscar.load_file("#{@dir}/CONTCAR")
	end

	# 配下の KPOINTS を読み込んだ結果をハッシュにして返す。
	#
	# 存在しなければ例外 Errno::ENOENT を返す筈だが、
	# vasp dir の判定を incar でやっているので置こる筈がない。
	def incar
		Incar.load_file("#{@dir}/INCAR")
	end

	# 配下の KPOINTS を読み込んだ結果をハッシュにして返す。
	def kpoints
		Kpoints.load_file("#{@dir}/KPOINTS")
	end

	private

	# Return lock file name.
	def lock_file
		return "#{@dir}/#{LOCK_FILE}"
	end

end

