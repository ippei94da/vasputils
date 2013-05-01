#! /usr/bin/ruby -W

require "helper"
require "test/unit"
require "stringio"

require "rubygems"
#gem "crystalcell"
require "crystalcell"

class TC_Poscar < Test::Unit::TestCase
  $tolerance = 10 ** (-10)

  def test_dump
    # 例外ケース
    axes = CrystalCell::LatticeAxes.new( [
      [1.0, 0.0, 0.0 ],
      [0.0, 1.0, 0.0 ],
      [0.0, 0.0, 1.0 ],
      ])
    atoms = [
      CrystalCell::Atom.new(0, [0.1, 0.2, 0.3]),
      CrystalCell::Atom.new(1, [0.2, 0.3, 0.4]),
      CrystalCell::Atom.new(0, [0.3, 0.4, 0.5]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    io = StringIO.new
    assert_raises(VaspUtils::Poscar::ElementMismatchError){
      VaspUtils::Poscar.dump(cell, [0,1,2], io)}

    # 生成
    axes = CrystalCell::LatticeAxes.new( [
      [1.0, 0.0, 0.0 ],
      [0.0, 1.0, 0.0 ],
      [0.0, 0.0, 1.0 ],
      ])
    atoms = [
      CrystalCell::Atom.new(0, [0.1, 0.2, 0.3]),
      CrystalCell::Atom.new(1, [0.2, 0.3, 0.4]),
      CrystalCell::Atom.new(0, [0.3, 0.4, 0.5]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    io = StringIO.new
    VaspUtils::Poscar.dump(cell, [0,1], io, 4)
    io.rewind
    corrects = [
      "test\n",
      "1.0\n",
      "   1.000000000000000   0.000000000000000   0.000000000000000\n",
      "   0.000000000000000   1.000000000000000   0.000000000000000\n",
      "   0.000000000000000   0.000000000000000   1.000000000000000\n",
      "2 1\n",
      "Direct\n",
      "   0.100000000000000   0.200000000000000   0.300000000000000\n",
      "   0.300000000000000   0.400000000000000   0.500000000000000\n",
      "   0.200000000000000   0.300000000000000   0.400000000000000\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)

    # vasp 4
    atoms = [
      CrystalCell::Atom.new(0, [0.1, 0.2, 0.3], "atom0", [false, true , true ]),
      CrystalCell::Atom.new(1, [0.2, 0.3, 0.4], "atom1", [false, false, true ]),
      CrystalCell::Atom.new(0, [0.3, 0.4, 0.5], "atom2", [false, false, false]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    io = StringIO.new
    VaspUtils::Poscar.dump(cell, [0,1], io, 4)
    io.rewind
    corrects = [
      "test\n",
      "1.0\n",
      "   1.000000000000000   0.000000000000000   0.000000000000000\n",
      "   0.000000000000000   1.000000000000000   0.000000000000000\n",
      "   0.000000000000000   0.000000000000000   1.000000000000000\n",
      "2 1\n",
      "Selective dynamics\n",
      "Direct\n",
      "   0.100000000000000   0.200000000000000   0.300000000000000 F T T\n",
      "   0.300000000000000   0.400000000000000   0.500000000000000 F F F\n",
      "   0.200000000000000   0.300000000000000   0.400000000000000 F F T\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)

    atoms = [
      CrystalCell::Atom.new(0, [0.1, 0.2, 0.3], "atom0", [false, true , true ]),
      CrystalCell::Atom.new(1, [0.2, 0.3, 0.4], "atom1", [false, false, true ]),
      CrystalCell::Atom.new(0, [0.3, 0.4, 0.5], "atom2", [false, false, false]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    io = StringIO.new
    VaspUtils::Poscar.dump(cell, [0,1], io, 4)
    io.rewind
    corrects = [
      "test\n",
      "1.0\n",
      "   1.000000000000000   0.000000000000000   0.000000000000000\n",
      "   0.000000000000000   1.000000000000000   0.000000000000000\n",
      "   0.000000000000000   0.000000000000000   1.000000000000000\n",
      "2 1\n",
      "Selective dynamics\n",
      "Direct\n",
      "   0.100000000000000   0.200000000000000   0.300000000000000 F T T\n",
      "   0.300000000000000   0.400000000000000   0.500000000000000 F F F\n",
      "   0.200000000000000   0.300000000000000   0.400000000000000 F F T\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)
    # vasp 5
    atoms = [
      CrystalCell::Atom.new("Li", [0.1, 0.2, 0.3], "atom0", [false, true , true ]),
      CrystalCell::Atom.new("O" , [0.2, 0.3, 0.4], "atom1", [false, false, true ]),
      CrystalCell::Atom.new("Li", [0.3, 0.4, 0.5], "atom2", [false, false, false]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    io = StringIO.new
    VaspUtils::Poscar.dump(cell, ["Li", "O"], io, 5)
    io.rewind
    corrects = [
      "test\n",
      "1.0\n",
      "   1.000000000000000   0.000000000000000   0.000000000000000\n",
      "   0.000000000000000   1.000000000000000   0.000000000000000\n",
      "   0.000000000000000   0.000000000000000   1.000000000000000\n",
      "Li O\n",
      "2 1\n",
      "Selective dynamics\n",
      "Direct\n",
      "   0.100000000000000   0.200000000000000   0.300000000000000 F T T\n",
      "   0.300000000000000   0.400000000000000   0.500000000000000 F F F\n",
      "   0.200000000000000   0.300000000000000   0.400000000000000 F F T\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)

  end

  def test_parse
    io = StringIO.new
    assert_raises(VaspUtils::Poscar::ParseError){ VaspUtils::Poscar.parse(io) }

    # vasp 4 style
    io = StringIO.new
    io.puts "sample0"
    io.puts "1.0"
    io.puts "    1.0  0.0  0.0"
    io.puts "    0.0  1.0  0.0"
    io.puts "    0.0  0.0  1.0"
    io.puts " 1 1 1"
    io.puts "Direct"
    io.puts "    0.0  0.0  0.0  #Li-001"
    io.puts "    0.5  0.0  0.0  #Ge-002"
    io.puts "    0.5  0.5  0.0  #O--003"
    io.rewind
    cell = VaspUtils::Poscar.parse(io)
    assert_equal("sample0", cell.comment)
    assert_equal(
      CrystalCell::LatticeAxes.new( [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ]),
      cell.axes
    )
    assert_equal(
      CrystalCell::Atom.new(0, [0.0, 0.0, 0.0], "#Li-001"), cell.atoms[0])
    assert_equal(
      CrystalCell::Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002"), cell.atoms[1])
    assert_equal(
      CrystalCell::Atom.new(2, [0.5, 0.5, 0.0], "#O--003"), cell.atoms[2])

    # vasp 4 style and selective dynamics
    io = StringIO.new
    io.puts "sample1"
    io.puts "2.0"
    io.puts "    1.0  0.0  0.0"
    io.puts "    0.0  1.0  0.0"
    io.puts "    0.0  0.0  1.0"
    io.puts " 1 1 2"
    io.puts "Selective dynamics"
    io.puts "Direct"
    io.puts "    0.0  0.0  0.0  F F F #Li-001"
    io.puts "    0.5  0.0  0.0  F T F #Ge-002"
    io.puts "    0.5  0.5  0.0  T T T #O--003"
    io.puts "    0.5  0.5  0.5  T T T #O--004"
    io.rewind
    cell = VaspUtils::Poscar.parse(io)
    assert_equal("sample1", cell.comment)
    assert_equal(
      CrystalCell::LatticeAxes.new( [
        [2.0, 0.0, 0.0 ],
        [0.0, 2.0, 0.0 ],
        [0.0, 0.0, 2.0 ],
      ]),
      cell.axes
    )
    assert_equal(
      CrystalCell::Atom.new(0, [0.0, 0.0, 0.0], "#Li-001", [false, false, false]),
      cell.atoms[0])
    assert_equal(
      CrystalCell::Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002", [false, true , false]),
      cell.atoms[1])
    assert_equal(
      CrystalCell::Atom.new(2, [0.5, 0.5, 0.0], "#O--003", [true, true, true]),
      cell.atoms[2])
    assert_equal(
      CrystalCell::Atom.new(2, [0.5, 0.5, 0.5], "#O--004", [true, true, true]),
      cell.atoms[3])

    # vasp 5 style
    io = StringIO.new
    io.puts "sample0"
    io.puts "1.0"
    io.puts "    1.0  0.0  0.0"
    io.puts "    0.0  1.0  0.0"
    io.puts "    0.0  0.0  1.0"
    io.puts " Li Ge O"
    io.puts " 1  1  1"
    io.puts "Direct"
    io.puts "    0.0  0.0  0.0  #Li-001"
    io.puts "    0.5  0.0  0.0  #Ge-002"
    io.puts "    0.5  0.5  0.0  #O--003"
    io.rewind
    cell = VaspUtils::Poscar.parse(io)
    assert_equal("sample0", cell.comment)
    assert_equal(
      CrystalCell::LatticeAxes.new( [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ]),
      cell.axes
    )
    assert_equal(
      CrystalCell::Atom.new("Li", [0.0, 0.0, 0.0], "#Li-001"), cell.atoms[0])
    assert_equal(
      CrystalCell::Atom.new("Ge", [0.5, 0.0, 0.0], "#Ge-002"), cell.atoms[1])
    assert_equal(
      CrystalCell::Atom.new("O", [0.5, 0.5, 0.0], "#O--003"), cell.atoms[2])
  end

  def test_load_file
    cell = VaspUtils::Poscar.load_file("test/poscar/POSCAR.4-0")
    assert_equal("sample0", cell.comment)
    assert_equal(
      CrystalCell::LatticeAxes.new( [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ]),
      cell.axes
    )
    assert_equal(
      CrystalCell::Atom.new(0, [0.0, 0.0, 0.0], "#Li-001"), cell.atoms[0])
    assert_equal(
      CrystalCell::Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002"), cell.atoms[1])
    assert_equal(
      CrystalCell::Atom.new(2, [0.5, 0.5, 0.0], "#O--003"), cell.atoms[2])


    assert_raise(VaspUtils::Poscar::ParseError) {
      VaspUtils::Poscar.load_file("test/poscar/NOT_POSCAR")
    }
  end
end
