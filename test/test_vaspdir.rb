#! /usr/bin/env ruby
# coding: utf-8

$TEST = true

require "rubygems"
gem "comana"
require "comana/computationmanager.rb"

require "test/unit"
require "vasputils.rb"

# assert_equal( cor, data)
# assert_in_delta( cor, data, $tolerance )
# assert_raise( RuntimeError ){}

class VaspUtils::VaspDir < Comana::ComputationManager
  attr_reader :mode

  def calculate
    generated_files = [
      "CHG",
      "CHGCAR",
      "CONTCAR",
      "DOSCAR",
      "EIGENVAL",
      "IBZKPT",
      "OSZICAR",
      "OUTCAR",
      "PCDAT",
      "WAVECAR",
      "XDATCAR",
      "machines",
      "vasprun.xml",
    ]
    generated_files.map!{|i| "#{@dir}/#{i}"}
    command = "touch #{generated_files.join(" ")}"

    system command
  end
end


class TC_VaspDir < Test::Unit::TestCase

  GENERATED_FILES_VD00 = [
    "test/vaspdir/not-yet/CHG",
    "test/vaspdir/not-yet/CHGCAR",
    "test/vaspdir/not-yet/CONTCAR",
    "test/vaspdir/not-yet/DOSCAR",
    "test/vaspdir/not-yet/EIGENVAL",
    "test/vaspdir/not-yet/IBZKPT",
    "test/vaspdir/not-yet/OSZICAR",
    "test/vaspdir/not-yet/OUTCAR",
    "test/vaspdir/not-yet/PCDAT",
    "test/vaspdir/not-yet/WAVECAR",
    "test/vaspdir/not-yet/XDATCAR",
    "test/vaspdir/not-yet/machines",
    "test/vaspdir/not-yet/vasprun.xml",
  ]

  def setup
    @vd00 = VaspUtils::VaspDir.new("test/vaspdir/not-yet")
    @vd01 = VaspUtils::VaspDir.new("test/vaspdir/locked")
    @vd02 = VaspUtils::VaspDir.new("test/vaspdir/started")
    @vd03 = VaspUtils::VaspDir.new("test/vaspdir/finished")

    GENERATED_FILES_VD00.each do |file|
      FileUtils.rm file if File.exist? file
    end

    #lock_dir = "test/vaspdir/not-yet/lock"
    #Dir.rmdir(lock_dir) if Dir.exist?(lock_dir)
  end

  def test_initialize
    assert_raise(VaspUtils::VaspDir::InitializeError){VaspUtils::VaspDir.new("test/vaspdir/lack-INCAR"  )}
    assert_raise(VaspUtils::VaspDir::InitializeError){VaspUtils::VaspDir.new("test/vaspdir/lack-KPOINTS")}
    assert_raise(VaspUtils::VaspDir::InitializeError){VaspUtils::VaspDir.new("test/vaspdir/lack-POSCAR" )}
    assert_raise(VaspUtils::VaspDir::InitializeError){VaspUtils::VaspDir.new("test/vaspdir/lack-POTCAR" )}

    assert_raise(VaspUtils::VaspDir::InitializeError){VaspUtils::VaspDir.new("test/conditionanalyzer/00" )}

  end

  def test_finished?
    assert_equal(false, @vd00.finished?)
    assert_equal(false, @vd01.finished?)
    assert_equal(false, @vd02.finished?)
    assert_equal(true , @vd03.finished?)
  end

  def test_calculate
    lock_dir = "test/vaspdir/not-yet/lock_vaspdir"
    Dir.rmdir(lock_dir) if Dir.exist?(lock_dir)
    #pp @vd00;exit
    #@vd00.calculate
    assert_nothing_raised{@vd00.calculate}

    GENERATED_FILES_VD00.each do |file|
      assert(FileTest.exist?(file), "#{file} not found.")
    end
    assert(FileTest.exist? "test/vaspdir/not-yet/INCAR")
    assert(FileTest.exist? "test/vaspdir/not-yet/KPOINTS")
    assert(FileTest.exist? "test/vaspdir/not-yet/POSCAR")
    assert(FileTest.exist? "test/vaspdir/not-yet/POTCAR")

    lock_dir = "test/vaspdir/not-yet/lock_vaspdir"
    Dir.rmdir(lock_dir) if Dir.exist?(lock_dir)
  end

  def test_outcar
    assert_equal("test/vaspdir/started/OUTCAR", @vd02.outcar[:name])
    assert_equal("test/vaspdir/finished/OUTCAR", @vd03.outcar[:name])
  end

  def test_poscar
    t = @vd03.poscar
    assert_equal(CrystalCell::Cell, t.class)
    assert_in_delta(3.8879999999999999, t.axes[2][2])
    
    t = @vd00.poscar
    assert_equal(CrystalCell::Cell, t.class)
    assert_in_delta(3.8879999999999999, t.axes[2][2])
  end

  def test_contcar
    t = @vd03.contcar
    assert_equal(CrystalCell::Cell, t.class)
    assert_in_delta(3.8879999999999999, t.axes[2][2])
    
    assert_raise(Errno::ENOENT){@vd00.contcar}
  end

  def test_incar
    t = @vd00.incar
    assert_equal("400", t["ENCUT"])
  end

  def test_kpoints
    t = @vd00.kpoints
    assert_equal("Automatic mesh", t[:comment])
  end

  #undef test_next

  def teardown
    GENERATED_FILES_VD00.each do |file|
      FileUtils.rm file if File.exist? file
    end
  end

end

