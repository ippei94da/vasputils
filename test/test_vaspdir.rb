#! /usr/bin/env ruby
# coding: utf-8

$TEST = true

class VaspDir
	attr_reader :mode
end

require "test/unit"
require "vasputils/vaspdir.rb"

#	assert_equal( cor, data)
#	assert_in_delta( cor, data, $tolerance )
#	assert_raise( RuntimeError ){}


class TC_VaspDir < Test::Unit::TestCase

	GENERATED_FILES_VD00 = 
	[
		"test/vaspdir/not-yet-ISIF2/CHG",
		"test/vaspdir/not-yet-ISIF2/CHGCAR",
		"test/vaspdir/not-yet-ISIF2/CONTCAR",
		"test/vaspdir/not-yet-ISIF2/DOSCAR",
		"test/vaspdir/not-yet-ISIF2/EIGENVAL",
		"test/vaspdir/not-yet-ISIF2/IBZKPT",
		"test/vaspdir/not-yet-ISIF2/OSZICAR",
		"test/vaspdir/not-yet-ISIF2/OUTCAR",
		"test/vaspdir/not-yet-ISIF2/PCDAT",
		"test/vaspdir/not-yet-ISIF2/WAVECAR",
		"test/vaspdir/not-yet-ISIF2/XDATCAR",
		"test/vaspdir/not-yet-ISIF2/machines",
		"test/vaspdir/not-yet-ISIF2/vasprun.xml",
		"test/vaspdir/not-yet-ISIF2/lock",
	]

	def setup
		@vd00 = VaspDir.new("test/vaspdir/not-yet-ISIF2")
		@vd01 = VaspDir.new("test/vaspdir/not-yet-ISIF3")
		@vd02 = VaspDir.new("test/vaspdir/ISIF3-NSW100-OUTCAR-Iter1-INT")
		@vd03 = VaspDir.new("test/vaspdir/ISIF2-NSW100-OUTCAR-Iter1")
		@vd04 = VaspDir.new("test/vaspdir/ISIF3-NSW002-OUTCAR-Iter2")
		@vd05 = VaspDir.new("test/vaspdir/ISIF3-NSW100-OUTCAR-Iter3")
		@vd06 = VaspDir.new("test/vaspdir/PI")
		@vd07 = VaspDir.new("test/vaspdir/lock")
		@vd08 = VaspDir.new("test/vaspdir/lock-PI")
		@vd09 = VaspDir.new("test/vaspdir/ISIF2-NSW100-OUTCAR-Iter3")
		@vd10 = VaspDir.new("test/vaspdir/next-try00")
		@vd11 = VaspDir.new("test/vaspdir/ISIF2-NSW000-OUTCAR-Iter1")
		@vd12 = VaspDir.new("test/vaspdir/ISIF2-NSW001-OUTCAR-Iter1")
		@vd13 = VaspDir.new("test/vaspdir/ISIF3-NSW000-OUTCAR-Iter1")
		@vd14 = VaspDir.new("test/vaspdir/ISIF3-NSW001-OUTCAR-Iter1")
		@vd15 = VaspDir.new("test/vaspdir/IBRION-1-NSW000-OUTCAR-Iter1")

		GENERATED_FILES_VD00.each do |file|
			FileUtils.rm file if File.exist? file
		end
	end

	def teardown
		["test/vaspdir/next-try01/POSCAR" ,
			"test/vaspdir/next-try01/POTCAR" ,
			"test/vaspdir/next-try01/INCAR"  ,
			"test/vaspdir/next-try01/KPOINTS"].each do |filename|
			FileUtils.rm(filename) if File.exist?(filename)
		end
		Dir.rmdir("test/vaspdir/next-try01") if File.exist?("test/vaspdir/next-try01")

		GENERATED_FILES_VD00.each do |file|
			FileUtils.rm file if File.exist? file
		end
	end

	def test_initialize
		assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-INCAR"  )}
		assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-KPOINTS")}
		assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-POSCAR" )}
		assert_raise(VaspDir::InitializeError){VaspDir.new("test/vaspdir/lack-POTCAR" )}

		assert_equal(:geom_opt_atoms,   @vd00.mode)
		assert_equal(:geom_opt_lattice, @vd01.mode)
		assert_equal(:geom_opt_lattice, @vd02.mode)
		assert_equal(:geom_opt_atoms,   @vd03.mode)
	end

	def test_name
		assert_equal("test/vaspdir/not-yet-ISIF2"                , @vd00.name)
		assert_equal("test/vaspdir/not-yet-ISIF3"                , @vd01.name)
		assert_equal("test/vaspdir/ISIF3-NSW100-OUTCAR-Iter1-INT", @vd02.name)
		assert_equal("test/vaspdir/ISIF2-NSW100-OUTCAR-Iter1"    , @vd03.name)
		assert_equal("test/vaspdir/ISIF3-NSW002-OUTCAR-Iter2"    , @vd04.name)
		assert_equal("test/vaspdir/ISIF3-NSW100-OUTCAR-Iter3"    , @vd05.name)
		assert_equal("test/vaspdir/PI"                           , @vd06.name)
		assert_equal("test/vaspdir/lock"                         , @vd07.name)
		assert_equal("test/vaspdir/lock-PI"                      , @vd08.name)
		assert_equal("test/vaspdir/ISIF2-NSW100-OUTCAR-Iter3"    , @vd09.name)
		assert_equal("test/vaspdir/next-try00"                   , @vd10.name)
		assert_equal("test/vaspdir/ISIF2-NSW000-OUTCAR-Iter1"    , @vd11.name)
		assert_equal("test/vaspdir/ISIF2-NSW001-OUTCAR-Iter1"    , @vd12.name)
		assert_equal("test/vaspdir/ISIF3-NSW000-OUTCAR-Iter1"    , @vd13.name)
		assert_equal("test/vaspdir/ISIF3-NSW001-OUTCAR-Iter1"    , @vd14.name)
		assert_equal("test/vaspdir/IBRION-1-NSW000-OUTCAR-Iter1" , @vd15.name)
	end

	def test_started?
		assert_equal(false, @vd00.started?)
		assert_equal(false, @vd01.started?)
		assert_equal(true , @vd02.started?)
		assert_equal(true , @vd03.started?)
		assert_equal(true , @vd04.started?)
		assert_equal(true , @vd05.started?)
		assert_equal(false, @vd06.started?)
		assert_equal(true , @vd07.started?)
		assert_equal(true , @vd08.started?)
		assert_equal(true , @vd09.started?)
		assert_equal(true , @vd10.started?)
		assert_equal(true , @vd11.started?)
		assert_equal(true , @vd12.started?)
		assert_equal(true , @vd13.started?)
		assert_equal(true , @vd14.started?)
		assert_equal(true , @vd15.started?)
	end

	def test_normal_ended?
		assert_equal(false, @vd00.normal_ended?)
		assert_equal(false, @vd01.normal_ended?)
		assert_equal(false, @vd02.normal_ended?)
		assert_equal(true , @vd03.normal_ended?)
		assert_equal(true , @vd04.normal_ended?)
		assert_equal(true , @vd05.normal_ended?)
		assert_equal(false, @vd06.normal_ended?)
		assert_equal(false, @vd07.normal_ended?)
		assert_equal(false, @vd08.normal_ended?)
		assert_equal(true , @vd09.normal_ended?)
	end

	def test_to_be_continued?
		assert_equal(false, @vd00.to_be_continued?)
		assert_equal(false, @vd01.to_be_continued?)
		assert_equal(false, @vd02.to_be_continued?)
		assert_equal(false, @vd03.to_be_continued?)
		assert_equal(true , @vd04.to_be_continued?)
		assert_equal(true , @vd05.to_be_continued?)
		assert_equal(false, @vd06.to_be_continued?)
		assert_equal(false, @vd07.to_be_continued?)
		assert_equal(false, @vd08.to_be_continued?)
		assert_equal(false, @vd09.to_be_continued?)
		assert_equal(true , @vd10.to_be_continued?)
		assert_equal(false, @vd11.to_be_continued?)
		assert_equal(false, @vd12.to_be_continued?)
		assert_equal(false, @vd13.to_be_continued?)
		assert_equal(false, @vd14.to_be_continued?)
		assert_equal(false, @vd15.to_be_continued?)
	end

	def test_calculate
		assert_raise(VaspDir::LockedError){@vd07.calculate}
		assert_raise(VaspDir::LockedError){@vd08.calculate}

		#
		assert_nothing_raised{@vd00.calculate}
		GENERATED_FILES_VD00.each do |file|
			assert(FileTest.exist?(file), "#{file} not found.")
		end
		assert(FileTest.exist? "test/vaspdir/not-yet-ISIF2/INCAR")
		assert(FileTest.exist? "test/vaspdir/not-yet-ISIF2/KPOINTS")
		assert(FileTest.exist? "test/vaspdir/not-yet-ISIF2/POSCAR")
		assert(FileTest.exist? "test/vaspdir/not-yet-ISIF2/POTCAR")
		#
		io = File.open("test/vaspdir/not-yet-ISIF2/lock", "r")
		lines = io.readlines
		assert_equal("HOST: #{ENV["HOST"]}\n", lines[0])
		assert(/^START: / =~ lines[1])
		assert_equal("STATUS: normal ended.\n", lines[2])

		io.close
		# あとかたづけは teardown にまかせる。
	end

	def test_next
		assert_raise(VaspDir::NotEndedError){@vd00.next}
		assert_raise(VaspDir::NotEndedError){@vd01.next}
		assert_raise(VaspDir::NotEndedError){@vd02.next}
		assert_raise(VaspDir::ConvergedError){@vd03.next}
		assert_raise(VaspDir::NotEndedError){@vd06.next}
		assert_raise(VaspDir::NotEndedError){@vd07.next}
		assert_raise(VaspDir::NotEndedError){@vd08.next}
		assert_raise(VaspDir::ConvergedError){@vd09.next}

		assert_equal(true , FileTest.exist?("test/vaspdir/next-try00"))
		assert_equal(false, FileTest.exist?("test/vaspdir/next-try01"))
		@vd10.next
		assert_equal("test/vaspdir/next-try01", @vd10.name)
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try00"))
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try01"))
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try01/POSCAR"))
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try01/POTCAR"))
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try01/INCAR"))
		assert_equal(true , FileTest.exist?("test/vaspdir/next-try01/KPOINTS"))
		assert_equal(4 , Dir.glob("test/vaspdir/next-try01/*").size)
		#
		poscar_00  = File.open("test/vaspdir/next-try00/POSCAR" ).readlines
		contcar_00 = File.open("test/vaspdir/next-try00/CONTCAR").readlines
		poscar_01  = File.open("test/vaspdir/next-try01/POSCAR" ).readlines
		assert_equal(false, poscar_00  == contcar_00)
		assert_equal(true,  contcar_00 == poscar_01)
		assert_equal(false, poscar_01  == poscar_00)
		# あとかたづけは teardown にまかせる。
	end

	def test_teardown
		# NO TEST
	end

	def test_internal_steps
		assert_equal(18, @vd10.internal_steps)
	end

	def test_external_steps
		assert_equal(2, @vd10.external_steps)
	end

	def test_elapsed_time
		assert_in_delta(126.383, @vd10.elapsed_time)
	end

	def test_outcar
		assert_equal("test/vaspdir/next-try00/OUTCAR", @vd10.outcar[:name])
	end

	def test_contcar
		t = @vd10.contcar
		assert_equal(Cell, t.class)
		assert_in_delta(3.8678456093562040, t.axes[2][2])
		
		assert_raise(Errno::ENOENT){@vd00.contcar}
	end

	def test_incar
		t = @vd10.incar
		assert_equal("400", t["ENCUT"])
	end

	def test_kpoints
		t = @vd10.kpoints
		assert_equal("Automatic mesh", t[:comment])
	end

	#undef test_next

end

