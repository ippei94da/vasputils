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
end

