#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "pp"
require "date"
require "yaml"

require "rubygems"
gem "comana"
require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

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
class VaspDir < ComputationManager
  class InitializeError < Exception; end
  class NoVaspBinaryError < Exception; end

  #INCAR 解析とかして、モードを調べる。
  #- 格子定数の構造最適化モード(ISIF = 3)
  #- 格子定数を固定した構造最適化モード(ISIF = 2)
  ##- k 点探索モードは無理だろう。
  def initialize(dir)
    super(dir)
    @lockdir    = "lock_vaspdir"
    %w(INCAR KPOINTS POSCAR POTCAR).each do |file|
      infile = "#{@dir}/#{file}"
      raise InitializeError, infile unless FileTest.exist? infile
    end
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

  # 正常に終了していれば true を返す。
  # 実行する前や実行中、OUTCAR が完遂していなければ false。
  #
  # MEMO
  # PI12345 ファイルは実行中のみ存在し、終了後 vasp (mpi？) に自動的に削除される。
  def finished?
    begin
      return Outcar.load_file("#{@dir}/OUTCAR")[:normal_ended]
    rescue Errno::ENOENT
      return false
    end
  end

  private

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
    begin
      info =
        MachineInfo.load_file("#{ENV["HOME"]}/.machineinfo").get_info(ENV["HOST"])
      vasp = info["vasp"]
    rescue
      #vasp = "vasp"
      raise NoVaspBinaryError, "No vasp path in #{ENV["HOME"]}/.machineinfo"
    end
    command = "cd #{@dir};"
    command += vasp
    command += "> stdout"

    system command
  end

  def prepare_next
    #do_nothing
  end

end

#class VaspGeometryOptimization < ComputationManager
#  # 次の計算ディレクトリを作成し、
#  # その VaspDir クラスで self を置き換える。
#  # 計算が正常終了していなければ、例外 VaspDirNotEndedError を生じる。
#  # 次の計算ディレクトリが既に存在していれば例外 Errno::EEXIST が投げられる。
#  def next
#    raise NotEndedError unless normal_ended?
#    raise ConvergedError unless to_be_continued?
#    #postfix = /try(\d+)$/
#    POSTFIX =~ @dir
#    try_num = $1.to_i
#    next_dir = @dir.sub(POSTFIX, sprintf("try%02d", try_num + 1))
#    Dir.mkdir next_dir
#    FileUtils.cp( "#{@dir}/INCAR"  , "#{next_dir}/INCAR")
#    FileUtils.cp( "#{@dir}/KPOINTS", "#{next_dir}/KPOINTS")
#    FileUtils.cp( "#{@dir}/POTCAR" , "#{next_dir}/POTCAR")
#    FileUtils.cp( "#{@dir}/CONTCAR", "#{next_dir}/POSCAR")
#    initialize(next_dir)
#  end
#
#  # Return number of electronic steps.
#  def internal_steps
#    return outcar[:electronic_steps] if outcar
#    return 0
#  end
#
#  # Return number of ionic steps.
#  def external_steps
#    return outcar[:ionic_steps] if outcar
#    return 0
#  end
#
#  # Return elapsed time.
#  def elapsed_time
#    return outcar[:elapsed_time] if outcar
#    return 0.0
#  end
#
#  # normal_ended? が false なら false。
#  # normal_ended? が true のうち、
#  # 結果を使って次に計算すべきなら true を、そうでなければ false を返す。
#  #
#  # 計算すべき、の条件はモードによって異なる。
#  #   NSW = 0 もしくは NSW = 1 のとき、必ず false。
#  #   - :single_point     モードならば、常に false。
#  #   - :geom_opt_lattice モードならば、ionic step が 2 以上なら true。
#  #   - :geom_opt_atoms   モードならば、ionic step が NSW と同じなら true。
#  #
#  def to_be_continued?
#    begin
#      outcar = Outcar.load_file("#{@dir}/OUTCAR")
#    rescue Errno::ENOENT
#      return false
#    end
#    ionic_steps = outcar[:ionic_steps]
#    return false unless outcar[:normal_ended]
#    return false if @incar["NSW"].to_i <= 1
#    if @mode == :geom_opt_lattice
#      return ionic_steps != 1
#    elsif @mode == :geom_opt_atoms
#      return ionic_steps == @incar["NSW"].to_i
#    else
#      return false
#    end
#  end
#
