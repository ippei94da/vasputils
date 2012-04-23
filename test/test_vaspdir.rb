#! /usr/bin/env ruby
# coding: utf-8

$TEST = true

require "rubygems"
gem "comana"
require "comana.rb"

class VaspDir < Comana
  attr_reader :mode
  public :finished?
end

require "test/unit"
require "vasputils/vaspdir.rb"

# assert_equal( cor, data)
# assert_in_delta( cor, data, $tolerance )
# assert_raise( RuntimeError ){}


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
    "test/vaspdir/not-yet/lock",
  ]

  def setup
    @vd00 = VaspDir.new("test/vaspdir/not-yet")
    @vd01 = VaspDir.new("test/vaspdir/locked")
    @vd02 = VaspDir.new("test/vaspdir/started")
    @vd03 = VaspDir.new("test/vaspdir/finished")

    GENERATED_FILES_VD00.each do |file|
      FileUtils.rm file if File.exist? file
    end
  end

  def test_initialize
    assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-INCAR"  )}
    assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-KPOINTS")}
    assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-POSCAR" )}
    assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-POTCAR" )}
  end

  def test_finished?
    assert_equal(false, @vd00.finished?)
    assert_equal(false, @vd01.finished?)
    assert_equal(false, @vd02.finished?)
    assert_equal(true , @vd03.finished?)
  end

  def test_calculate
    assert_nothing_raised{@vd00.calculate}
    GENERATED_FILES_VD00.each do |file|
      assert(FileTest.exist?(file), "#{file} not found.")
    end
    assert(FileTest.exist? "test/vaspdir/not-yet/INCAR")
    assert(FileTest.exist? "test/vaspdir/not-yet/KPOINTS")
    assert(FileTest.exist? "test/vaspdir/not-yet/POSCAR")
    assert(FileTest.exist? "test/vaspdir/not-yet/POTCAR")
    #
    io = File.open("test/vaspdir/not-yet-ISIF2/lock", "r")
    lines = io.readlines
    assert_equal("HOST: #{ENV["HOST"]}\n", lines[0])
    assert(/^START: / =~ lines[1])
    assert_equal("STATUS: normal ended.\n", lines[2])

    io.close
    # あとかたづけは teardown にまかせる。
  end

  def test_outcar
    assert_equal("test/vaspdir/started/OUTCAR", @vd02.outcar[:name])
    assert_equal("test/vaspdir/finished/OUTCAR", @vd03.outcar[:name])
  end

  def test_contcar
    t = @vd00.contcar
    assert_equal(Cell, t.class)
    assert_in_delta(3.8678456093562040, t.axes[2][2])
    
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

end

