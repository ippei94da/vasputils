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
    INITIAL_DIFF = 1E-2

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
        new_strain = [
            [1.0, 0.0, 0.0],
            [0.0, 1.0, 0.0],
            [0.0, 0.0, 1.0],
        ]

        3.times do |i|
            3.times do |j|
                if calcdirs.size == 1 # 点数が1つ。±1% で歪みテンソルを作る
                    component = calcdirs[0].vasprun_xml.stress[i][j]
                    if component > 0
                        diff = INITIAL_DIFF
                    elsif component < 0
                        diff = - INITIAL_DIFF
                    else
                        diff = 0.0
                    end
                else # 点数2以上、最新2つで線形で近似解を取り、歪みテンソルを作る。
                    a, b = line_through_two_points(
                        [strain1[i][j], stress1[i][j]],
                        [strain2[i][j], stress2[i][j]]
                    )
                    diff = 1.0/a
                end
                new_strain[i][j] += diff
            end
        end

        #つぎのディレクトリを作る
        #POTCAR, INCAR, KPOINTS は cellopt00 のをコピー。
        new_dir = next_name(calcdirs[-1].name)
        Dir.mkdir new_dir
        ['INCAR', 'KPOINTS', 'POTCAR'].each do |file|
            FileUtils.cp("#{calcdirs[0].path}/#{file}",
                         "#{new_dir}/#{file}")
        end

        poscar00 = calcdirs[0].poscar
        axes = poscar00.axes
        new_axes = Mageo::Tensor
        HERE

        cellopt00 の POSCAR を取得し、new_strain で変形させた軸で POSCAR を作る。



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

    private

    #point1, point2 is like [0.0, 1.0], [2.0, 3.0]
    # return [a,b] of 'ax + by = 1'
    def line_through_two_points(point1, point2)
        x1 = point1[0]
        y1 = point1[1]
        x2 = point2[0]
        y2 = point2[1]

        matrix = [
            [(x1 + x2), (y1 + y2)],
            [(x1 - x2), (y1 - y2)],
        ]
        values = [2.0, 0.0]

        Malge::SimultaneousEquation.solve(matrix, values)
    end

end

