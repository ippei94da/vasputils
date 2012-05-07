#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "test/unit"
require "vasputils/vaspgeomopt.rb"


class VaspGeomOpt < ComputationManager
  public :latest_dir, :prepare_next
end

class TC_VaspGeomOpt < Test::Unit::TestCase
  TEST_DIR = "test/vaspgeomopt"
  def setup
    @vgo00 = VaspGeomOpt.new( TEST_DIR + "/not-yet")
    @vgo01 = VaspGeomOpt.new( TEST_DIR + "/started")
    @vgo02 = VaspGeomOpt.new( TEST_DIR + "/till01")
    @vgo03 = VaspGeomOpt.new( TEST_DIR + "/ended-Iter1")
    @vgo04 = VaspGeomOpt.new( TEST_DIR + "/ended-Iter2")
  end

  def test_initialize
    assert_raise(VaspGeomOpt::NoVaspDirError){
      VaspGeomOpt.new( TEST_DIR + "/not-geomopt")
    }
  end

  def test_latest_dir
    assert_equal("#{@vgo00.dir}/try00", @vgo00.latest_dir.dir)
    assert_equal("#{@vgo01.dir}/try00", @vgo01.latest_dir.dir)
    assert_equal("#{@vgo02.dir}/try01", @vgo02.latest_dir.dir)
    assert_equal("#{@vgo03.dir}/try01", @vgo03.latest_dir.dir)
  end

  def test_finished?
    assert_equal(false, @vgo00.finished?)
    assert_equal(false, @vgo01.finished?)
    assert_equal(false, @vgo02.finished?)
    assert_equal(true , @vgo03.finished?)
    assert_equal(false, @vgo04.finished?)
  end

  def test_next_name
    assert_equal( "try01" , VaspGeomOpt.next_name("try00"))
    assert_equal( "try01" , VaspGeomOpt.next_name("try0"))
    assert_equal( "try10" , VaspGeomOpt.next_name("try09"))
    assert_equal( "try11" , VaspGeomOpt.next_name("try10"))
    assert_equal( "try100", VaspGeomOpt.next_name("try99"))
    assert_equal( "01"    , VaspGeomOpt.next_name("00"))
    assert_equal( "try01" , VaspGeomOpt.next_name("try"))
    #assert_raise(VaspGeomOpt::NoIntegerEndedNameError){VaspGeomOpt.next_name("try")}
  end

  def test_prepare_next
    dir = TEST_DIR + "/prepare_next"
    old_number_dir = dir + "/try00"
    new_number_dir = dir + "/try01"

    if Dir.exist?(new_number_dir)
      Dir.glob(new_number_dir + "/*").each do |file|
        FileUtils.rm file
      end
      Dir.rmdir new_number_dir
    end

    vgo = VaspGeomOpt.new(dir)
    vgo.prepare_next
    assert(Dir.exist?(new_number_dir))
    assert(File.exist?(new_number_dir + "/CHG"     ))
    assert(File.exist?(new_number_dir + "/CHGCAR"  ))
    assert(File.exist?(new_number_dir + "/DOSCAR"  ))
    assert(File.exist?(new_number_dir + "/EIGENVAL"))
    assert(File.exist?(new_number_dir + "/INCAR"   ))
    assert(File.exist?(new_number_dir + "/KPOINTS" ))
    assert(File.exist?(new_number_dir + "/OSZICAR" ))
    assert(File.exist?(new_number_dir + "/PCDAT"   ))
    assert(File.exist?(new_number_dir + "/POTCAR"  ))
    assert(File.exist?(new_number_dir + "/WAVECAR" ))
    assert(File.exist?(new_number_dir + "/XDATCAR" ))
    assert(File.exist?(new_number_dir + "/POSCAR"  ))
    assert(! File.exist?(new_number_dir + "/CONTCAR" ))
    assert(! File.exist?(new_number_dir + "/OUTCAR" ))
    assert(! File.exist?(new_number_dir + "/vasprun.xml" ))

    if Dir.exist?(new_number_dir)
      Dir.glob(new_number_dir + "/*").each do |file|
        FileUtils.rm file
      end
      Dir.rmdir new_number_dir
    end
  end

end

