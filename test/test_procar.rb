#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "vasputils.rb"
#require "pkg/klass.rb"
#
class VaspUtils::Procar
  public :projection
end

class TC_Procar < Test::Unit::TestCase
  def setup
    @p00 = VaspUtils::Procar.load_file("test/procar/Si2-k222-NBAND8-ISPIN2.PROCAR")
    @p01 = VaspUtils::Procar.load_file("test/procar/La.PROCAR")
  end

  def test_energies
    correct = [
      [-5.72406918, 1.39818264, 4.54489326, 4.54489326,
       7.18759475, 8.74432526, 8.74432526, 11.94041316],
      [-3.85979310, -1.03952109, 1.83993091, 3.13528844,
       6.82460808, 9.70841020, 10.87421242, 11.13140386],
      [-4.68323341, 2.43044440, 5.55330388, 5.55330388,
       8.26994506, 9.84168906, 9.84168906, 13.01171710],
      [-2.82249666, -0.00489068, 2.87902633, 4.16118261,
       7.90270675, 10.76948848, 11.94438791, 12.21350660],
    ]
    assert_equal(correct, @p00.energies)
  end

  def test_occupancies
    correct = [
      [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0]
    ]
    assert_equal(correct, @p00.occupancies)
  end

  def test_num_bands
    assert_equal(8, @p00.num_bands)
  end

  def test_num_kpoints
    assert_equal(2, @p00.num_kpoints)
  end

  def test_num_ions
    assert_equal(2, @p00.num_ions)
  end

  def test_weights
    assert_equal([0.25, 0.75, 0.25, 0.75], @p00.weights)
  end

  def test_f_orbital?
    assert_equal(false, @p00.f_orbital?)
    assert_equal(true , @p01.f_orbital?)
  end

  def test_projection
    corrects = [ 
      {:energy=>-5.72406918, :s=>0.075, :py=>0.001, :pz=>0.000, :px=>0.002,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=>-3.85979310, :s=>0.234, :py=>0.012, :pz=>0.006, :px=>0.003,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=>-1.03952109, :s=>0.189, :py=>0.024, :pz=>0.012, :px=>0.039,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=> 1.39818264, :s=>0.041, :py=>0.010, :pz=>0.005, :px=>0.029,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 1.83993091, :s=>0.030, :py=>0.045, :pz=>0.024, :px=>0.105,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=> 3.13528844, :s=>0.000, :py=>0.078, :pz=>0.156, :px=>0.000,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=> 4.54489326, :s=>0.000, :py=>0.007, :pz=>0.075, :px=>0.004,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 4.54489326, :s=>0.000, :py=>0.060, :pz=>0.002, :px=>0.025,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 6.82460808, :s=>0.072, :py=>0.042, :pz=>0.021, :px=>0.006,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=> 7.18759475, :s=>0.076, :py=>0.005, :pz=>0.002, :px=>0.014,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 8.74432526, :s=>0.000, :py=>0.000, :pz=>0.055, :px=>0.009,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 8.74432526, :s=>0.000, :py=>0.050, :pz=>0.002, :px=>0.012,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25},
      {:energy=> 9.7084102 , :s=>0.036, :py=>0.015, :pz=>0.009, :px=>0.099,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=>10.87421242, :s=>0.096, :py=>0.051, :pz=>0.024, :px=>0.120,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=>11.13140386, :s=>0.000, :py=>0.060, :pz=>0.123, :px=>0.000,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.75},
      {:energy=>11.94041316, :s=>0.059, :py=>0.019, :pz=>0.009, :px=>0.056,
       :dxy=>0.0, :dyz=>0.0, :dz2=>0.0, :dxz=>0.0, :dx2=>0.0, :weight=>0.25}
    ]
    results = @p00.projection([1, 2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i], results[i])
    end
  end

  def test_states
    #assert_equal([0.25, 0.75, 0.25, 0.75], @p00.weights)
    #correct = 
    #[[[[0.075,    0.001, 0.0,   0.002, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.075,   0.001, 0.0,   0.002, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.041,  0.01,  0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.041,   0.01,  0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.007, 0.075, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.007, 0.075, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.06,  0.002, 0.025, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.06,  0.002, 0.025, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.076,  0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.076,   0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.05,  0.002, 0.012, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.05,  0.002, 0.012, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.0,   0.055, 0.009, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.0,   0.055, 0.009, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.059,  0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.059,   0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0]]],
    #[[[0.078, 0.004, 0.002, 0.001, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.078,   0.004, 0.002, 0.001, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.063,  0.008, 0.004, 0.013, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.063,   0.008, 0.004, 0.013, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.01,   0.015, 0.008, 0.035, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.01,    0.015, 0.008, 0.035, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.026, 0.052, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.026, 0.052, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.024,  0.014, 0.007, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.024,   0.014, 0.007, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.012,  0.005, 0.003, 0.033, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.012,   0.005, 0.003, 0.033, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.032,  0.017, 0.008, 0.04,  0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.032,   0.017, 0.008, 0.04,  0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.02,  0.041, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.02,  0.041, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0]]],
    #[[[0.075, 0.001, 0.0,   0.002, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.075,   0.001, 0.0,   0.002, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.041,  0.01,  0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.041,   0.01,  0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.009, 0.074, 0.003, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.009, 0.074, 0.003, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.058, 0.003, 0.026, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.058, 0.003, 0.026, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.075,  0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.075,   0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.05,  0.003, 0.011, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.05,  0.003, 0.011, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.0,   0.054, 0.01,  0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.0,   0.054, 0.01,  0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.06,   0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.06,    0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0]]],
    #[[[0.078, 0.004, 0.002, 0.001, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.078,   0.004, 0.002, 0.001, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.063,  0.008, 0.004, 0.013, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.063,   0.008, 0.004, 0.013, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.01,   0.015, 0.008, 0.035, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.01,    0.015, 0.008, 0.035, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.026, 0.052, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.026, 0.052, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.024,  0.014, 0.007, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.024,   0.014, 0.007, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.011,  0.005, 0.002, 0.032, 0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.011,   0.005, 0.002, 0.032, 0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.033,  0.017, 0.009, 0.04,  0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.033,   0.017, 0.009, 0.04,  0.0, 0.0, 0.0, 0.0, 0.0]],
    #[[0.0,    0.02,  0.041, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0],
    #[0.0,     0.02,  0.041, 0.0,   0.0, 0.0, 0.0, 0.0, 0.0]]]]
    #assert_equal(correct, @p00.states)
    #pp @p00.states[0][0][0][0]
  end

  #def test_sum_ions
  #  #pp @p00.sum_ions([0,1])
  #  [ [-5.72406918, 0.075, 0.001, 0.000, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [-3.85979310, 0.234, 0.012, 0.006, 0.003, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [-1.03952109, 0.189, 0.024, 0.012, 0.039, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [ 1.39818264, 0.041, 0.010, 0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 1.83993091, 0.030, 0.045, 0.024, 0.105, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [ 3.13528844, 0.000, 0.078, 0.156, 0.000, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [ 4.54489326, 0.000, 0.007, 0.075, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 4.54489326, 0.000, 0.060, 0.002, 0.025, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 6.82460808, 0.072, 0.042, 0.021, 0.006, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [ 7.18759475, 0.076, 0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 8.74432526, 0.000, 0.000, 0.055, 0.009, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 8.74432526, 0.000, 0.050, 0.002, 0.012, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5],
  #    [ 9.7084102 , 0.036, 0.015, 0.009, 0.099, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [10.87421242, 0.096, 0.051, 0.024, 0.120, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [11.13140386, 0.000, 0.060, 0.123, 0.000, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5],
  #    [11.94041316, 0.059, 0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5]
  #  ]
  #end
end


