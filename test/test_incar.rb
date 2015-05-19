#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils.rb"
require "vasputils/incar.rb"
require "stringio"

# assert_equal( cor, data)
# assert_in_delta( cor, data, $tolerance )
# assert_raise( RuntimeError ){}

class TC_Incar < Test::Unit::TestCase
  #def setup
  # @k = Incar.new
  #end
  
  SAMPLE_PAIRS = {
    "SYSTEM"    => "Untitled",
    "PREC"      => "High",
    "IBRION"    => "2",
    "NSW"           => "100",
    "ISIF"      => "2",
    "ENCUT"     => "400",
    "NELM"      => "60",
    "NELMIN"    => "2",
    "EDIFF"     => "1.0e-05",
    "EDIFFG"    => "-0.02",
    "VOSKOWN" => "1",
    "NBLOCK"    => "1",
    "ISPIN"     => "1",
    "INIWAV"    => "1",
    "ISTART"    => "1",
    "ICHARG"    => "1",
    "LWAVE"     => ".TRUE.",
    "LCHARG"    => ".TRUE.",
    "ISMEAR"    => "0",
    "SIGMA"     => "0.1",
    "IALGO"     => "38",
    "LREAL"     => "Auto",
    "NGX"           => "36",
    "NGY"           => "36",
    "NGZ"           => "42",
  }

  def test_self_parse
    io = StringIO.new
    io.puts "# SCF input for VASP"
    io.puts "# Note that VASP uses the FIRST occurence of a keyword"
    io.puts "# if single point calc, IBRION = -1, NSW = 0, and comment out ISIF"
    io.puts ""
    io.puts " SYSTEM = Untitled (VASP)"
    io.puts "   PREC = High"
    io.puts " IBRION = 2"
    io.puts "    NSW = 100        #maximum number of ionic steps"
    io.puts "   ISIF = 2"
    io.puts "  ENCUT = 400"
    io.puts "   NELM = 60         #maximum number of electronic steps"
    io.puts " NELMIN = 2          #minimum number of electronic steps"
    io.puts "  EDIFF = 1.0e-05"
    io.puts " EDIFFG = -0.02"
    io.puts "VOSKOWN = 1"
    io.puts " NBLOCK = 1"
    io.puts "  ISPIN = 1          #1:non spin polarized, 2:spin polarized"
    io.puts " INIWAV = 1"
    io.puts " ISTART = 1"
    io.puts " ICHARG = 1"
    io.puts "  LWAVE = .TRUE."
    io.puts " LCHARG = .TRUE."
    io.puts " ISMEAR = 0"
    io.puts "  SIGMA = 0.1"
    io.puts "  IALGO = 38         #38:KosugiAlgorithm, 48:RMM-DIIS"
    io.puts "  LREAL = Auto       #fast & not accurate"
    io.puts "    NGX = 36"
    io.puts "    NGY = 36"
    io.puts "    NGZ = 42"
    io.rewind
    incar = VaspUtils::Incar.parse(io)
    #assert_equal(incar.data["SYSTEM"], "Untitled (VASP)")
    assert_equal(incar.data["SYSTEM"], "Untitled")
    assert_equal(incar.data["PREC"], "High")
    assert_equal(incar.data["IBRION"], "2")
    assert_equal(incar.data["NSW"], "100")
    assert_equal(incar.data["ISIF"], "2")
    assert_equal(incar.data["ENCUT"], "400")
    assert_equal(incar.data["NELM"], "60")
    assert_equal(incar.data["NELMIN"], "2")
    assert_equal(incar.data["EDIFF"], "1.0e-05")
    assert_equal(incar.data["EDIFFG"], "-0.02")
    assert_equal(incar.data["VOSKOWN"], "1")
    assert_equal(incar.data["NBLOCK"], "1")
    assert_equal(incar.data["ISPIN"], "1")
    assert_equal(incar.data["INIWAV"], "1")
    assert_equal(incar.data["ISTART"], "1")
    assert_equal(incar.data["ICHARG"], "1")
    assert_equal(incar.data["LWAVE"], ".TRUE.")
    assert_equal(incar.data["LCHARG"], ".TRUE.")
    assert_equal(incar.data["ISMEAR"], "0")
    assert_equal(incar.data["SIGMA"], "0.1")
    assert_equal(incar.data["IALGO"], "38")
    assert_equal(incar.data["LREAL"], "Auto")
    assert_equal(incar.data["NGX"], "36")
    assert_equal(incar.data["NGY"], "36")
    assert_equal(incar.data["NGZ"], "42")
  end

  def test_self_load_file
    incar = VaspUtils::Incar.load_file "test/incar/INCAR.00"
    assert_equal(incar.data["SYSTEM"    ], "Untitled")
    assert_equal(incar.data["PREC"      ], "High")
    assert_equal(incar.data["IBRION"    ], "2")
    assert_equal(incar.data["NSW"       ], "100")
    assert_equal(incar.data["ISIF"      ], "2")
    assert_equal(incar.data["ENCUT"     ], "400")
    assert_equal(incar.data["NELM"      ], "60")
    assert_equal(incar.data["NELMIN"    ], "2")
    assert_equal(incar.data["EDIFF"     ], "1.0e-05")
    assert_equal(incar.data["EDIFFG"    ], "-0.02")
    assert_equal(incar.data["VOSKOWN"   ], "1")
    assert_equal(incar.data["NBLOCK"    ], "1")
    assert_equal(incar.data["ISPIN"     ], "1")
    assert_equal(incar.data["INIWAV"    ], "1")
    assert_equal(incar.data["ISTART"    ], "1")
    assert_equal(incar.data["ICHARG"    ], "1")
    assert_equal(incar.data["LWAVE"     ], ".TRUE.")
    assert_equal(incar.data["LCHARG"    ], ".TRUE.")
    assert_equal(incar.data["ISMEAR"    ], "0")
    assert_equal(incar.data["SIGMA"     ], "0.1")
    assert_equal(incar.data["IALGO"     ], "38")
    assert_equal(incar.data["LREAL"     ], "Auto")
    assert_equal(incar.data["NGX"       ], "36")
    assert_equal(incar.data["NGY"       ], "36")
    assert_equal(incar.data["NGZ"       ], "42")

    incar = VaspUtils::Incar.load_file "test/incar/INCAR.01"
    assert_equal(incar.data["SYSTEM" ], "Untitled")
    assert_equal(incar.data["PREC"   ], "High")
    assert_equal(incar.data["IBRION" ], "2")
    assert_equal(incar.data["NSW"    ], "0")
    assert_equal(incar.data["ISIF"   ], "2")
    assert_equal(incar.data["ENCUT"  ], "400")
    assert_equal(incar.data["NELM"   ], "60")
    assert_equal(incar.data["NELMIN" ], "2")
    assert_equal(incar.data["EDIFF"  ], "1.0e-05")
    assert_equal(incar.data["EDIFFG" ], "-0.02")
    assert_equal(incar.data["VOSKOWN"], "1")
    assert_equal(incar.data["NBLOCK" ], "1")
    assert_equal(incar.data["ISPIN"  ], "1")
    assert_equal(incar.data["INIWAV" ], "1")
    assert_equal(incar.data["ISTART" ], "1")
    assert_equal(incar.data["ICHARG" ], "1")
    assert_equal(incar.data["LWAVE"  ], ".TRUE.")
    assert_equal(incar.data["LCHARG" ], ".TRUE.")
    assert_equal(incar.data["ISMEAR" ], "0")
    assert_equal(incar.data["SIGMA"  ], "0.1")
    assert_equal(incar.data["IALGO"  ], "38")
    assert_equal(incar.data["LREAL"  ], "Auto")
    assert_equal(incar.data["NGX"    ], "36")
    assert_equal(incar.data["NGY"    ], "36")
    assert_equal(incar.data["NGZ"    ], "42")

    # not exist
    assert_raise(Errno::ENOENT){VaspUtils::Incar.load_file("")}
  end

  def test_dump
    data = {
      "SYSTEM" => "dummy",
      "PREC"   => "High",
      "ENCUT"  => "400",
      "EDIFF"  => "1.0e-05",
      "LREAL"  => ".TRUE.",
     }
    incar = VaspUtils::Incar.new( data)

    correct = [
      "SYSTEM = dummy",
      "PREC = High",
      "ENCUT = 400",
      "EDIFF = 1.0e-05",
      "LREAL = .TRUE.",
    ].join("\n")
    assert_equal( correct, incar.dump )

    assert_equal( correct, incar.dump(nil))

    outfile = "test/incar/tmp.incar"
    FileUtils.rm outfile if File.exist? outfile
    File.open(outfile, "w") { |io| incar.dump(io) }
    assert_equal( correct, File.open(outfile).read)
    FileUtils.rm outfile if File.exist? outfile
  end
end

