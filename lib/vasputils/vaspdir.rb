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
  class InitializeError < Exception; end
  class NoVaspBinaryError < Exception; end
  class PrepareNextError < Exception; end
  class ExecuteError < Exception; end

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
    begin
      info =
        Comana::ClusterSetting.load_file("#{ENV["HOME"]}/.clustersetting").settings_host(ENV["HOST"])
      vasp = info["vasp"]
    rescue
      #vasp = "vasp"
      raise NoVaspBinaryError, "No vasp path in #{ENV["HOME"]}/.clustersetting"
    end
    command = "cd #{@dir};"
    command += vasp
    command += "> stdout"

    end_status = system command
    raise ExecuteError, "end_status is #{end_status.inspect}" unless end_status
  end

  def prepare_next
    #do_nothing
    raise PrepareNextError, "VaspDir doesn't need next."
  end

end
