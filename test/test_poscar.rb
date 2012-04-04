#! /usr/bin/ruby -W

require "test/unit"
require "stringio"
require "vasputils/poscar.rb"

require "rubygems"
gem "mageo"
require "mageo/vector3dinternal.rb"
gem "crystalcell"
require "crystalcell/cell.rb"

class TC_Poscar < Test::Unit::TestCase
	$tolerance = 10 ** (-10)

	def test_dump
		# 例外ケース
		axes = LatticeAxes.new( [
			[1.0, 0.0, 0.0 ],
			[0.0, 1.0, 0.0 ],
			[0.0, 0.0, 1.0 ],
			])
		atoms = [
			Atom.new(0, [0.1, 0.2, 0.3]),
			Atom.new(1, [0.2, 0.3, 0.4]),
			Atom.new(0, [0.3, 0.4, 0.5]),
		]
		cell = Cell.new(axes, atoms)
		cell.comment = "test"
		io = StringIO.new
		assert_raises(Poscar::ElementMismatchError){
			Poscar.dump(cell, [0,1,2], io)}

		# 生成
		axes = LatticeAxes.new( [
			[1.0, 0.0, 0.0 ],
			[0.0, 1.0, 0.0 ],
			[0.0, 0.0, 1.0 ],
			])
		atoms = [
			Atom.new(0, [0.1, 0.2, 0.3]),
			Atom.new(1, [0.2, 0.3, 0.4]),
			Atom.new(0, [0.3, 0.4, 0.5]),
		]
		cell = Cell.new(axes, atoms)
		cell.comment = "test"
		io = StringIO.new
		Poscar.dump(cell, [0,1], io)
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

		atoms = [
			Atom.new(0, [0.1, 0.2, 0.3], "atom0", [false, true , true ]),
			Atom.new(1, [0.2, 0.3, 0.4], "atom1", [false, false, true ]),
			Atom.new(0, [0.3, 0.4, 0.5], "atom2", [false, false, false]),
		]
		cell = Cell.new(axes, atoms)
		cell.comment = "test"
		io = StringIO.new
		Poscar.dump(cell, [0,1], io)
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
	end

	def test_parse
		io = StringIO.new
		assert_raises(Poscar::ParseError){ Poscar.parse(io) }

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
		cell = Poscar.parse(io)
		assert_equal("sample0", cell.comment)
		assert_equal(
			LatticeAxes.new( [
				[1.0, 0.0, 0.0 ],
				[0.0, 1.0, 0.0 ],
				[0.0, 0.0, 1.0 ],
			]),
			cell.axes
		)
		assert_equal(
			Atom.new(0, [0.0, 0.0, 0.0], "#Li-001"), cell.atoms[0])
		assert_equal(
			Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002"), cell.atoms[1])
		assert_equal(
			Atom.new(2, [0.5, 0.5, 0.0], "#O--003"), cell.atoms[2])

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
		cell = Poscar.parse(io)
		assert_equal("sample1", cell.comment)
		assert_equal(
			LatticeAxes.new( [
				[2.0, 0.0, 0.0 ],
				[0.0, 2.0, 0.0 ],
				[0.0, 0.0, 2.0 ],
			]),
			cell.axes
		)
		assert_equal(
			Atom.new(0, [0.0, 0.0, 0.0], "#Li-001", [false, false, false]),
			cell.atoms[0])
		assert_equal(
			Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002", [false, true , false]),
			cell.atoms[1])
		assert_equal(
			Atom.new(2, [0.5, 0.5, 0.0], "#O--003", [true, true, true]),
			cell.atoms[2])
		assert_equal(
			Atom.new(2, [0.5, 0.5, 0.5], "#O--004", [true, true, true]),
			cell.atoms[3])
	end

	def test_load_file
		cell = Poscar.load_file("test/poscar/POSCAR.00")
		assert_equal("sample0", cell.comment)
		assert_equal(
			LatticeAxes.new( [
				[1.0, 0.0, 0.0 ],
				[0.0, 1.0, 0.0 ],
				[0.0, 0.0, 1.0 ],
			]),
			cell.axes
		)
		assert_equal(
			Atom.new(0, [0.0, 0.0, 0.0], "#Li-001"), cell.atoms[0])
		assert_equal(
			Atom.new(1, [0.5, 0.0, 0.0], "#Ge-002"), cell.atoms[1])
		assert_equal(
			Atom.new(2, [0.5, 0.5, 0.0], "#O--003"), cell.atoms[2])

		#cell = Poscar.load_file("test/poscar/POSCAR.02")
		#assert_equal("sample0", cell.comment)
		#assert_in_delta( 7.1028554188641708, cell.axes[0][0], $tolerance)
		#assert_in_delta(-0.0000000169534433, cell.axes[0][1], $tolerance)
		#assert_in_delta(-0.0000000169534428, cell.axes[0][2], $tolerance)
		#assert_in_delta( 0.0000001136137521, cell.axes[1][0], $tolerance) 
		#assert_in_delta( 7.1028554188641725, cell.axes[1][1], $tolerance) 
		#assert_in_delta(-0.0000000169534433, cell.axes[1][2], $tolerance) 
		#assert_in_delta( 0.0000001136137521, cell.axes[2][0], $tolerance) 
		#assert_in_delta( 0.0000001136137521, cell.axes[2][1], $tolerance) 
		#assert_in_delta( 7.1028554188641725, cell.axes[2][2], $tolerance) 
		#assert_equal(0, cell.atoms[0].element)
		#assert_equal(0.0395891220708791, cell.atoms[0].position[0]) 
		#assert_equal(0.0395891220708791, cell.atoms[0].position[1])
		#assert_equal(0.0395891220708791, cell.atoms[0].position[2])

	end

	#def setup
	#	#@pp02 = Poscar.new("test/poscar/POSCAR.shirai")
	#end

end
