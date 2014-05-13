#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "fileutils"

require "rubygems"
#gem "comana"
#require "comana/computationmanager.rb"
#require "comana/computationmanager.rb"

#require "vasputils.rb"
#require "vasputils/vaspdir.rb"

#
#The directory must has subdirs whose name is started by 'geomopt'.
#This restriction of naming is necessary to distinguish from simple aggregation
#of vasp directories.
#
class VaspUtils::VaspGeometryOptimizer < Comana::ComputationManager
    class NoVaspDirError < Exception; end
    class LatestDirStartedError < Exception; end
    class NoIntegerEndedNameError < Exception; end
    class NoContcarError < Exception; end

    PREFIX = "geomopt"

    def initialize(dir)
        super(dir)
        @lockdir        = "lock_vaspgeomopt"
        latest_dir # to check.
    end

    # Return incremented name.
    # If the name of VaspDir ends with string of integer,
    # return incremental value with the basename.
    # If not ended with integer, this method assume "00"
    def self.next_name(name)
        basename = name.sub(/(\d*)$/, "")
        new_num = $1.to_i + 1
        return basename + sprintf("%02d", new_num)
    end

    # 注目した VaspDir が yet なら実行し、続ける。
    # yet 以外なら例外。
    # VaspDir になっているか。
    def calculate
        $stdout.puts "Calculate #{latest_dir.dir}"
        $stdout.flush

        latest_dir.start
        #dir = latest_dir
        #while (! finished?)
        #    raise LatestDirStartedError if dir.state == :started
        #    dir.start
        #    if dir.finished?
        #        break
        #    else
        #        #dir = prepare_next
        #        puts "Geometry optimization fihished. Exit."
        #    end
        #end
        #puts "Geometry optimization fihished. Exit."
        #sleep 1 # for interrupt
    end

    # latest_dir から返って来る最新の VaspDir が finished? で真を返し、
    # かつ Iteration が 1 であるか。
    # Note: even when the geometry optimization does not include lattice shape,
    #       calculate will continued till to converge to Iter 1 calculation.
    def finished?
        return false unless latest_dir.finished?
        return false unless latest_dir.outcar[:ionic_steps] == 1
        return true
    end

    # Find latest VaspDir.
    # Return a last VaspDir which has the name by name sort
    # and which can be made as a VaspDir instance.
    # Note: in a series of geometry optimization,
    #       the directory names should have a rule of naming
    #       which can define a method <=>.
    #       Usually, it is simple sort of String.
    def latest_dir
        Dir.glob("#{@dir}/#{PREFIX}*").sort.reverse.find do |dir|
            begin
                vd = VaspUtils::VaspDir.new(dir)
                return vd
            rescue VaspUtils::VaspDir::InitializeError
                next
            end
        end
        raise NoVaspDirError, @dir
    end

    #Keep 'geomopt00/{POSCAR,POTCAR,INCAR,POTCAR}', remove others.
    def reset_init
        poscars = Dir.glob("#{@dir}/#{PREFIX}*/POSCAR").sort
        poscar = nil
        path = nil
        poscars.each do |poscar|
            begin
                VaspUtils::Poscar.load_file poscar
                path = File.dirname(poscar)
                break
            rescue VaspUtils::Poscar::ParseError
                next
            end
        end
        raise NoVaspDirError unless path

        ##geomopt*
        rm_list = Dir.glob "#{@dir}/#{PREFIX}*"
        rm_list.delete path
        ##input files
        rm_list << Dir.glob("#{path}/*")
        rm_list.flatten!
        ["KPOINTS", "INCAR", "POTCAR", "POSCAR"].each do |file|
            rm_list.delete "#{path}/#{file}"
        end
        ##queeue
        rm_list += Dir.glob "#{@dir}/lock*"
        rm_list += Dir.glob "#{@dir}/*.sh"
        rm_list += Dir.glob "#{@dir}/*.log"
        rm_list += Dir.glob "#{@dir}/*.o*"
        ##remove
        rm_list.each do |file|
            FileUtils.rm_rf file
        end
    end

    #Generate a new vaspdir as 'geomopt00'.
    #Other directories, including old 'geomopt00', are removed.
    def reset_next(io = $stdout)
        begin
            latest_dir.contcar
            prepare_next
            clean_queue_files
        rescue Errno::ENOENT
            latest_dir.reset_init(io)
            clean_queue_files
        rescue VaspUtils::Poscar::ParseError
            latest_dir.reset_init(io)
            clean_queue_files
        end
    end

    #Generate a new vaspdir as 'geomopt00'.
    #Other directories, including old 'geomopt00', are removed.
    def reset_reincarnate
        #CONTCAR を最後から解釈していく。
        #全てだめだったら POSCAR を解釈する。
        #全部だめだったら例外を投げる。

        #CONTCAR を解釈できたディレクトリで INCAR, KPOINTS, POTCAR を取得。
        #geomopt01 という名前でディレクトリを作る。
        contcars = Dir.glob("#{@dir}/#{PREFIX}*/CONTCAR").sort.reverse
        contcars += Dir.glob("#{@dir}/#{PREFIX}*/POSCAR").sort.reverse
        poscar = nil
        path = nil
        contcars.each do |contcar|
            begin
                VaspUtils::Poscar.load_file contcar
                poscar = contcar
                path = File.dirname(contcar)
                break
            rescue VaspUtils::Poscar::ParseError
                next
            end
        end
        raise NoVaspDirError unless poscar

        new_dir = "#{@dir}/new_#{PREFIX}00"
        Dir.mkdir new_dir
        FileUtils.mv("#{path}/KPOINTS", "#{new_dir}/KPOINTS")
        FileUtils.mv("#{path}/INCAR"    , "#{new_dir}/INCAR"    )
        FileUtils.mv("#{path}/POTCAR" , "#{new_dir}/POTCAR" )
        FileUtils.mv(poscar                     , "#{new_dir}/POSCAR")

        rm_list =    Dir.glob "#{@dir}/#{PREFIX}*"
        rm_list += Dir.glob "#{@dir}/lock*"
        rm_list += Dir.glob "#{@dir}/*.sh"
        rm_list += Dir.glob "#{@dir}/*.log"
        rm_list += Dir.glob "#{@dir}/*.o*"
        rm_list.each do |file|
            FileUtils.rm_rf file
        end

        FileUtils.mv new_dir, "#{@dir}/#{PREFIX}00"
    end

    private

    # Generate next directory from latest_dir.
    # Need proper CONTCAR. If not, raise NoContcarError.
    def prepare_next
        raise NoContcarError unless File.exist? "#{latest_dir.dir}/CONTCAR"

        new_dir = self.class.next_name(latest_dir.dir)
        Dir.mkdir new_dir

        #FileUtils.cp("#{latest_dir.dir}/CHG"           , "#{new_dir}/CHG"       )
        #FileUtils.cp("#{latest_dir.dir}/CHGCAR"    , "#{new_dir}/CHGCAR"    )
        #FileUtils.cp("#{latest_dir.dir}/DOSCAR"    , "#{new_dir}/DOSCAR"    )
        #FileUtils.cp("#{latest_dir.dir}/EIGENVAL", "#{new_dir}/EIGENVAL")
        #FileUtils.cp("#{latest_dir.dir}/INCAR"     , "#{new_dir}/INCAR"     )
        #FileUtils.cp("#{latest_dir.dir}/KPOINTS" , "#{new_dir}/KPOINTS" )
        #FileUtils.cp("#{latest_dir.dir}/OSZICAR" , "#{new_dir}/OSZICAR" )
        #FileUtils.cp("#{latest_dir.dir}/PCDAT"     , "#{new_dir}/PCDAT"     )
        #FileUtils.cp("#{latest_dir.dir}/POTCAR"    , "#{new_dir}/POTCAR"    )
        #FileUtils.cp("#{latest_dir.dir}/WAVECAR" , "#{new_dir}/WAVECAR" )
        #FileUtils.cp("#{latest_dir.dir}/XDATCAR" , "#{new_dir}/XDATCAR" )

        possible_files = ["CHG", "CHGCAR", "DOSCAR", "EIGENVAL", 
            "OSZICAR", "PCDAT", "WAVECAR", "XDATCAR"]
        possible_files.each do |file|
            if File.exist? "#{latest_dir.dir}/#{file}"
                FileUtils.cp("#{latest_dir.dir}/#{file}", "#{new_dir}/#{file}")
            end
        end

        necessary_files = ["INCAR", "KPOINTS", "POTCAR"]
        necessary_files.each do |file|
            FileUtils.cp("#{latest_dir.dir}/#{file}", "#{new_dir}/#{file}")
        end

        FileUtils.cp("#{latest_dir.dir}/CONTCAR" , "#{new_dir}/POSCAR"  ) # change name
        # without POSCAR, OUTCAR, vasprun.xml
        VaspUtils::VaspDir.new(new_dir)
    end

    def clean_queue_files
        rm_list = []
        rm_list += Dir.glob "#{@dir}/lock*"
        rm_list += Dir.glob "#{@dir}/*.sh"
        rm_list += Dir.glob "#{@dir}/*.log"
        rm_list += Dir.glob "#{@dir}/*.o*"
        rm_list.each do |file|
            FileUtils.rm_rf file
        end
    end

end

