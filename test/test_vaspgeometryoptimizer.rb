#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "test/unit"

require "vasputils.rb"
#require "vasputils/vaspgeometryoptimizer.rb"


class VaspUtils::VaspGeometryOptimizer < Comana::ComputationManager
  public :latest_dir, :prepare_next
end

class TC_VaspGeometryOptimizer < Test::Unit::TestCase
  TEST_DIR = "test/vaspgeometryoptimizer"
  def setup
    @vgo00 = VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/not-yet")
    @vgo01 = VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/started")
    @vgo02 = VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/till01")
    @vgo03 = VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/ended-Iter1")
    @vgo04 = VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/ended-Iter2")
  end

  def test_initialize
    assert_raise(VaspUtils::VaspGeometryOptimizer::NoVaspDirError){
      VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/not-geomopt/nothing")
    }

    assert_raise(VaspUtils::VaspGeometryOptimizer::NoVaspDirError){
      VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/not-geomopt/not-try-subdir")
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
    assert_equal( "try01" , VaspUtils::VaspGeometryOptimizer.next_name("try00"))
    assert_equal( "try01" , VaspUtils::VaspGeometryOptimizer.next_name("try0"))
    assert_equal( "try10" , VaspUtils::VaspGeometryOptimizer.next_name("try09"))
    assert_equal( "try11" , VaspUtils::VaspGeometryOptimizer.next_name("try10"))
    assert_equal( "try100", VaspUtils::VaspGeometryOptimizer.next_name("try99"))
    assert_equal( "01"    , VaspUtils::VaspGeometryOptimizer.next_name("00"))
    assert_equal( "try01" , VaspUtils::VaspGeometryOptimizer.next_name("try"))
    #assert_raise(VaspUtils::VaspGeometryOptimizer::NoIntegerEndedNameError){VaspUtils::VaspGeometryOptimizer.next_name("try")}
  end

  def test_prepare_next
    dir = TEST_DIR + "/prepare_next/normal"
    old_number_dir = dir + "/try00"
    new_number_dir = dir + "/try01"

    if Dir.exist?(new_number_dir)
      Dir.glob(new_number_dir + "/*").each do |file|
        FileUtils.rm file
      end
      Dir.rmdir new_number_dir
    end

    vgo = VaspUtils::VaspGeometryOptimizer.new(dir)
    vgo.prepare_next
    assert_equal(true ,Dir.exist?(new_number_dir))
    assert_equal(true , File.exist?(new_number_dir + "/CHG"     ))
    assert_equal(true , File.exist?(new_number_dir + "/CHGCAR"  ))
    assert_equal(true , File.exist?(new_number_dir + "/DOSCAR"  ))
    assert_equal(true , File.exist?(new_number_dir + "/EIGENVAL"))
    assert_equal(true , File.exist?(new_number_dir + "/INCAR"   ))
    assert_equal(true , File.exist?(new_number_dir + "/KPOINTS" ))
    assert_equal(true , File.exist?(new_number_dir + "/OSZICAR" ))
    assert_equal(true , File.exist?(new_number_dir + "/PCDAT"   ))
    assert_equal(true , File.exist?(new_number_dir + "/POTCAR"  ))
    assert_equal(true , File.exist?(new_number_dir + "/WAVECAR" ))
    assert_equal(true , File.exist?(new_number_dir + "/XDATCAR" ))
    assert_equal(true , File.exist?(new_number_dir + "/POSCAR"  ))
    assert_equal(false, File.exist?(new_number_dir + "/CONTCAR" ))
    assert_equal(false, File.exist?(new_number_dir + "/OUTCAR" ))
    assert_equal(false, File.exist?(new_number_dir + "/vasprun.xml" ))

    if Dir.exist?(new_number_dir)
      Dir.glob(new_number_dir + "/*").each do |file|
        FileUtils.rm file
      end
      Dir.rmdir new_number_dir
    end

    dir = TEST_DIR + "/prepare_next/no-contcar"
    vgo = VaspUtils::VaspGeometryOptimizer.new(dir)
    assert_raise(VaspUtils::VaspGeometryOptimizer::NoContcarError){
      vgo.prepare_next
    }
  end


  def test_reset_init
    orig = TEST_DIR + "/reset_init/orig"
    tmp  = TEST_DIR + "/reset_init/tmp"

    FileUtils.rm_r tmp if FileTest.exist? tmp

    FileUtils.cp_r(orig, tmp)
    vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
    vgo.reset_init

    assert_equal(true,  File.exist?("#{tmp}/try00"))
    assert_equal(false, File.exist?("#{tmp}/try01"))
    #assert_equal(1,     Dir.glob("#{tmp}/*").size)
      #This test may rail in NFS environment due to nfs lock; try02/.nfs*.
    assert_equal(4,     Dir.glob("#{tmp}/try00/*").size)
    assert_equal("POSCAR_00\n", File.open("#{tmp}/try00/POSCAR", "r").readline)

    FileUtils.rm_rf tmp if FileTest.exist? tmp
  end

  def test_reset_next
    orig = TEST_DIR + "/reset_next/orig"
    tmp  = TEST_DIR + "/reset_next/tmp"

    FileUtils.rm_r tmp if FileTest.exist? tmp

    FileUtils.cp_r(orig, tmp)
    vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
    vgo.reset_next

    assert_equal(true,  File.exist?("#{tmp}/try00"))
    assert_equal(true,  File.exist?("#{tmp}/try01"))
    assert_equal(true,  File.exist?("#{tmp}/try02"))
    assert_equal(true,  File.exist?("#{tmp}/try03"))
    #assert_equal(1,     Dir.glob("#{tmp}/*").size)
      #This test may rail in NFS environment due to nfs lock; try02/.nfs*.
    assert_equal(4,     Dir.glob("#{tmp}/try03/*").size)
    assert_equal("CONTCAR_02\n", File.open("#{tmp}/try03/POSCAR", "r").readline)

    FileUtils.rm_rf tmp if FileTest.exist? tmp
  end

  def test_reset_reincarnation
    orig = TEST_DIR + "/reset_reincarnation/orig"
    tmp  = TEST_DIR + "/reset_reincarnation/tmp"

    FileUtils.rm_r tmp if FileTest.exist? tmp

    FileUtils.cp_r(orig, tmp)
    vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
    vgo.reset_reincarnate

    assert_equal(true,  File.exist?("#{tmp}/try00"))
    assert_equal(false, File.exist?("#{tmp}/try01"))
    #assert_equal(1,     Dir.glob("#{tmp}/*").size)
      #This test may rail in NFS environment due to nfs lock; try02/.nfs*.
    assert_equal(4,     Dir.glob("#{tmp}/try00/*").size)
    assert_equal("CONTCAR_01\n", File.open("#{tmp}/try00/POSCAR", "r").readline)

    FileUtils.rm_rf tmp if FileTest.exist? tmp
  end

end

