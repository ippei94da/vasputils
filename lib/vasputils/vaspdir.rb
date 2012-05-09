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

# Class for VASP executable directory,
# including input and output files.
#
class VaspDir < ComputationManager
  class InitializeError < Exception; end
  class NoVaspBinaryError < Exception; end
  class PrepareNextError < Exception; end

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
    raise PrepareNextError, "VaspDir doesn't need next."
  end

end
