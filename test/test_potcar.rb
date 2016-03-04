#! /usr/bin/ruby

require "test/unit"
require "vasputils.rb"
require "vasputils/potcar.rb"
require "vasputils/setting.rb"


class VaspUtils::Potcar
  attr_accessor :elements, :enmaxes
end

class TC_Potcar < Test::Unit::TestCase

    def setup
        @p00 = VaspUtils::Potcar.new
        @p00.elements = [ "Li", "Ge", "O" ]
        @p00.enmaxes = [140.000, 173.807, 282.841 ]
    end


    def test_elements
        assert_equal([ "Li", "Ge", "O" ], @p00.elements)
    end

    def test_enmaxes
        assert_equal([140.000, 173.807, 282.841 ], @p00.enmaxes)
    end

    #def test_get_filename
    #    assert_equal("test/potcar/POTCAR", @p0.name)
    #    assert_equal("test/potcar/POTCAR.dummy", @p1.name)
    #    assert_equal("test/potcar/POTCAR.allElement", @p2.name)
    #end

    def test_loadfile
        p10 = VaspUtils::Potcar.load_file("test/potcar/POTCAR")
        assert_equal([ "Li", "Ge", "O" ], p10.elements)
        assert_equal([140.000, 173.807, 282.841 ], p10.enmaxes)

        p11 = VaspUtils::Potcar.load_file("test/potcar/POTCAR.dummy")
        assert_equal([ "Li", "Ge", "O" ], p11.elements)

        p12 = VaspUtils::Potcar.load_file("test/potcar/POTCAR.allElement")
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
        assert_equal( correct, p12.elements)
    end

end

