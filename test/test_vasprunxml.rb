#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_VasprunXml < Test::Unit::TestCase
  def setup
    #@v00 = VaspUtils::VasprunXml.new
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

  def test_num_ions
    assert_equal(2, @v02.num_ions)
  end

  def test_num_spins
    assert_equal(2, @v00.num_spins)
    assert_equal(1, @v01.num_spins)
    assert_equal(2, @v02.num_spins)
  end

  def test_total_dos
    results = @v02.total_dos
    NEED_SPINS

    assert_equal([-40.0000, 0.0000, 0.0000], results[0])
    assert_equal([  0.0000, 0.0615, 1.7078], results[400])
    assert_equal([30.0000, 0.0000, 20.0000], results[-1])
  end

  def test_total_dos_labels
    results = @v02.total_dos_labels
    corrects = [ 'energy', 'total', 'integrated' ]
    assert_equal(corrects, results)
  end

  def test_partial_dos
    #pp @v01.total_dos
    #  partial
    #    array
    #      set
    #        ion
    #          spin
  end
end

