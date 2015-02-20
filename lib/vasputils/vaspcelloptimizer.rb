#! /usr/bin/env ruby
# coding: utf-8

#require "pp"
#require "fileutils"
#
#
#
class VaspUtils::VaspCellOptimizer < Comana::ComputationManager
    class NoVaspDirError < Exception; end
    class InitializeError < Exception; end

    PREFIX = "cellopt"
    STRAIN_YAML = "strain.yaml"
    THRESHOLD = 1E-1

    #
    def initialize(dir)
        super(dir)
        @lockdir        = "lock_vaspcellopt"
        begin
            latest_dir # to check.
        rescue NoVaspDirError
            raise InitializeError
        end
    end

    # Return incremented name.
    # If the name of VaspDir ends with string of integer,
    # return incremental value with the basename.
    # If not ended with integer, this method assume "00"
    def self.next_name(name)
        name =~ /^(.*#{PREFIX})(\d+)/
        return sprintf("%s%02d", $1, $2.to_i + 1)
    end

    # 注目した VaspDir が yet なら実行し、続ける。
    # yet 以外なら例外。
    # VaspDir になっているか。
    def calculate
        $stdout.puts "Calculate #{latest_dir.dir}"
        $stdout.flush

        #最初の計算ディレクトリだけならば strain.yaml を生成する。
        if calcdirs.size == 1
            File.open("#{calcdirs[0]}/#{STRAIN_YAML}", "w") do |io|
                YAML.dump( [ [1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0, 1.0, 1.0] ], io)
            end
        end

        latest_dir.start
    end

    # vasprun.xml から 最後の応力テンソルを持ってきて、
    # 成分の最大値が閾値以下なら収束。
    def finished?
        return true if calcdirs[-1].vasprun_xml.stress.flatten.max < THRESHOLD
        return false
    end

    def prepare_next
        TODO

        点数が1つなら、±1% で歪みテンソルを作る

        点数2以上なら、最新2つで線形で近似解を取り、
        歪みテンソルを作る。

        歪みテンソルで変形したディレクトリを作る。



        #raise NoContcarError unless File.exist? "#{latest_dir.dir}/CONTCAR"

        #new_dir = self.class.next_name(latest_dir.dir)
        #Dir.mkdir new_dir

        #possible_files = ["CHG", "CHGCAR", "DOSCAR", "EIGENVAL", 
        #    "OSZICAR", "PCDAT", "WAVECAR", "XDATCAR"]
        #possible_files.each do |file|
        #    if File.exist? "#{latest_dir.dir}/#{file}"
        #        FileUtils.cp("#{latest_dir.dir}/#{file}", "#{new_dir}/#{file}")
        #    end
        #end

        #necessary_files = ["INCAR", "KPOINTS", "POTCAR"]
        #necessary_files.each do |file|
        #    FileUtils.cp("#{latest_dir.dir}/#{file}", "#{new_dir}/#{file}")
        #end

        #FileUtils.cp("#{latest_dir.dir}/CONTCAR" , "#{new_dir}/POSCAR"  ) # change name
        ## without POSCAR, OUTCAR, vasprun.xml
        #VaspUtils::VaspDir.new(new_dir)
    end

    # ディレクトリリストを返すようにする。
    # latest はコール側で最後のものを取得すれば良い。
    #旧 latest_dir
    def calcdirs
        dirs = []
        Dir.glob("#{@dir}/#{PREFIX}*").sort.each do |dir|
            begin
                dirs << VaspUtils::VaspDir.new(dir)
            rescue VaspUtils::VaspDir::InitializeError
                next
            end
        end
        raise NoVaspDirError, @dir
        dirs
    end

    #private

end

