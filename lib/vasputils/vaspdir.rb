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

  class InitializeError < Exception; end
  class NoVaspBinaryError < Exception; end
  class PrepareNextError < Exception; end
  class ExecuteError < Exception; end
  class InvalidValueError < Exception; end

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

  # 配下の KPOINTS を読み込んだ結果をハッシュにして返す。
  #
  # 存在しなければ例外 Errno::ENOENT を返す筈だが、
  # vasp dir の判定を incar でやっているので置こる筈がない。
  def incar
    VaspUtils::Incar.load_file("#{@dir}/INCAR")
  end

  # 配下の KPOINTS を読み込んだ結果をハッシュにして返す。
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

  def reset_init(io = $stdout)
    #fullpath = File.expand_path @dir
    keep_files   = ["INCAR", "KPOINTS", "POSCAR", "POTCAR"]
    remove_files = []
    Dir.entries( @dir ).sort.each do |file|
      next if file == "."
      next if file == ".."
      remove_files << file unless keep_files.include? file
    end

    if remove_files.size == 0
      io.puts "  No remove files."
      return
    else
      #pp @dir; exit
      #puts "  Remove files:"
      #remove_files.each { |file| puts "    #{file}" }

      #puts "  Keep files:"
      #keep_files.each { |file| puts "    #{file}" }

      remove_files.each do |file|
        io.puts "  Removing: #{file}"
        FileUtils.rm_rf "#{@dir}/#{file}"
      end
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
