#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
require "stringio"
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
        assert_raise(VaspUtils::VaspGeometryOptimizer::InitializeError){
            VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/not-geomopt/nothing")
        }

        assert_raise(VaspUtils::VaspGeometryOptimizer::InitializeError){
            VaspUtils::VaspGeometryOptimizer.new( TEST_DIR + "/not-geomopt/not-geomopt-subdir")
        }
    end

    def test_latest_dir
        assert_equal("#{@vgo00.dir}/geomopt00", @vgo00.latest_dir.dir)
        assert_equal("#{@vgo01.dir}/geomopt00", @vgo01.latest_dir.dir)
        assert_equal("#{@vgo02.dir}/geomopt01", @vgo02.latest_dir.dir)
        assert_equal("#{@vgo03.dir}/geomopt01", @vgo03.latest_dir.dir)
    end

    def test_finished?
        assert_equal(false, @vgo00.finished?)
        assert_equal(false, @vgo01.finished?)
        assert_equal(false, @vgo02.finished?)
        assert_equal(true , @vgo03.finished?)
        assert_equal(false, @vgo04.finished?)
    end

    def test_next_name
        assert_equal( "geomopt01" , VaspUtils::VaspGeometryOptimizer.next_name("geomopt00"))
        assert_equal( "geomopt01" , VaspUtils::VaspGeometryOptimizer.next_name("geomopt0"))
        assert_equal( "geomopt10" , VaspUtils::VaspGeometryOptimizer.next_name("geomopt09"))
        assert_equal( "geomopt11" , VaspUtils::VaspGeometryOptimizer.next_name("geomopt10"))
        assert_equal( "geomopt100", VaspUtils::VaspGeometryOptimizer.next_name("geomopt99"))
        assert_equal( "01"      , VaspUtils::VaspGeometryOptimizer.next_name("00"))
        assert_equal( "geomopt01" , VaspUtils::VaspGeometryOptimizer.next_name("geomopt"))
        #assert_raise(VaspUtils::VaspGeometryOptimizer::NoIntegerEndedNameError){VaspUtils::VaspGeometryOptimizer.next_name("try")}
    end

    def test_prepare_next
        dir = TEST_DIR + "/prepare_next/normal"
        old_number_dir = dir + "/geomopt00"
        new_number_dir = dir + "/geomopt01"

        if Dir.exist?(new_number_dir)
            Dir.glob(new_number_dir + "/*").each do |file|
                FileUtils.rm file
            end
            Dir.rmdir new_number_dir
        end

        vgo = VaspUtils::VaspGeometryOptimizer.new(dir)
        vgo.prepare_next
        assert_equal(true ,Dir.exist?(new_number_dir))
        assert_equal(true , File.exist?(new_number_dir + "/CHG"         ))
        assert_equal(true , File.exist?(new_number_dir + "/CHGCAR"  ))
        assert_equal(true , File.exist?(new_number_dir + "/DOSCAR"  ))
        assert_equal(true , File.exist?(new_number_dir + "/EIGENVAL"))
        assert_equal(true , File.exist?(new_number_dir + "/INCAR"       ))
        assert_equal(true , File.exist?(new_number_dir + "/KPOINTS" ))
        assert_equal(true , File.exist?(new_number_dir + "/OSZICAR" ))
        assert_equal(true , File.exist?(new_number_dir + "/PCDAT"       ))
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
        assert_equal(true,  File.exist?("#{tmp}/geomopt00"))
        assert_equal(false, File.exist?("#{tmp}/geomopt01"))
        assert_equal(4,         Dir.glob("#{tmp}/geomopt00/*").size)
        assert_equal("POSCAR_00\n", File.open("#{tmp}/geomopt00/POSCAR", "r").readline)
        FileUtils.rm_rf tmp if FileTest.exist? tmp
    end

    def test_reset_next
        #with correct POSCAR and CONTCAR
        orig = TEST_DIR + "/reset_next/poscar-contcar/orig"
        tmp  = TEST_DIR + "/reset_next/poscar-contcar/tmp"
        FileUtils.rm_r tmp if FileTest.exist? tmp
        FileUtils.cp_r(orig, tmp)
        vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
        io = StringIO.new
        vgo.reset_next(io)
        assert_equal(true,  File.exist?("#{tmp}/geomopt00"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt01"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt02"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt03"))
        assert_equal(4,         Dir.glob("#{tmp}/geomopt03/*").size)
        assert_equal("CONTCAR_02\n", File.open("#{tmp}/geomopt03/POSCAR", "r").readline)
        FileUtils.rm_rf tmp if FileTest.exist? tmp

        #with correct POSCAR and empty CONTCAR
        orig = TEST_DIR + "/reset_next/empty-contcar/orig"
        tmp  = TEST_DIR + "/reset_next/empty-contcar/tmp"
        FileUtils.rm_r tmp if FileTest.exist? tmp
        FileUtils.cp_r(orig, tmp)
        vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
        vgo.reset_next(io)
        assert_equal(true,  File.exist?("#{tmp}/geomopt00"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt01"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt02"))
        assert_equal(false,  File.exist?("#{tmp}/geomopt03"))
        assert_equal(4,         Dir.glob("#{tmp}/geomopt02/*").size)
        assert_equal("POSCAR_02\n", File.open("#{tmp}/geomopt02/POSCAR", "r").readline)
        FileUtils.rm_rf tmp if FileTest.exist? tmp

        #with correct POSCAR and no CONTCAR
        orig = TEST_DIR + "/reset_next/no-contcar/orig"
        tmp  = TEST_DIR + "/reset_next/no-contcar/tmp"
        FileUtils.rm_r tmp if FileTest.exist? tmp
        FileUtils.cp_r(orig, tmp)
        vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
        vgo.reset_next(io)
        assert_equal(true,  File.exist?("#{tmp}/geomopt00"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt01"))
        assert_equal(true,  File.exist?("#{tmp}/geomopt02"))
        assert_equal(false,  File.exist?("#{tmp}/geomopt03"))
        assert_equal(4,         Dir.glob("#{tmp}/geomopt02/*").size)
        assert_equal("POSCAR_02\n", File.open("#{tmp}/geomopt02/POSCAR", "r").readline)
        FileUtils.rm_rf tmp if FileTest.exist? tmp
    end

    def test_reset_reincarnation
        orig = TEST_DIR + "/reset_reincarnation/orig"
        tmp  = TEST_DIR + "/reset_reincarnation/tmp"

        FileUtils.rm_r tmp if FileTest.exist? tmp

        FileUtils.cp_r(orig, tmp)
        vgo = VaspUtils::VaspGeometryOptimizer.new(tmp)
        vgo.reset_reincarnate

        assert_equal(true,  File.exist?("#{tmp}/geomopt00"))
        assert_equal(false, File.exist?("#{tmp}/geomopt01"))
        #assert_equal(1,         Dir.glob("#{tmp}/*").size)
            #This test may rail in NFS environment due to nfs lock; geomopt02/.nfs*.
        assert_equal(4,         Dir.glob("#{tmp}/geomopt00/*").size)
        assert_equal("CONTCAR_01\n", File.open("#{tmp}/geomopt00/POSCAR", "r").readline)

        FileUtils.rm_rf tmp if FileTest.exist? tmp
    end

end

