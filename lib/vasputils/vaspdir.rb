#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "pp"
require "date"
require "yaml"

#require "rubygems"
#require "comana"

# Class for VASP executable directory,
# including input and output files.
#
class VaspUtils::VaspDir < Comana::ComputationManager
    MACHINEFILE = "machines"
    INSPECT_DEFAULT_ITEMS = [ :klass_name, :state, :toten, :dir, ]
    #INSPECT_ALL_ITEMS = [ :ka, :kb, :kc, :encut, :i_step, :e_step, :time, ] + INSPECT_DEFAULT_ITEMS
    INSPECT_ALL_ITEMS = [ :kpoints, :encut, :i_step, :e_step, :time, ] + INSPECT_DEFAULT_ITEMS

    # for printf option. minus value indicate left shifted printing.
    INSPECT_WIDTH = {
        :dir         => "-20",
        :e_step      => "3",
        :i_step      => "3",
        :klass_name  => "11",
        :kpoints     => "8",
        #:ka          => "2",
        #:kb          => "2",
        #:kc          => "2",
        :encut       => "6",
        :state       => "10",
        :time        => "15",
        :toten       => "17",
    }


    class InitializeError < Exception; end
    class NoVaspBinaryError < Exception; end
    class PrepareNextError < Exception; end
    class ExecuteError < Exception; end
    class InvalidValueError < Exception; end
    class AlreadyExistError < Exception; end

    def initialize(dir)
        super(dir)
        @lockdir        = "lock_run"
        %w(INCAR KPOINTS POSCAR POTCAR).each do |file|
            infile = "#{@dir}/#{file}"
            raise InitializeError, infile unless FileTest.exist? infile
        end
    end

    #
    def self.run(args)
        tgts = args
        tgts = [ENV['PWD']] if tgts.size == 0

        tgts.each do |dir|
            begin
                calc_dir = VaspUtils::VaspDir.new(dir)
                calc_dir.start
            rescue VaspUtils::VaspDir::InitializeError
                puts "Not VaspDir: #{dir}"
                exit
            rescue Comana::ComputationManager::AlreadyStartedError
                puts "Already started. Exit."
                exit
            end
        end
    end

    def self.reset_clean(args)
        targets = args
        targets = [ENV['PWD']] if targets.size == 0
        targets.each do |target_dir|
            puts "Directory: #{target_dir}"

            # Check target_dir is VaspDir?
            begin
                vd = VaspUtils::VaspDir.new(target_dir)
            rescue VaspUtils::VaspDir::InitializeError
                puts "  Do nothing due to not VaspDir."
                next
            end
            vd.reset_clean
        end
    end

    def self.reset_initialize(args)
        targets = args
        targets = [ENV['PWD']] if targets.size == 0
        targets.each do |target_dir|
            puts "Directory: #{target_dir}"

            # Check target_dir is VaspDir?
            begin
                vd = VaspUtils::VaspDir.new(target_dir)
            rescue VaspUtils::VaspDir::InitializeError
                puts "  Do nothing due to not VaspDir."
                next
            end
            vd.reset_initialize
        end
    end

    def self.show_inspect(args)
        ## option analysis
        show_items = []
        show_dir_states = []
        options = {}

        op = OptionParser.new
        options[:show_dir] = []
        op.on("-f", "--finished"  , "Show finished dir."   ){show_dir_states << :finished}
        op.on("-y", "--yet"       , "Show yet dir."        ){show_dir_states << :yet}
        op.on("-t", "--terminated", "Show terminated dir." ){show_dir_states << :terminated}
        op.on("-s", "--started"   , "Show sarted dir."     ){show_dir_states << :started}
        op.on("-l", "--dirs-with-matches", "Show dir name only."){options[:dirnameonly  ] = true}

        op.on("-a", "--all-items"   , "Show all items."         ){options[:all_items] = true}
        op.on("-S", "--state"       , "Show STATE."             ){options[:show_items] << :state    }
        op.on("-e", "--toten"       , "Show TOTEN."             ){options[:show_items] << :toten    }
        op.on("-i", "--ionic-steps" , "Show ionic steps as I_S."){options[:show_items] << :ionic_steps}
        op.on("-L", "--last-update" , "Show LAST-UPDATE."       ){options[:show_items] << :last_update}
        op.on("-k", "--kpoints" , "Show KPOINTS."               ){
            options[:show_items] << :kpoints
            #options[:show_items] << :ka
            #options[:show_items] << :kb
            #options[:show_items] << :kc
        }
        op.on("-c", "--encut" , "Show ENCUT."                   ){options[:show_items] << :encut    }
        op.parse!(args)

        dirs = args
        #dirs = Dir.glob("*").sort if args.empty?
        dirs = ["."] if args.empty?

        if options[:all_items]
            options[:show_items] = INSPECT_ALL_ITEMS
        elsif options[:dirnameonly]
            options[:show_items] = [:dir]
        elsif options[:show_items] == nil || options[:show_items].empty?
            options[:show_items] = INSPECT_DEFAULT_ITEMS
        else 
            options[:show_items] = options[:show_items].push :dir
        end

        unless options[:dirnameonly]
            # show title of items.
            results = {
                :klass_name => "TYPE",
                :kpoints    => "KPOINTS",
                #:ka         => "KA",
                #:kb         => "KB",
                #:kc         => "KC",
                :encut      => "ENCUT",
                :state      => "STATE",
                :toten      => "TOTEN",
                :i_step     => "I_S", #I_S is ionic steps      
                :e_step     => "E_S", #E_S is electronic steps 
                :time       => "LAST_UPDATE_AGO",
                :dir        => "DIR"
            }
            self.show_items(results, options)
        end

        dirs.each do |dir|
            next unless File.directory? dir
            begin
                klass_name = "VaspDir"
                calc = VaspUtils::VaspDir.new(dir)
                #pp calc.kpoints
                state = calc.state
                begin
                    outcar = calc.outcar
                    toten  = sprintf("%9.6f", outcar[:totens][-1].to_f)
                    i_step = outcar[:ionic_steps]
                    e_step = outcar[:electronic_steps]
                    #time = calc.latest_modified_time.to_s
                    #time = calc.latest_modified_time.strftime("%Y%m%d-%H%M%S")
                    time = self.form_time(Time.now - calc.latest_modified_time)
                    kp = calc.kpoints

                    if kp.scheme == :automatic
                        k_str = kp.mesh.join("x")
                    else
                        k_str = kp.points.size.to_s
                    end


                    encut = calc.incar["ENCUT"]
                rescue
                    toten = i_step = e_step = time = k_str = encut = ""
                end

            rescue VaspUtils::VaspDir::InitializeError
                klass_name = "-------"
                #state = toten = i_step = e_step = "---"
            end
            results = {
                :klass_name => klass_name,
                #:ka         => ka,
                #:kb         => kb,
                #:kc         => kc,
                :kpoints    => k_str,
                :encut      => encut,
                :state      => state,
                :toten      => toten,
                :i_step     => i_step,
                :e_step     => e_step,
                :time       => time,
                :dir        => dir,
            }
            #pp results

            if show_dir_states.empty?
                self.show_items(results, options)
            else 
                if show_dir_states.include? results[:state]
                    self.show_items(results, options)
                end
            end
        end
    end

    def self.show_items(hash, options = {})
        items = options[:show_items].map do |item|
            val = sprintf("%#{INSPECT_WIDTH[item]}s", hash[item])
            val
        end
        separator = " "

        puts items.join(separator)
    end

    def self.form_time(second)
        second = second.to_i
        result = ""

        result = sprintf("%02d", second % 60)

        minute = second / 60
        if 0 < minute
            result = sprintf("%02d:#{result}", minute % 60)
        end

        hour = minute / 60
        if 0 < hour
            result = sprintf("%02d:#{result}", hour % 24)
        end

        day = hour / 24
        if 0 < day
            result = sprintf("%dd #{result}", day)
        end

        return result
    end



    # 配下の OUTCAR を Outcar インスタンスにして返す。
    # 存在しなければ例外 Errno::ENOENT を返す。
    def outcar
        VaspUtils::Outcar.load_file("#{@dir}/OUTCAR")
    end

    # 配下の POSCAR を CrystalCell::Cell インスタンスにして返す。
    # 存在しなければ例外 Errno::ENOENT を返す。
    def poscar
        VaspUtils::Poscar.load_file("#{@dir}/POSCAR")
    end

    # 配下の CONTCAR を CrystalCell::Cell インスタンスにして返す。
    # 存在しなければ例外 Errno::ENOENT を返す。
    def contcar
        VaspUtils::Poscar.load_file("#{@dir}/CONTCAR")
    end

    # 配下の INCAR を表現する Incar クラスインスタンスを返す。
    #
    # 存在しなければ例外 Errno::ENOENT を返す筈だが、
    # vasp dir の判定を incar でやっているので生じる筈がない。
    def incar
        VaspUtils::Incar.load_file("#{@dir}/INCAR")
    end

    # 配下の KPOINTS を表現する Kpoints クラスインスタンスを返す。
    def kpoints
        VaspUtils::Kpoints.load_file("#{@dir}/KPOINTS")
    end

    # 正常に終了していれば true を返す。
    # 実行する前や実行中、OUTCAR が完遂していなければ false。
    #
    # MEMO
    # PI12345 ファイルは実行中のみ存在し、終了後 vasp (mpi？) に自動的に削除される。
    def finished?
        begin
            return VaspUtils::Outcar.load_file("#{@dir}/OUTCAR")[:normal_ended]
        rescue Errno::ENOENT
            return false
        end
    end

    # VASP の出力ファイルを削除する。
    #入力のみに使うもの、残す
    #   INCAR KPOINTS POSCAR POTCAR
    #
    #主に出力。消す。
    #   CHG CHGCAR CONTCAR DOSCAR EIGENVAL EIGENVALUE ELFCAR
    #   EXHCAR IBZKPT LOCPOT OSZICAR OUTCAR PCDAT PRJCAR PROCAR
    #   PROOUT STOPCAR TMPCAR WAVECAR XDATCAR vasprun.xml
    #
    #付随する出力ファイル。残す。
    #   machines stderr stdout
    def reset_clean(io = $stdout)
        remove_files = %w(
            CHG CHGCAR CONTCAR DOSCAR EIGENVAL EIGENVALUE
            ELFCAR EXHCAR IBZKPT LOCPOT OSZICAR OUTCAR PCDAT
            PRJCAR PROCAR
            PROOUT STOPCAR TMPCAR WAVECAR XDATCAR vasprun.xml
        )
        remove_files.each do |file|
            io.puts "    Removing: #{file}"
            FileUtils.rm_rf "#{@dir}/#{file}"
        end
    end

    # Delete all except for four files, INCAR, KPOINTS, POSCAR, POTCAR.
    def reset_initialize(io = $stdout)
        #fullpath = File.expand_path @dir
        keep_files   = ["INCAR", "KPOINTS", "POSCAR", "POTCAR"]
        remove_files = []
        Dir.entries( @dir ).sort.each do |file|
            next if file == "."
            next if file == ".."
            remove_files << file unless keep_files.include? file
        end

        if remove_files.size == 0
            io.puts "    No remove files."
            return
        else
            remove_files.each do |file|
                io.puts "    Removing: #{file}"
                FileUtils.rm_rf "#{@dir}/#{file}"
            end
        end
    end

    # 'tgt_name' is a String.
    # 'conditions' is a Hash.
    #   E.g., {:encut => 500.0, :ka => 2, :kb => 4}
    def mutate(tgt_name, condition)
        raise AlreadyExistError, "Already exist: #{tgt_name}" if File.exist? tgt_name

        Dir.mkdir tgt_name

        ##POSCAR
        FileUtils.cp("#{@dir}/POSCAR", "#{tgt_name}/POSCAR")

        ##POTCAR
        FileUtils.cp("#{@dir}/POTCAR", "#{tgt_name}/POTCAR")

        ##INCAR
        new_incar = incar
        new_incar["ENCUT"] = condition[:encut] if condition[:encut]
        File.open("#{tgt_name}/INCAR", "w") do |io|
            VaspUtils::Incar.dump(new_incar, io)
        end

        ##KPOINTS
        new_kpoints = kpoints
        new_kpoints.mesh[0] = condition[:ka] if condition[:ka]
        new_kpoints.mesh[1] = condition[:kb] if condition[:kb]
        new_kpoints.mesh[2] = condition[:kc] if condition[:kc]
        if condition[:kab]
            new_kpoints.mesh[0] = condition[:kab]
            new_kpoints.mesh[1] = condition[:kab]
        end
        if condition[:kbc]
            new_kpoints.mesh[1] = condition[:kbc]
            new_kpoints.mesh[2] = condition[:kbc]
        end
        if condition[:kca]
            new_kpoints.mesh[2] = condition[:kca]
            new_kpoints.mesh[0] = condition[:kca]
        end
        if condition[:kabc]
            new_kpoints.mesh[0] = condition[:kabc]
            new_kpoints.mesh[1] = condition[:kabc]
            new_kpoints.mesh[2] = condition[:kabc]
        end
        File.open("#{tgt_name}/KPOINTS", "w") do |io|
            new_kpoints.dump(io)
        end
    end

    private

    # vasp を投げる。
    def calculate
        #HOSTNAME is for GridEngine
        hostname = (ENV["HOST"] || ENV["HOSTNAME"]).sub(/\..*$/, "") #ignore domain name

        begin
            clustersettings = Comana::ClusterSetting.load_file("#{ENV["HOME"]}/.clustersetting")
            info = clustersettings.settings_host(hostname)
        rescue
            puts "No vasp path in #{ENV["HOME"]}/.clustersetting"
            pp info
            raise NoVaspBinaryError
        end

        if ENV["SGE_EXECD_PIDFILE"] #grid engine 経由のとき
            nslots = ENV["NSLOTS"]
            lines = open(ENV["PE_HOSTFILE"], "r").readlines.collect do |line|
                line =~ /^(\S+)\s+(\S+)/
                "#{$1} cpu=#{$2}"
            end
            generate_machinefile(lines)
        else
            nslots = 1
            lines = ["localhost cpu=1"]
            generate_machinefile(lines)
        end

        raise InvalidValueError,
            "`clustersettings' is #{clustersettings.inspect}." unless clustersettings
        raise InvalidValueError, "`info' is #{info.inspect}." unless info
        raise InvalidValueError, "`info['mpi']' is #{info['mpi']}" unless info['mpi']
        raise InvalidValueError, "`info['vasp']' is #{info['vasp']}" unless info['vasp']
        raise InvalidValueError, "`MACHINEFILE' is #{MACHINEFILE}" unless MACHINEFILE
        raise InvalidValueError, "`nslots' is #{nslots}" unless nslots
        raise InvalidValueError, "`nslots' is #{nslots}" unless nslots

        #pp "#{info["mpi"]} -machinefile #{MACHINEFILE} -np #{nslots} #{info["vasp"]}"
        command = "cd #{@dir};"
        command += "#{info["mpi"]} -machinefile #{MACHINEFILE} -np #{nslots} #{info["vasp"]}"
        command += "> stdout"

        io = File.open("#{@dir}/runvasp.log", "w")
        io.puts command
        io.close

        end_status = system command
        raise ExecuteError, "end_status is #{end_status.inspect}" unless end_status
    end

    def prepare_next
        #do_nothing
        raise PrepareNextError, "VaspDir doesn't need next."
    end

    def generate_machinefile(lines)
        io = File.open("#{@dir}/#{MACHINEFILE}", "w")
        io.puts lines
        io.close
    end

end
