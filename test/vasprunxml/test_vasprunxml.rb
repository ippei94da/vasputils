#! /usr/bin/env ruby
# coding: utf-8

require "helper"

class TC_VasprunXml < Test::Unit::TestCase
  def setup
    @v00 = VaspUtils::VasprunXml.load_file('test/vasprunxml/singlepoint.xml')
    @v01 = VaspUtils::VasprunXml.load_file('test/vasprunxml/geomopt.xml')
    @v02 = VaspUtils::VasprunXml.load_file('test/vasprunxml/dos.xml')
  end

  def test_load_file
    correct = [
      [ 327.28361242,   -291.24674632,      0.00000000],
      [-291.24674632,    327.28361242,      0.00000000],
      [   0.00000000,      0.00000000,     28.53476763],
    ]
    assert_equal(correct, @v00.stress)

    correct = [
      [-1.90067153,     -0.00000000,     -0.00000000],
      [ 0.00000000,     -1.90067153,      0.00000000],
      [-0.00000000,      0.00000000,     -1.90067153],
    ]
    assert_equal(correct, @v01.stress)
  end

  def test_bases
    correct = [
      [ [-1.69543387, -1.69543387, 1.69543387],
        [-1.69543387, 1.69543387, -1.69543387],
        [1.69543387, -1.69543387, -1.69543387]],
      [ [-1.62179317, -1.62179317, 1.62179317],
        [-1.62179317, 1.62179317, -1.62179317],
        [1.62179317, -1.62179317, -1.62179317]],
      [ [-1.51067861, -1.51067861, 1.51067861],
        [-1.51067861, 1.51067861, -1.51067861],
        [1.51067861, -1.51067861, -1.51067861]],
      [ [-1.4842561, -1.4842561, 1.4842561],
        [-1.4842561, 1.4842561, -1.4842561],
        [1.4842561, -1.4842561, -1.4842561]],
      [ [-1.49234629, -1.49234629, 1.49234629],
        [-1.49234629, 1.49234629, -1.49234629],
        [1.49234629, -1.49234629, -1.49234629]]
    ]
    assert_equal(correct, @v01.bases)
  end

  def test_positions_list
    correct = [
      [[0.0, 0.0, 0.0]],
      [[0.0, 0.0, 0.0]],
      [[0.0, 0.0, 0.0]],
      [[0.0, 0.0, 0.0]],
      [[0.0, 0.0, 0.0]]
    ]
    assert_equal(correct, @v01.positions_list)
  end

  def test_nums_elements
    assert_equal([1], @v01.nums_elements)
  end

  def test_elements
    assert_equal(['Li'], @v01.elements)
  end

  def test_fermi_energy
    assert_equal( 3.78039662, @v00.fermi_energy)
    assert_equal(-3.28068319, @v01.fermi_energy)
    assert_equal(6.07577117, @v02.fermi_energy)
  end

  def test_num_atoms
    assert_equal(4, @v00.num_atoms)
    assert_equal(1, @v01.num_atoms)
    assert_equal(2, @v02.num_atoms)

    assert_equal(4, @v00.num_ions)
  end

  def test_num_spins
    assert_equal(2, @v00.num_spins)
    assert_equal(1, @v01.num_spins)
    assert_equal(2, @v02.num_spins)
  end

  def test_total_dos
    results = @v02.total_dos(1)
    assert_equal([-40.0000, 0.0000, 0.0000], results[0])
    assert_equal([  0.0000, 0.0615, 1.7078], results[400])
    assert_equal([30.0000, 0.0000, 20.0000], results[-1])

    results = @v02.total_dos(2)
    assert_equal([-40.0000, 0.0000, 0.0000], results[0])
    assert_equal([  0.0000, 0.4175, 1.4531], results[400])
    assert_equal([30.0000, 0.0000, 20.0000], results[-1])

    assert_raise(VaspUtils::VasprunXml::IllegalArgumentError){ @v02.total_dos(3)}
    assert_raise(VaspUtils::VasprunXml::IllegalArgumentError){ @v01.total_dos(2)}
  end

  def test_total_dos_labels
    results = @v02.total_dos_labels
    corrects = [ 'energy', 'total', 'integrated' ]
    assert_equal(corrects, results)
  end

  def test_partial_dos_labels
    results = @v02.partial_dos_labels
    corrects = %w( energy s py pz px dxy dyz dz2 dxz dx2 )
    assert_equal(corrects, results)

    xml = VaspUtils::VasprunXml.load_file('test/vasprunxml/La.xml')
    results = xml.partial_dos_labels
    corrects = %w( energy s py pz px dxy dyz dz2 dxz dx2 f-3 f-2 f-1 f0 f1 f2 f3 )
    assert_equal(corrects, results)
  end

  def test_partial_dos
    results = @v02.partial_dos(1, 1)
    assert_equal([-40.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], results[0])
    assert_equal([
      0.0000, 0.0044, 0.0002, 0.0004, 0.0010,
      0.0000, 0.0000, 0.0000, 0.0000, 0.0000
    ], results[400])
    assert_equal([ 30.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], results[-1])

    results = @v02.partial_dos(2, 2)
    error = VaspUtils::VasprunXml::IllegalArgumentError
    assert_nothing_raised{ @v00.partial_dos(4, 1)}
    assert_raise(error){ @v00.partial_dos(5, 1)}
  end

  def test_calculation_energies
    results = @v01.calculation_energies
    assert_equal(5  , results.size)
    assert_equal(-4.21361453, results[0])
    assert_equal(-4.31607186, results[1])
    assert_equal(-4.39832854, results[2])
    assert_equal(-4.40043741, results[3])
    assert_equal(-4.40063677, results[4])
  end

  def test_calculation_basis
    v = VaspUtils::VasprunXml.load_file('test/vasprunxml/P-1.xml')
    results = v.calculation_basis
    assert_equal(100, results.size)
    assert_equal(
      [ [  5.46899986,  0.00000000,  0.00000000],
        [ -1.74915164,  9.50235270,  0.00000000],
        [ -2.23197985, -1.92643023, 14.02443236],
      ],
      results[0]
    )
    assert_equal(
      [ [  5.40956519, -0.00945616, -0.00482282],
        [ -1.74657312,  9.66179824, -0.01002973],
        [ -2.21676384, -1.97136374, 14.19879844],
      ],
      results[1]
    )
    assert_equal(
      [ [  4.47641358, -0.16679058,  0.40905180],
        [ -1.81434021, 10.68263862, -0.18256841],
        [ -0.18061392, -2.30429722, 15.63276550],
      ],
      results[99]
    )
  end

  def test_elements
    assert_equal( ["Ag", "Ag", "I ", "I "], @v00.elements)
  end

  def test_calculation_cells
    v = VaspUtils::VasprunXml.load_file('test/vasprunxml/P-1.xml')
    results = v.calculation_cells
    assert_equal(100, results.size)
    assert_equal(CrystalCell::Cell, results[0].class)
    #pp results
  end



end

