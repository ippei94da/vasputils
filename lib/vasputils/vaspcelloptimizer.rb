#! /usr/bin/env ruby
# coding: utf-8

require "malge"
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
        latest_dir # to check.
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

    # return distorted axes
    def self.distort_axes(strain, axes)
        mat = Matrix[*strain]
        result = axes.map do |ary|
            mat * Vector[*ary]
        end
    end

    #point1, point2 is like [0.0, 1.0], [2.0, 3.0]
    # return [a,b] of 'ax + by = 1'
    def self.line_through_two_points(point1, point2)
        #pp point1, point2
        x1 = point1[0]
        y1 = point1[1]
        x2 = point2[0]
        y2 = point2[1]

        matrix = [
            [(x1 + x2), (y1 + y2)],
            [(x1 - x2), (y1 - y2)],
        ]
        #pp matrix
        values = [2.0, 0.0]

        Malge::SimultaneousEquations.cramer(matrix, values)
    end


    # 注目した VaspDir が yet なら実行し、続ける。
    # yet 以外なら例外。
    # VaspDir になっているか。
    def calculate
        $stdout.puts "Calculate #{latest_dir.dir}"
        $stdout.flush

        #最初の計算ディレクトリだけならば strain.yaml を生成する。
        if calcdirs.size == 1
            File.open("#{calcdirs[0].dir}/#{STRAIN_YAML}", "w") do |io|
                YAML.dump( [ [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0] ], io)
            end
        end

        latest_dir.start
    end

    # vasprun.xml から 最後の応力テンソルを持ってきて、
    # 成分の最大値が閾値以下なら収束。
    def finished?
        max_component = calcdirs[-1].vasprun_xml.stress.flatten.map {|i| i.abs}.max
        return true if max_component < THRESHOLD
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
                        new_strain[i][j] += INITIAL_DIFF
                    elsif component < 0
                        new_strain[i][j] -= INITIAL_DIFF
                    else
                        #new_strain[i][j] += 0.0
                    end
                else # 点数2以上、最新2つで線形で近似解を取り、歪みテンソルを作る。
                    strain1 = YAML.load_file("#{calcdirs[-1].dir}/#{STRAIN_YAML}")
                    strain2 = YAML.load_file("#{calcdirs[-2].dir}/#{STRAIN_YAML}")
                    stress1 = calcdirs[-1].vasprun_xml.stress
                    stress2 = calcdirs[-2].vasprun_xml.stress

                    begin
                        a, b = self.class.line_through_two_points(
                            [strain1[i][j], stress1[i][j]],
                            [strain2[i][j], stress2[i][j]]
                        )
                        new_strain[i][j] = 1.0/a
                    rescue Malge::SimultaneousEquations::NotRegularError
                        new_strain[i][j] = 0.0
                    end
                end
            end
        end

        #つぎのディレクトリを作る
        #POTCAR, INCAR, KPOINTS は cellopt00 のをコピー。
        new_dir = self.class.next_name(calcdirs[-1].dir)
        Dir.mkdir new_dir
        ['INCAR', 'KPOINTS', 'POTCAR'].each do |file|
            FileUtils.cp("#{calcdirs[0].dir}/#{file}",
                         "#{new_dir}/#{file}")
        end

        #cellopt00 の POSCAR を取得し、new_strain で変形させた軸で POSCAR を作る。
        poscar00 = calcdirs[0].poscar
        axes = poscar00.axes
        new_axes = self.class.distort_axes(new_strain, axes)
        poscar00 = VaspUtils::Poscar.load_file("#{calcdirs[0].dir}/POSCAR")
        poscar00.axes = new_axes
        File.open("#{new_dir}/POSCAR", 'w') do |io|
            poscar00.dump(io)
        end

        #pp new_strain
        #strain.yaml を記録
        File.open("#{new_dir}/#{STRAIN_YAML}", 'w') do |io|
            YAML.dump(new_strain, io)
        end
    end

    # ディレクトリリストを返す。
    # latest はコール側で最後のものを取得すれば良い。
    def calcdirs
        dirs = []
        Dir.glob("#{@dir}/#{PREFIX}*").sort.each do |dir|
            begin
                dirs << VaspUtils::VaspDir.new(dir)
            rescue VaspUtils::VaspDir::InitializeError
                next
            end
        end
        dirs
    end

    def latest_dir
        calcdirs[-1]
    end

    private

end

