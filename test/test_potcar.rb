#! /usr/bin/ruby

require "test/unit"
require "vasputils/potcar.rb"

class TC_Potcar < Test::Unit::TestCase

	def setup
		@p0 = Potcar.load_file("test/potcar/POTCAR"           )
		@p1 = Potcar.load_file("test/potcar/POTCAR.dummy"     )
		@p2 = Potcar.load_file("test/potcar/POTCAR.allElement")
	end

	def test_get_filename
		assert_equal("test/potcar/POTCAR"           , @p0[:name])
		assert_equal("test/potcar/POTCAR.dummy"     , @p1[:name])
		assert_equal("test/potcar/POTCAR.allElement", @p2[:name])
	end

	def test_elements
		assert_equal([ "Li", "Ge", "O" ], @p0[:elements])
		assert_equal([ "Li", "Ge", "O" ], @p1[:elements])
		correct = [
			"Ac", "Ac", "Ag", "Al", "Al", "Ar", "As", "Au", "B", "B", "B", "Ba",
			"Be", "Be", "Bi", "Bi", "Br", "C", "C", "C", "Ca", "Ca", "Cd", "Ce",
			"Ce", "Cl", "Cl", "Co", "Cr", "Cr", "Cs", "Cu", "Cu", "Dy",
			"Er", "Er", "Eu", "Eu", "F", "F", "F", "Fe", "Fe", "Ga", "Ga", "Ga",
			"Gd", "Gd", "Ge", "Ge", "Ge", "H", "H", "H", "H", "H", "H", "He",
			"Hf", "Hf", "Hg", "Ho", "I", "In", "In", "Ir", "K", "K", "Kr",
			"La", "La", "Li", "Li", "Lu", "Lu", "Mg", "Mg", "Mn", "Mn",
			"Mo", "Mo", "N", "N", "N", "Na", "Na", "Na", "Nb", "Nb", "Nd", "Nd",
			"Ne", "Ni", "Ni", "Np", "Np", "O", "O", "O", "Os", "Os", "P", "P",
			"Pa", "Pa", "Pb", "Pb", "Pd", "Pd", "Pm", "Pm", "Pr", "Pr", "Pt",
			"Pu", "Pu", "Rb", "Rb", "Re", "Re", "Rh", "Rh", "Ru", "Ru", "S", "S",
			"Sb", "Sc", "Se", "Si", "Si", "Sm", "Sm", "Sn", "Sn", "Sr",
			"Ta", "Ta", "Tb", "Tc", "Tc", "Te", "Th", "Th", "Ti", "Ti", "Ti",
			"Tl", "Tl", "Tm", "Tm", "U", "U", "V", "V", "V", "W", "W", "X", "Y",
			"Yb", "Yb", "Zn", "Zr", "Zr"]
		assert_equal( correct, @p2[:elements])
	end

	#def test_self_elements
	#	assert_equal([ "Li", "Ge", "O" ], Potcar.elements( @p0 ))
	#	assert_equal([ "Li", "Ge", "O" ], Potcar.elements( @p1 ))
	#	correct = [
	#		"Ac", "Ac", "Ag", "Al", "Al", "Ar", "As", "Au", "B", "B", "B", "Ba",
	#		"Be", "Be", "Bi", "Bi", "Br", "C", "C", "C", "Ca", "Ca", "Cd", "Ce",
	#		"Ce", "Cl", "Cl", "Co", "Cr", "Cr", "Cs", "Cu", "Cu", "Dy",
	#		"Er", "Er", "Eu", "Eu", "F", "F", "F", "Fe", "Fe", "Ga", "Ga", "Ga",
	#		"Gd", "Gd", "Ge", "Ge", "Ge", "H", "H", "H", "H", "H", "H", "He",
	#		"Hf", "Hf", "Hg", "Ho", "I", "In", "In", "Ir", "K", "K", "Kr",
	#		"La", "La", "Li", "Li", "Lu", "Lu", "Mg", "Mg", "Mn", "Mn",
	#		"Mo", "Mo", "N", "N", "N", "Na", "Na", "Na", "Nb", "Nb", "Nd", "Nd",
	#		"Ne", "Ni", "Ni", "Np", "Np", "O", "O", "O", "Os", "Os", "P", "P",
	#		"Pa", "Pa", "Pb", "Pb", "Pd", "Pd", "Pm", "Pm", "Pr", "Pr", "Pt",
	#		"Pu", "Pu", "Rb", "Rb", "Re", "Re", "Rh", "Rh", "Ru", "Ru", "S", "S",
	#		"Sb", "Sc", "Se", "Si", "Si", "Sm", "Sm", "Sn", "Sn", "Sr",
	#		"Ta", "Ta", "Tb", "Tc", "Tc", "Te", "Th", "Th", "Ti", "Ti", "Ti",
	#		"Tl", "Tl", "Tm", "Tm", "U", "U", "V", "V", "V", "W", "W", "X", "Y",
	#		"Yb", "Yb", "Zn", "Zr", "Zr"]
	#	assert_equal( correct, Potcar.elements( @p2 ))
	#end

end

