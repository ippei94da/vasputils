#! /usr/bin/ruby -W

require "helper"
require "test/unit"
require "stringio"

require "rubygems"
require "crystalcell"

class TC_Poscar < Test::Unit::TestCase
    $tolerance = 10 ** (-10)
    def setup
        hash = {
            :comment => 'p00',
            :scale   => 1.0,
            :axes    => [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            :elements           => %w(Li Ge O),
            :nums_elements      => [1,1,2],
            :selective_dynamics => false,
            :direct             => true,
            :positions          => [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
                [0.5,  0.5,  0.5],
            ]
        }
        @p00 = VaspUtils::Poscar.new(hash)
    end


    def test_initialize
        hash = {
            :comment => 'sample0',
            :scale   => 1.0,
            :axes    => [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            :elements           => %w(Li Ge O),
            :nums_elements      => [1,1,2],
            :selective_dynamics => false,
            :direct             => true,
            :positions          => [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
            ]
        }
        poscar = VaspUtils::Poscar.new(hash)

        assert_equal("sample0", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_equal(
            [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            poscar.axes
        )
        assert_equal(%w(Li Ge O), poscar.elements)
        assert_equal([1,1,2], poscar.nums_elements)
        assert_equal(true, poscar.direct)
        assert_equal(
            [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
            ],
            poscar.positions
        )

        assert_raise(VaspUtils::Poscar::ParseError) {
            VaspUtils::Poscar.load_file("test/poscar/NOT_POSCAR")
        }
    end

    def test_load_file
        poscar = VaspUtils::Poscar.load_file("test/poscar/POSCAR.5-0")
        assert_equal("sample0", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_equal(
            [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            poscar.axes
        )
        assert_equal(%w(Li Ge O), poscar.elements)
        assert_equal([1,1,1], poscar.nums_elements)
        assert_equal(false, poscar.selective_dynamics)
        assert_equal(true, poscar.direct)
        assert_equal(
            [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
            ],
            poscar.positions
        )


        poscar = VaspUtils::Poscar.load_file("test/poscar/POSCAR.5-selectivedynamics")
        assert_equal("sample0", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_equal(
            [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            poscar.axes
        )
        assert_equal(%w(Li Ge O), poscar.elements)
        assert_equal([1,1,2], poscar.nums_elements)
        assert_equal(
            [
                [false, false, false],
                [false, true , false],
                [true , true , true ],
                [true , true , true ],
            ],
            poscar.selective_dynamics
        )

        assert_equal(true, poscar.direct)
        assert_equal(
            [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
                [0.5,  0.5,  0.5],
            ],
            poscar.positions
        )


        poscar = VaspUtils::Poscar.load_file("test/poscar/POSCAR.4-0")
        assert_equal("sample0", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_equal(
            [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            poscar.axes
        )
        assert_equal(nil, poscar.elements)
        assert_equal([1,1,1], poscar.nums_elements)
        assert_equal(false, poscar.selective_dynamics)
        assert_equal(true, poscar.direct)
        assert_equal(
            [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
            ],
            poscar.positions
        )


        assert_raise(VaspUtils::Poscar::ParseError) {
            VaspUtils::Poscar.load_file("test/poscar/NOT_POSCAR")
        }
    end

    def test_load_cell
        axes = CrystalCell::LatticeAxes.new( [
            [1.0, 0.0, 0.0 ],
            [0.0, 1.0, 0.0 ],
            [0.0, 0.0, 1.0 ],
            ])
        atoms = [
            CrystalCell::Atom.new("Li", [0.1, 0.2, 0.3], "atom0", [false, true , true ]),
            CrystalCell::Atom.new("O" , [0.2, 0.3, 0.4], "atom1", [false, false, true ]),
            CrystalCell::Atom.new("Li", [0.3, 0.4, 0.5], "atom2", [false, false, false]),
        ]
        cell = CrystalCell::Cell.new(axes, atoms)
        cell.comment = "test"
        poscar = VaspUtils::Poscar.load_cell(cell)
        #
        assert_equal("test", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_in_delta(1.0, poscar.axes[0][0], $tolerance)
        assert_in_delta(0.0, poscar.axes[0][1], $tolerance)
        assert_in_delta(0.0, poscar.axes[0][2], $tolerance)
        assert_in_delta(0.0, poscar.axes[1][0], $tolerance)
        assert_in_delta(1.0, poscar.axes[1][1], $tolerance)
        assert_in_delta(0.0, poscar.axes[1][2], $tolerance)
        assert_in_delta(0.0, poscar.axes[2][0], $tolerance)
        assert_in_delta(0.0, poscar.axes[2][1], $tolerance)
        assert_in_delta(1.0, poscar.axes[2][2], $tolerance)
        assert_equal(%w(Li O), poscar.elements)
        assert_equal([2,1], poscar.nums_elements)
        assert_equal(
            [
                [false, true , true ], 
                [false, false, false], 
                [false, false, true ], 
            ],
            poscar.selective_dynamics
        )

        assert_equal(true, poscar.direct)
        assert_in_delta(0.1, poscar.positions[0][0], $tolerance)
        assert_in_delta(0.2, poscar.positions[0][1], $tolerance)
        assert_in_delta(0.3, poscar.positions[0][2], $tolerance)
        assert_in_delta(0.3, poscar.positions[1][0], $tolerance)
        assert_in_delta(0.4, poscar.positions[1][1], $tolerance)
        assert_in_delta(0.5, poscar.positions[1][2], $tolerance)
        assert_in_delta(0.2, poscar.positions[2][0], $tolerance)
        assert_in_delta(0.3, poscar.positions[2][1], $tolerance)
        assert_in_delta(0.4, poscar.positions[2][2], $tolerance)
    end

    def test_dump
        # vasp 5
        io = StringIO.new
        @p00.dump(io)

        io.rewind
        corrects = [
            "p00\n",
            "1.0\n",
            "   1.000000000000000     0.000000000000000     0.000000000000000\n",
            "   0.000000000000000     1.000000000000000     0.000000000000000\n",
            "   0.000000000000000     0.000000000000000     1.000000000000000\n",
            "Li Ge O\n",
            "1 1 2\n",
            "Direct\n",
            "     0.000000000000000     0.000000000000000     0.000000000000000\n",
            "     0.500000000000000     0.000000000000000     0.000000000000000\n",
            "     0.500000000000000     0.500000000000000     0.000000000000000\n",
            "     0.500000000000000     0.500000000000000     0.500000000000000\n",
        ]
        lines = io.readlines
        corrects.each_with_index do |cor, index|
            assert_equal(cor, lines[index], "line: #{index}")
        end
        assert_equal(corrects.size, lines.size)
    end

    #def test_self_dump
    #    # vasp 5
    #    io = StringIO.new
    #    @p00.dump(io)

    #    VaspUtils::Poscar.dump(cell, ["Li", "O"], io, 5)
    #    io.rewind
    #    corrects = [
    #        "p00\n",
    #        "1.0\n",
    #        "   1.000000000000000     0.000000000000000     0.000000000000000\n",
    #        "   0.000000000000000     1.000000000000000     0.000000000000000\n",
    #        "   0.000000000000000     0.000000000000000     1.000000000000000\n",
    #        "Li Ge O\n",
    #        "1 1 2\n",
    #        "Direct\n",
    #        "     0.000000000000000     0.000000000000000     0.000000000000000\n",
    #        "     0.500000000000000     0.000000000000000     0.000000000000000\n",
    #        "     0.500000000000000     0.500000000000000     0.000000000000000\n",
    #    ]
    #    lines = io.readlines
    #    corrects.each_with_index do |cor, index|
    #        assert_equal(cor, lines[index], "line: #{index}")
    #    end
    #    assert_equal(corrects.size, lines.size)
    #end

    def test_parse
        #io = StringIO.new
        #assert_raises(VaspUtils::Poscar::ParseError){ VaspUtils::Poscar.parse(io) }

        # vasp 5 style
        io = File.open('test/poscar/POSCAR.5-0', 'r')
        poscar = VaspUtils::Poscar.parse(io)

        assert_equal("sample0", poscar.comment)
        assert_equal(1.0, poscar.scale)
        assert_equal(
            [
                [1.0, 0.0, 0.0 ],
                [0.0, 1.0, 0.0 ],
                [0.0, 0.0, 1.0 ],
            ],
            poscar.axes
        )
        assert_equal(%w(Li Ge O), poscar.elements)
        assert_equal([1, 1, 1], poscar.nums_elements)
        assert_equal(false, poscar.selective_dynamics)
        assert_equal(true, poscar.direct)
        assert_equal(
            [
                [0.0,  0.0,  0.0],
                [0.5,  0.0,  0.0],
                [0.5,  0.5,  0.0],
            ],
            poscar.positions
        )
    end

    def test_to_cell
        result = @p00.to_cell
        axes = CrystalCell::LatticeAxes.new( [
            [1.0, 0.0, 0.0 ],
            [0.0, 1.0, 0.0 ],
            [0.0, 0.0, 1.0 ],
            ])
        atoms = [
            CrystalCell::Atom.new("Li", [0.0, 0.0, 0.0], nil, nil),
            CrystalCell::Atom.new("Ge", [0.5, 0.0, 0.0], nil, nil),
            CrystalCell::Atom.new("O" , [0.5, 0.5, 0.0], nil, nil),
            CrystalCell::Atom.new("O" , [0.5, 0.5, 0.5], nil, nil),
        ]
        correct = CrystalCell::Cell.new(axes, atoms)
        assert_equal(correct.axes, result.axes)
        assert_equal(correct.atoms[0], result.atoms[0])
        assert_equal(correct.atoms[1], result.atoms[1])
        assert_equal(correct.atoms[2], result.atoms[2])
        assert_equal(correct.atoms[3], result.atoms[3])
        assert_equal(correct.atoms.size, result.atoms.size)
    end

    def test_accessor #reader
        assert_equal('p00', @p00.comment           )
        assert_equal(1.0, @p00.scale             )
        axes    = [
            [1.0, 0.0, 0.0 ],
            [0.0, 1.0, 0.0 ],
            [0.0, 0.0, 1.0 ],
        ]
        assert_equal(axes,        @p00.axes              )
        assert_equal(%w(Li Ge O), @p00.elements          )
        assert_equal([1,1,2],     @p00.nums_elements     )
        assert_equal(false,       @p00.selective_dynamics)
        assert_equal(true,        @p00.direct            )
        positions          = [
            [0.0,  0.0,  0.0],
            [0.5,  0.0,  0.0],
            [0.5,  0.5,  0.0],
            [0.5,  0.5,  0.5],
        ]
        assert_equal(positions, @p00.positions             )
    end
end

