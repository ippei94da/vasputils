#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "fileutils"

require "rubygems"
gem "comana"
require "comana/computationmanager.rb"

#require "vasputils.rb"
#require "vasputils/vaspdir.rb"

#
#
#
class VaspUtils::VaspGeometryOptimizer < Comana::ComputationManager
  class NoVaspDirError < Exception; end
  class LatestDirStartedError < Exception; end
  class NoIntegerEndedNameError < Exception; end

  def initialize(dir)
    super(dir)
    @lockdir    = "lock_vaspgeomopt"
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
    #  raise LatestDirStartedError if dir.state == :started
    #  dir.start
    #  if dir.finished?
    #    break
    #  else
    #    #dir = prepare_next
    #    puts "Geometry optimization fihished. Exit."
    #  end
    #end
    #puts "Geometry optimization fihished. Exit."
    #sleep 1 # for interrupt
  end

  # latest_dir から返って来る最新の VaspDir が finished? で真を返し、
  # かつ Iteration が 1 であるか。
  # Note: even when the geometry optimization does not include lattice shape,
  #   calculate will continued till to converge to Iter 1 calculation.
  def finished?
    return false unless latest_dir.finished?
    return false unless latest_dir.outcar[:ionic_steps] == 1
    return true
  end

  # Find latest VaspDir.
  # Return a last VaspDir which has the name by name sort
  # and which can be made as a VaspDir instance.
  # Note: in a series of geometry optimization,
  #   the directory names should have a rule of naming
  #   which can define a method <=>.
  #   Usually, it is simple sort of String.
  def latest_dir
    Dir.glob("#{@dir}/*").sort.reverse.find do |dir|
      begin
        vd = VaspUtils::VaspDir.new(dir)
        return vd
      rescue VaspUtils::VaspDir::InitializeError
        next
      end
    end
    raise NoVaspDirError, @dir
  end

  private

  # Generate next directory of latest_dir.
  def prepare_next
    new_dir = self.class.next_name(latest_dir.dir)
    Dir.mkdir new_dir
    FileUtils.cp("#{latest_dir.dir}/CHG"     , "#{new_dir}/CHG"     )
    FileUtils.cp("#{latest_dir.dir}/CHGCAR"  , "#{new_dir}/CHGCAR"  )
    FileUtils.cp("#{latest_dir.dir}/DOSCAR"  , "#{new_dir}/DOSCAR"  )
    FileUtils.cp("#{latest_dir.dir}/EIGENVAL", "#{new_dir}/EIGENVAL")
    FileUtils.cp("#{latest_dir.dir}/INCAR"   , "#{new_dir}/INCAR"   )
    FileUtils.cp("#{latest_dir.dir}/KPOINTS" , "#{new_dir}/KPOINTS" )
    FileUtils.cp("#{latest_dir.dir}/OSZICAR" , "#{new_dir}/OSZICAR" )
    FileUtils.cp("#{latest_dir.dir}/PCDAT"   , "#{new_dir}/PCDAT"   )
    FileUtils.cp("#{latest_dir.dir}/POTCAR"  , "#{new_dir}/POTCAR"  )
    FileUtils.cp("#{latest_dir.dir}/WAVECAR" , "#{new_dir}/WAVECAR" )
    FileUtils.cp("#{latest_dir.dir}/XDATCAR" , "#{new_dir}/XDATCAR" )
    FileUtils.cp("#{latest_dir.dir}/CONTCAR" , "#{new_dir}/POSCAR"  ) # change name
    # without POSCAR, OUTCAR, vasprun.xml
    VaspUtils::VaspDir.new(new_dir)
  end

end

