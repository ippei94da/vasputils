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
    assert_equal(-4.21361453, results[0])
    assert_equal(-4.31607186, results[1])
    assert_equal(-4.39832854, results[2])
    assert_equal(-4.40043741, results[3])
    assert_equal(-4.40063677, results[4])
  end

  #487:   <i name="e_fr_energy">     -4.21361453 </i>
  #584:   <i name="e_fr_energy">     -4.31607186 </i>
  #690:   <i name="e_fr_energy">     -4.39832854 </i>
  #778:   <i name="e_fr_energy">     -4.40043741 </i>
  #866:   <i name="e_fr_energy">     -4.40063677 </i>



end

