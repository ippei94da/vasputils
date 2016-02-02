#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "vasputils.rb"
#require "pkg/klass.rb"
#
class VaspUtils::Procar
  public :project_onto_energy, :left_foot_gaussian, :right_foot_gaussian,
    :broadening
end

class TC_Procar < Test::Unit::TestCase
  TOLERANCE = 1.0E-10

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

  def test_num_orbitals
    assert_equal( 9, @p00.num_orbitals)
    assert_equal(16, @p01.num_orbitals)
  end

  def test_weights
    assert_equal([0.25, 0.75, 0.25, 0.75], @p00.weights)
  end

  def test_f_orbital?
    assert_equal(false, @p00.f_orbital?)
    assert_equal(true , @p01.f_orbital?)
  end

  #def test_each_band
  #  @p00.each_band do |i|
  #    p i
  #  end
  #end

  def test_project_onto_energy
    corrects = [ 
      {:energy=>-5.72406918, :orbitals=>[0.0375, 0.0005, 0.0000, 0.0010, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=>-3.85979310, :orbitals=>[0.1170, 0.0060, 0.0030, 0.0015, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>-1.03952109, :orbitals=>[0.0945, 0.0120, 0.0060, 0.0195, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 1.39818264, :orbitals=>[0.0205, 0.0050, 0.0025, 0.0145, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 1.83993091, :orbitals=>[0.0150, 0.0225, 0.0120, 0.0525, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 3.13528844, :orbitals=>[0.0000, 0.0390, 0.0780, 0.0000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 4.54489326, :orbitals=>[0.0000, 0.0035, 0.0375, 0.0020, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 4.54489326, :orbitals=>[0.0000, 0.0300, 0.0010, 0.0125, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 6.82460808, :orbitals=>[0.0360, 0.0210, 0.0105, 0.0030, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 7.18759475, :orbitals=>[0.0380, 0.0025, 0.0010, 0.0070, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.0000, 0.0000, 0.0275, 0.0045, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.0000, 0.0250, 0.0010, 0.0060, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 9.7084102 , :orbitals=>[0.0180, 0.0075, 0.0045, 0.0495, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>10.87421242, :orbitals=>[0.0480, 0.0255, 0.0120, 0.0600, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.13140386, :orbitals=>[0.0000, 0.0300, 0.0615, 0.0000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.94041316, :orbitals=>[0.0295, 0.0095, 0.0045, 0.0280, 0.0, 0.0, 0.0, 0.0, 0.0]}  #:weight=>0.25, 
    ]
    results = @p00.project_onto_energy([2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end


    corrects = [ 
      {:energy=>-5.72406918, :weight=>0.25, :orbitals=>[0.075, 0.001, 0.000, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=>-3.85979310, :weight=>0.75, :orbitals=>[0.234, 0.012, 0.006, 0.003, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=>-1.03952109, :weight=>0.75, :orbitals=>[0.189, 0.024, 0.012, 0.039, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 1.39818264, :weight=>0.25, :orbitals=>[0.041, 0.010, 0.005, 0.029, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 1.83993091, :weight=>0.75, :orbitals=>[0.030, 0.045, 0.024, 0.105, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 3.13528844, :weight=>0.75, :orbitals=>[0.000, 0.078, 0.156, 0.000, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 4.54489326, :weight=>0.25, :orbitals=>[0.000, 0.007, 0.075, 0.004, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 4.54489326, :weight=>0.25, :orbitals=>[0.000, 0.060, 0.002, 0.025, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 6.82460808, :weight=>0.75, :orbitals=>[0.072, 0.042, 0.021, 0.006, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 7.18759475, :weight=>0.25, :orbitals=>[0.076, 0.005, 0.002, 0.014, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 8.74432526, :weight=>0.25, :orbitals=>[0.000, 0.000, 0.055, 0.009, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 8.74432526, :weight=>0.25, :orbitals=>[0.000, 0.050, 0.002, 0.012, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=> 9.7084102 , :weight=>0.75, :orbitals=>[0.036, 0.015, 0.009, 0.099, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=>10.87421242, :weight=>0.75, :orbitals=>[0.096, 0.051, 0.024, 0.120, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=>11.13140386, :weight=>0.75, :orbitals=>[0.000, 0.060, 0.123, 0.000, 0.0, 0.0, 0.0, 0.0, 0.0]},
      {:energy=>11.94041316, :weight=>0.25, :orbitals=>[0.059, 0.019, 0.009, 0.056, 0.0, 0.0, 0.0, 0.0, 0.0]}
    ]
    results = @p00.project_onto_energy([1, 2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end

  end
  
  def test_left_foot_gaussian
    sigma = 0.1
    tick = 0.01
    min = @p00.left_foot_gaussian(@p00.energies[0][0], sigma, tick)
    assert_in_delta(-6.73, min, TOLERANCE)
  end

  def test_right_foot_gaussian
    sigma = 0.1
    tick = 0.01
    max = @p00.right_foot_gaussian(@p00.energies[2][7], sigma, tick)
    assert_in_delta(14.02, max, TOLERANCE)
    
  end

  def test_gauss_function
    assert_in_delta(0.24197072451914337  , VaspUtils::Procar.gauss_function(1.0, 1.0), TOLERANCE)
    assert_in_delta(0.05399096651318806  , VaspUtils::Procar.gauss_function(1.0, 2.0), TOLERANCE)
    assert_in_delta(0.0044318484119380075, VaspUtils::Procar.gauss_function(1.0, 3.0), TOLERANCE)
    assert_in_delta(0.17603266338214976  , VaspUtils::Procar.gauss_function(2.0, 1.0), TOLERANCE)
    assert_in_delta(0.12098536225957168  , VaspUtils::Procar.gauss_function(2.0, 2.0), TOLERANCE)
    assert_in_delta(0.06475879783294587  , VaspUtils::Procar.gauss_function(2.0, 3.0), TOLERANCE)
    assert_in_delta(0.12579440923099774  , VaspUtils::Procar.gauss_function(3.0, 1.0), TOLERANCE)
    assert_in_delta(0.10648266850745075  , VaspUtils::Procar.gauss_function(3.0, 2.0), TOLERANCE)
    assert_in_delta(0.0806569081730478   , VaspUtils::Procar.gauss_function(3.0, 3.0), TOLERANCE)
  end

  def test_broadening
    options = {
      :tick       => 1.0,
      :sigma      => 1.0,
      :occupy     => false,
      :min_energy => nil,
      :max_energy => nil
    }
    proj = [
      { :energy => -1.0, :orbitals => [1.0, 1.0], :raw_total => 2.0 },
      { :energy =>  1.0, :orbitals => [1.0, 2.0], :raw_total => 1.0 },
    ]
    results = @p00.broadening(proj, options)
    corrects =
      [
        [-11.0, 7.69459862670642e-23   , 7.69459862670642e-23   , 1.538919725341284e-22  ],
        [-10.0, 1.0279773571668917e-18 , 1.0279773571668917e-18 , 2.0559547143337833e-18 ],
        [ -9.0, 5.052271160482879e-15  , 5.052271237428865e-15  , 1.0104542244019772e-14 ],
        [ -8.0, 9.134721436341952e-12  , 9.13472246431931e-12   , 1.8269441844706546e-11 ],
        [ -7.0, 6.07588790209437e-09   , 6.075892954365453e-09  , 1.2151770751917655e-08 ],
        [ -6.0, 1.4867286494547063e-06 , 1.4867377841751147e-06 , 2.973448164189004e-06  ],
        [ -5.0, 0.0001338363016477352  , 0.000133842377530585   , 0.0002676665274126206  ],
        [ -4.0, 0.004433335131452742   , 0.004434821850967476   , 0.00886518354339075    ],
        [ -3.0, 0.05412479673895295    , 0.05425862696471783    , 0.108115763252141      ],
        [ -2.0, 0.24640257293108137    , 0.25083442134301936    , 0.48837329745022473    ],
        [ -1.0, 0.4529332469146208     , 0.5069242134278088     , 0.8518755273160534     ],
        [  0.0, 0.48394144903828673    , 0.7259121735574301     , 0.7259121735574301     ],
        [  1.0, 0.4529332469146208     , 0.8518755273160534     , 0.5069242134278088     ],
        [  2.0, 0.24640257293108137    , 0.48837329745022473    , 0.25083442134301936    ],
        [  3.0, 0.05412479673895295    , 0.108115763252141      , 0.05425862696471783    ],
        [  4.0, 0.004433335131452742   , 0.00886518354339075    , 0.004434821850967476   ],
        [  5.0, 0.0001338363016477352  , 0.0002676665274126206  , 0.000133842377530585   ],
        [  6.0, 1.4867286494547063e-06 , 2.973448164189004e-06  , 1.4867377841751147e-06 ],
        [  7.0, 6.07588790209437e-09   , 1.2151770751917655e-08 , 6.075892954365453e-09  ],
        [  8.0, 9.134721436341952e-12  , 1.8269441844706546e-11 , 9.13472246431931e-12   ],
        [  9.0, 5.052271160482879e-15  , 1.0104542244019772e-14 , 5.052271237428865e-15  ],
        [ 10.0, 1.0279773571668917e-18 , 2.0559547143337833e-18 , 1.0279773571668917e-18 ],
        [ 11.0, 7.69459862670642e-23   , 1.538919725341284e-22  , 7.69459862670642e-23   ],
      ]
      assert_equal(corrects, results)


      #p      2.0 * 7.69459862670642e-23
      #p      2.0 * 1.0279773571668917e-18
      #p      2.0 * 5.052271083536893e-15    + 1.0 * 7.69459862670642e-23   
      #p      2.0 * 9.134720408364595e-12    + 1.0 * 1.0279773571668917e-18 
      #p      2.0 * 6.075882849823286e-09    + 1.0 * 5.052271083536893e-15  
      #p      2.0 * 1.4867195147342979e-06   + 1.0 * 9.134720408364595e-12  
      #p      2.0 * 0.00013383022576488537   + 1.0 * 6.075882849823286e-09  
      #p      2.0 * 0.0044318484119380075    + 1.0 * 1.4867195147342979e-06 
      #p      2.0 * 0.05399096651318806      + 1.0 * 0.00013383022576488537 
      #p      2.0 * 0.24197072451914337      + 1.0 * 0.0044318484119380075  
      #p      2.0 * 0.3989422804014327       + 1.0 * 0.05399096651318806    
      #p      2.0 * 0.24197072451914337      + 1.0 * 0.24197072451914337    
      #p      2.0 * 0.05399096651318806      + 1.0 * 0.3989422804014327     
      #p      2.0 * 0.0044318484119380075    + 1.0 * 0.24197072451914337    
      #p      2.0 * 0.00013383022576488537   + 1.0 * 0.05399096651318806    
      #p      2.0 * 1.4867195147342979e-06   + 1.0 * 0.0044318484119380075  
      #p      2.0 * 6.075882849823286e-09    + 1.0 * 0.00013383022576488537 
      #p      2.0 * 9.134720408364595e-12    + 1.0 * 1.4867195147342979e-06 
      #p      2.0 * 5.052271083536893e-15    + 1.0 * 6.075882849823286e-09  
      #p      2.0 * 1.0279773571668917e-18   + 1.0 * 9.134720408364595e-12  
      #p      2.0 * 7.69459862670642e-23     + 1.0 * 5.052271083536893e-15  
      #p                                       1.0 * 1.0279773571668917e-18 
      #p                                       1.0 * 7.69459862670642e-23   
  end

  #def test_density_of_states
  #  ion_indices = [1]
  #  options = {
  #    :tick   => 1.0,
  #    :sigma  => 0.1,
  #    :occupy => false
  #  }

  #  @p00.density_of_states(ion_indices, options)
  #end

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


