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

  #class InitializeError < Comana::ComputationManager::InitializeError; end
  class InitializeError < StandardError; end
  class NoVaspBinaryError < StandardError; end
  class PrepareNextError < StandardError; end
  class ExecuteError < StandardError; end
  class InvalidValueError < StandardError; end
  class AlreadyExistError < StandardError; end

  def initialize(dir)
    super(dir)
    @lockdir        = "lock_execute"
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

  # 配下の INCAR を表現する Incar クラスインスタンスを返す。
  # 存在しなければ例外 Errno::ENOENT を返す筈だが、
  # vasp dir の判定を incar でやっているので生じる筈がない。
  def incar
    VaspUtils::Incar.load_file("#{@dir}/INCAR")
  end

  # 配下の KPOINTS を表現する Kpoints クラスインスタンスを返す。
  def kpoints
    VaspUtils::Kpoints.load_file("#{@dir}/KPOINTS")
  end

  # 配下の vasprun.xml を表現する VasprunXml クラスインスタンスを返す。
  def vasprun_xml
    VaspUtils::VasprunXml.load_file("#{@dir}/vasprun.xml")
  end


  # 正常に終了していれば true を返す。
  # 実行する前や実行中、OUTCAR が完遂していなければ false。
  # MEMO: PI12345 ファイルは実行中のみ存在し、終了後 vasp (mpi？) に自動的に削除される。
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
      new_incar.dump(io)
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

    command = "cd #{@dir};"
    command += "#{info["mpi"]} -machinefile #{MACHINEFILE} -np #{nslots} #{info["vasp"]}"
    command += "| tee stdout"

    io = File.open("#{@dir}/executevasp.log", "w")
    io.puts command
    io.close

    end_status = system command
    raise ExecuteError, "end_status is #{end_status.inspect}" unless end_status
  end

  def prepare_next
    raise PrepareNextError, "VaspDir doesn't need next."
  end

  def generate_machinefile(lines)
    io = File.open("#{@dir}/#{MACHINEFILE}", "w")
    io.puts lines
    io.close
  end
end
