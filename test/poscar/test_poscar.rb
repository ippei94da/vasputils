#! /usr/bin/ruby -W

require "helper"
require "stringio"

class VaspUtils::Poscar
  public :merge_selective_dynamics, :periodic_nearest, :fill_true, :unite_elements
end

class TC_Poscar < Test::Unit::TestCase
  T = true
  F = false

  $tolerance = 10 ** (-10)
  def setup
    @p00 = VaspUtils::Poscar.new({
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
    })
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
        [F, F, F],
        [F, T, F],
        [T, T, T],
        [T, T, T],
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
      CrystalCell::Atom.new("Li", [0.1, 0.2, 0.3], "atom0", [F, T, T]),
      CrystalCell::Atom.new("O" , [0.2, 0.3, 0.4], "atom1", [F, F, T]),
      CrystalCell::Atom.new("Li", [0.3, 0.4, 0.5], "atom2", [F, F, F]),
    ]
    cell = CrystalCell::Cell.new(axes, atoms)
    cell.comment = "test"
    poscar = VaspUtils::Poscar.load_cell(cell)

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
      [ [F, T, T], [F, F, F], [F, F, T], ],
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
    ## vasp 5
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

    io = StringIO.new
    p01 = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Ge O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => [
        [true , true , true ],
        [true , true , false],
        [true , false, false],
        [false, false, false],
      ],
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.5,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
      ]
    })
    p01.dump(io)
    io.rewind
    corrects = [
      "p00\n",
      "1.0\n",
      "   1.000000000000000     0.000000000000000     0.000000000000000\n",
      "   0.000000000000000     1.000000000000000     0.000000000000000\n",
      "   0.000000000000000     0.000000000000000     1.000000000000000\n",
      "Li Ge O\n",
      "1 1 2\n",
      "Selective dynamics\n",
      "Direct\n",
      "     0.000000000000000     0.000000000000000     0.000000000000000 T T T\n",
      "     0.500000000000000     0.000000000000000     0.000000000000000 T T F\n",
      "     0.500000000000000     0.500000000000000     0.000000000000000 T F F\n",
      "     0.500000000000000     0.500000000000000     0.500000000000000 F F F\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)

    io = StringIO.new
    p01 = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Ge O),
      :nums_elements      => [1,2,2],
      :selective_dynamics => [
        [true , true , true ],
        [true , true , true ],
        [true , true , false],
        [true , false, false],
        [false, false, false],
      ],
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.1,  0.1,  0.1],
        [0.5,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
      ]
    })
    p01.dump(io)
    io.rewind
    corrects = [
      "p00\n",
      "1.0\n",
      "   1.000000000000000     0.000000000000000     0.000000000000000\n",
      "   0.000000000000000     1.000000000000000     0.000000000000000\n",
      "   0.000000000000000     0.000000000000000     1.000000000000000\n",
      "Li Ge O\n",
      "1 2 2\n",
      "Selective dynamics\n",
      "Direct\n",
      "     0.000000000000000     0.000000000000000     0.000000000000000 T T T\n",
      "     0.100000000000000     0.100000000000000     0.100000000000000 T T T\n",
      "     0.500000000000000     0.000000000000000     0.000000000000000 T T F\n",
      "     0.500000000000000     0.500000000000000     0.000000000000000 T F F\n",
      "     0.500000000000000     0.500000000000000     0.500000000000000 F F F\n",
    ]
    lines = io.readlines
    corrects.each_with_index do |cor, index|
      assert_equal(cor, lines[index], "line: #{index}")
    end
    assert_equal(corrects.size, lines.size)
  end

  def test_parse
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

    result = @p00.to_cell(CrystalCell::Povray::Cell)
    assert_equal(CrystalCell::Povray::Cell, result.class)
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

  def test_interpolate
    p01 = VaspUtils::Poscar.new( {
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 1.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Ge O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => false,
      :direct             => true,
      :positions          => [
        [0.2,  0.4,  0.6],
        [0.5,  0.2,  0.4],
        [0.5,  0.5,  0.2],
        [0.5,  0.5,  0.5],
      ]
    })
    correct = VaspUtils::Poscar.new({
      :comment => "Generated by interpolation of 0.25",
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.25 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Ge O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => [ [T, T, T], [T, T, T], [T, T, T], [T, T, T] ],
      :direct             => true,
      :positions          => [
        [0.05, 0.10, 0.15],
        [0.5,  0.05, 0.10],
        [0.5,  0.5,  0.05],
        [0.5,  0.5,  0.5],
      ]
    })
    result = VaspUtils::Poscar.interpolate(@p00, p01, 0.25)

    assert_equal(correct.comment, result.comment)
    assert_equal(correct.scale, result.scale)
    assert_equal(correct.axes, result.axes)
    assert_equal(correct.elements, result.elements)
    assert_equal(correct.nums_elements, result.nums_elements)
    assert_equal(correct.selective_dynamics, result.selective_dynamics)
    assert_equal(correct.direct, result.direct)
    assert_equal(correct.positions, result.positions)
    assert_equal(correct, result)

    result = @p00.interpolate( p01, 0.25)
    assert_equal(correct, result)

    correct = VaspUtils::Poscar.new({
      :comment => "Generated by interpolation of 0.25",
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.25 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Ge O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => [ [T, T, T], [T, T, T], [T, T, T], [T, T, T] ],
      :direct             => true,
      :positions          => [
        [0.05, 0.10, -0.1],
        [0.5,  0.05, 0.10],
        [0.5,  0.5,  0.05],
        [0.5,  0.5,  0.5],
      ]
    })

    assert_equal(correct, VaspUtils::Poscar.interpolate(@p00, p01, 0.25, true))

    #selective dynamics で AND をとる。
    #なければ全部 TRUE
    hash00 = {
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li O),
      :nums_elements      => [1,2],
      :selective_dynamics => [ [T, T, T], [T, T, F], [F, F, F], ],
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.1],
        [0.0,  0.2,  0.3],
        [0.4,  0.5,  0.6],
      ]
    }
    p00 = VaspUtils::Poscar.new(hash00)
    hash00[:selective_dynamics] = [
      [T, T, T],
      [F, T, T],
      [F, F, F],
    ]
    p01 = VaspUtils::Poscar.new(hash00)
    result = VaspUtils::Poscar.interpolate(p00, p01, 0.5)
    correct = VaspUtils::Poscar.new({
      :comment => "Generated by interpolation of 0.5",
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li O),
      :nums_elements      => [1,2],
      :selective_dynamics => [ [T, T, T], [F, T, F], [F, F, F]],
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.1],
        [0.0,  0.2,  0.3],
        [0.4,  0.5,  0.6],
      ]
    })
    assert_equal(correct, result)

    result = VaspUtils::Poscar.interpolate(p01, p00, 0.5)
    assert_equal(correct, result)
  end

  def test_equal
    p00 = VaspUtils::Poscar.new({
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
    })

    assert_equal(true, @p00 == p00)

    p00 = VaspUtils::Poscar.new({
      :comment => 'p01',
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
    })
    assert_equal(false, @p00 == p00)
  end

  def test_substitute
    p01 = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(Li Si O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => false,
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.5,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
      ]
    })
    result = @p00.substitute('Ge', 'Si')
    assert_equal(p01, result)

    setup
    result = @p00.substitute('Li', 'O')
    correct = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(O Ge),
      :nums_elements      => [3,1],
      :selective_dynamics => false,
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
        [0.5,  0.0,  0.0],
      ]
    })
    assert_equal(correct, result)
  end

  def test_unite_elements
    tmp = Marshal.load(Marshal.dump(@p00))
    tmp.unite_elements
    assert_equal(@p00, tmp)

    p01 = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(O Ge O),
      :nums_elements      => [1,1,2],
      :selective_dynamics => false,
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.5,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
      ]
    })
    p02 = VaspUtils::Poscar.new({
      :comment => 'p00',
      :scale   => 1.0,
      :axes    => [
        [1.0, 0.0, 0.0 ],
        [0.0, 1.0, 0.0 ],
        [0.0, 0.0, 1.0 ],
      ],
      :elements           => %w(O Ge),
      :nums_elements      => [3,1],
      :selective_dynamics => false,
      :direct             => true,
      :positions          => [
        [0.0,  0.0,  0.0],
        [0.5,  0.5,  0.0],
        [0.5,  0.5,  0.5],
        [0.5,  0.0,  0.0],
      ]
    })
    p01.unite_elements
    assert_equal(p02, p01)
  end

  def test_periodic_nearest
    corrects = [0.0, 0.0, -0.2]
    results =  @p00.periodic_nearest( [0.0, 0.0, 0.0], [0.0, 0.0, 0.8])
    3.times { |i| assert_in_delta(corrects[i], results[i], $tolerance) }

    corrects = [0.0, 0.0, 1.0]
    results =  @p00.periodic_nearest( [0.0, 0.0, 0.8], [0.0, 0.0, 0.0])
    3.times { |i| assert_in_delta(corrects[i], results[i], $tolerance) }

    corrects = [0.0, -0.2, -0.2]
    results =  @p00.periodic_nearest( [0.0, 0.0, 0.0], [0.0, 0.8, 0.8])
    3.times { |i| assert_in_delta(corrects[i], results[i], $tolerance) }

    corrects = [-0.2, -0.2, -0.2]
    results =  @p00.periodic_nearest( [0.0, 0.0, 0.0], [0.8, 0.8, 0.8])
    3.times { |i| assert_in_delta(corrects[i], results[i], $tolerance) }
  end

  def test_merge_selective_dynamics
    sd0 = [ [T, T, T], [T, T, F], [T, F, F], [F, F, F] ]
    sd1 = [ [T, T, T], [F, T, T], [F, F, T], [F, F, F] ]

    e01 = [ [T, T, T], [F, T, F], [F, F, F], [F, F, F] ]
    assert_equal( e01, @p00.merge_selective_dynamics(sd0, sd1))
    assert_equal( e01, @p00.merge_selective_dynamics(sd1, sd0))

    assert_equal(
      [ [T, T, T], [T, T, F], [T, F, F], [F, F, F] ],
      @p00.merge_selective_dynamics(sd0, F)
    )

    assert_equal(
      [ [T, T, T], [T, T, F], [T, F, F], [F, F, F] ],
      @p00.merge_selective_dynamics(F, sd0)
    )

    #はぬけがあったやつ。
    assert_equal(
      [ [F, F, F], [F, F, F], [F, F, T], [T, T, T] ],
      @p00.merge_selective_dynamics(
        [ [T, T, T], [T, T, T], [T, T, T], [T, T, T] ],
        [ [F, F, F], [F, F, F], [F, F] ],
      )
    )
  end

  def test_fill_true
    e00 = [ [T, T, T], [T, T, T], [T, T, T], [T, T, T] ]
    assert_equal(e00, @p00.fill_true(false))
    assert_equal(e00, 
      @p00.fill_true( [ [T, T, T], [T, T, T], [T, T]])
    )
  end
end

