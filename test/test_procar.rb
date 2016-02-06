#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "vasputils.rb"
#require "pkg/klass.rb"
#
class VaspUtils::Procar
  public :project_onto_energy, :left_foot_gaussian, :right_foot_gaussian,
    :broadening, :dos_for_spin
end

class TC_Procar < Test::Unit::TestCase
  TOLERANCE = 1.0E-10

  def setup
    @p00 = VaspUtils::Procar.load_file("test/procar/Si2-k222-NBAND8-ISPIN2.PROCAR")
    @p01 = VaspUtils::Procar.load_file("test/procar/La.PROCAR")
  end

  #def test_load_file
  #  #pp @p00.energies
  #  #pp @p00.states
  #  #pp @p00.occupancies
  #  #pp @p00.weights
  #end

  def test_energies
    correct =
      [
        [
          [ -5.72406918, 1.39818264, 4.54489326, 4.54489326,
            7.18759475, 8.74432526, 8.74432526, 11.94041316],
          [ -3.85979310, -1.03952109, 1.83993091, 3.13528844,
            6.82460808, 9.70841020, 10.87421242, 11.13140386],
        ], [
          [ -4.68323341, 2.43044440, 5.55330388, 5.55330388,
            8.26994506, 9.84168906, 9.84168906, 13.01171710],
          [-2.82249666, -0.00489068, 2.87902633, 4.16118261,
           7.90270675, 10.76948848, 11.94438791, 12.21350660],
        ]
      ]
    assert_equal(correct, @p00.energies)
  end

  def test_occupancies
    correct = [
      [ [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
        [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
      ], [
        [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0],
        [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0]
      ]
    ]
    assert_equal(correct, @p00.occupancies)
  end

  def test_num_spins
    assert_equal(2, @p00.num_spins)
    assert_equal(1, @p01.num_spins)
  end

  def test_num_bands
    assert_equal(8, @p00.num_bands)
    assert_equal(20, @p01.num_bands)
  end

  def test_num_kpoints
    assert_equal(2, @p00.num_kpoints)
    assert_equal(1, @p01.num_kpoints)
  end

  def test_num_ions
    assert_equal(2, @p00.num_ions)
    assert_equal(1, @p01.num_ions)
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

  def test_project_onto_energy
    corrects = [ 
      {:energy=>-5.72406918, :orbitals=>[0.01875, 0.00025, 0.00000, 0.00050, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=>-3.85979310, :orbitals=>[0.05850, 0.00300, 0.00150, 0.00075, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>-1.03952109, :orbitals=>[0.04725, 0.00600, 0.00300, 0.00975, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 1.39818264, :orbitals=>[0.01025, 0.00250, 0.00125, 0.00725, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 1.83993091, :orbitals=>[0.00750, 0.01125, 0.00600, 0.02625, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 3.13528844, :orbitals=>[0.00000, 0.01950, 0.03900, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.00175, 0.01875, 0.00100, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.01500, 0.00050, 0.00625, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 6.82460808, :orbitals=>[0.01800, 0.01050, 0.00525, 0.00150, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 7.18759475, :orbitals=>[0.01900, 0.00125, 0.00050, 0.00350, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.00000, 0.01375, 0.00225, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.01250, 0.00050, 0.00300, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 9.7084102 , :orbitals=>[0.00900, 0.00375, 0.00225, 0.02475, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>10.87421242, :orbitals=>[0.02400, 0.01275, 0.00600, 0.03000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.13140386, :orbitals=>[0.00000, 0.01500, 0.03075, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.94041316, :orbitals=>[0.01475, 0.00475, 0.00225, 0.01400, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
    ]
    results = @p00.project_onto_energy(0, [2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end

    corrects = [ 
      {:energy=>-4.68323341, :orbitals=>[0.01875, 0.00025, 0.00000, 0.00050, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.25, band   1  
      {:energy=>-2.82249666, :orbitals=>[0.05850, 0.00300, 0.00150, 0.00075, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.75, band   1  
      {:energy=>-0.00489068, :orbitals=>[0.04725, 0.00600, 0.00300, 0.00975, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.75, band   2  
      {:energy=> 2.43044440, :orbitals=>[0.01025, 0.00250, 0.00125, 0.00725, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.25, band   2  
      {:energy=> 2.87902633, :orbitals=>[0.00750, 0.01125, 0.00600, 0.02625, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.75, band   3  
      {:energy=> 4.16118261, :orbitals=>[0.00000, 0.01950, 0.03900, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.75, band   4  
      {:energy=> 5.55330388, :orbitals=>[0.00000, 0.00225, 0.01850, 0.00075, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.25, band   3  
      {:energy=> 5.55330388, :orbitals=>[0.00000, 0.01450, 0.00075, 0.00650, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  1.00000000 , weight = 0.25, band   4  
      {:energy=> 7.90270675, :orbitals=>[0.01800, 0.01050, 0.00525, 0.00150, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.75, band   5  
      {:energy=> 8.26994506, :orbitals=>[0.01875, 0.00125, 0.00050, 0.00350, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.25, band   5  
      {:energy=> 9.84168906, :orbitals=>[0.00000, 0.00000, 0.01350, 0.00250, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.25, band   6  
      {:energy=> 9.84168906, :orbitals=>[0.00000, 0.01250, 0.00075, 0.00275, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.25, band   7  
      {:energy=>10.76948848, :orbitals=>[0.00825, 0.00375, 0.00150, 0.02400, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.75, band   6  
      {:energy=>11.94438791, :orbitals=>[0.02475, 0.01275, 0.00675, 0.03000, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.75, band   7  
      {:energy=>12.21350660, :orbitals=>[0.00000, 0.01500, 0.03075, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.75, band   8  
      {:energy=>13.01171710, :orbitals=>[0.01500, 0.00475, 0.00225, 0.01400, 0.0, 0.0, 0.0, 0.0, 0.0]}, # occ.  0.00000000 , weight = 0.25, band   8  
    ]
    results = @p00.project_onto_energy(1, [2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end

    corrects = [ 
      {:energy=>-5.72406918, :orbitals=>[0.03750, 0.00050, 0.00000, 0.00100, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=>-3.85979310, :orbitals=>[0.11700, 0.00600, 0.00300, 0.00150, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>-1.03952109, :orbitals=>[0.09450, 0.01200, 0.00600, 0.01950, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 1.39818264, :orbitals=>[0.02050, 0.00500, 0.00250, 0.01450, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 1.83993091, :orbitals=>[0.01500, 0.02250, 0.01200, 0.05250, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 3.13528844, :orbitals=>[0.00000, 0.03900, 0.07800, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.00350, 0.03750, 0.00200, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.03000, 0.00100, 0.01250, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 6.82460808, :orbitals=>[0.03600, 0.02100, 0.01050, 0.00300, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 7.18759475, :orbitals=>[0.03800, 0.00250, 0.00100, 0.00700, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.00000, 0.02750, 0.00450, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.02500, 0.00100, 0.00600, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 9.7084102 , :orbitals=>[0.01800, 0.00750, 0.00450, 0.04950, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>10.87421242, :orbitals=>[0.04800, 0.02550, 0.01200, 0.06000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.13140386, :orbitals=>[0.00000, 0.03000, 0.06150, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>11.94041316, :orbitals=>[0.02950, 0.00950, 0.00450, 0.02800, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
    ]
    results = @p00.project_onto_energy(0, [1, 2])
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end

    # occpancy
    corrects = [ 
      {:energy=>-5.72406918, :orbitals=>[0.01875, 0.00025, 0.00000, 0.00050, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.25 }, #:weight=>0.25, 
      {:energy=>-3.85979310, :orbitals=>[0.05850, 0.00300, 0.00150, 0.00075, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.75 }, #:weight=>0.75, 
      {:energy=>-1.03952109, :orbitals=>[0.04725, 0.00600, 0.00300, 0.00975, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.75 }, #:weight=>0.75, 
      {:energy=> 1.39818264, :orbitals=>[0.01025, 0.00250, 0.00125, 0.00725, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.25 }, #:weight=>0.25, 
      {:energy=> 1.83993091, :orbitals=>[0.00750, 0.01125, 0.00600, 0.02625, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.75 }, #:weight=>0.75, 
      {:energy=> 3.13528844, :orbitals=>[0.00000, 0.01950, 0.03900, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.75 }, #:weight=>0.75, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.00175, 0.01875, 0.00100, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.25 }, #:weight=>0.25, 
      {:energy=> 4.54489326, :orbitals=>[0.00000, 0.01500, 0.00050, 0.00625, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.25 }, #:weight=>0.25, 
      {:energy=> 6.82460808, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.75, 
      {:energy=> 7.18759475, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.25, 
      {:energy=> 8.74432526, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.25, 
      {:energy=> 9.7084102 , :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.75, 
      {:energy=>10.87421242, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.75, 
      {:energy=>11.13140386, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.75, 
      {:energy=>11.94041316, :orbitals=>[0.00000, 0.00000, 0.00000, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0], :raw_total=>0.0  }, #:weight=>0.25, 
    ]
    results = @p00.project_onto_energy(0, [2], 0.0, true)
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_equal(corrects[i][:energy], results[i][:energy])
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
      assert_equal(corrects[i][:energy], results[i][:energy])
    end

    ##fermi
    corrects = [ 
      {:energy=>-6.72406918, :orbitals=>[0.01875, 0.00025, 0.00000, 0.00050, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=>-4.85979310, :orbitals=>[0.05850, 0.00300, 0.00150, 0.00075, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>-2.03952109, :orbitals=>[0.04725, 0.00600, 0.00300, 0.00975, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 0.39818264, :orbitals=>[0.01025, 0.00250, 0.00125, 0.00725, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 0.83993091, :orbitals=>[0.00750, 0.01125, 0.00600, 0.02625, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 2.13528844, :orbitals=>[0.00000, 0.01950, 0.03900, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 3.54489326, :orbitals=>[0.00000, 0.00175, 0.01875, 0.00100, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 3.54489326, :orbitals=>[0.00000, 0.01500, 0.00050, 0.00625, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 5.82460808, :orbitals=>[0.01800, 0.01050, 0.00525, 0.00150, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 6.18759475, :orbitals=>[0.01900, 0.00125, 0.00050, 0.00350, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 7.74432526, :orbitals=>[0.00000, 0.00000, 0.01375, 0.00225, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 7.74432526, :orbitals=>[0.00000, 0.01250, 0.00050, 0.00300, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
      {:energy=> 8.7084102 , :orbitals=>[0.00900, 0.00375, 0.00225, 0.02475, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=> 9.87421242, :orbitals=>[0.02400, 0.01275, 0.00600, 0.03000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>10.13140386, :orbitals=>[0.00000, 0.01500, 0.03075, 0.00000, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.75, 
      {:energy=>10.94041316, :orbitals=>[0.01475, 0.00475, 0.00225, 0.01400, 0.0, 0.0, 0.0, 0.0, 0.0]}, #:weight=>0.25, 
    ]
    results = @p00.project_onto_energy(0, [2], 1.0)
    assert_equal(corrects.size, results.size)
    corrects.size.times do |i|
      assert_in_delta(corrects[i][:energy], results[i][:energy], TOLERANCE)
      corrects[i][:orbitals].size.times do |o|
        assert_in_delta(corrects[i][:orbitals][o], results[i][:orbitals][o], TOLERANCE)
      end
    end

  end

  def test_dos_for_spin
    options = {
      :tick       => 2.0,
      :sigma      => 0.1,
      :occupancy  => false,
      :min_energy => nil,
      :max_energy => nil
    }
    results = @p00.dos_for_spin([1], options, 0)
    corrects = {:energies=>
        [-8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0],
      :orbitals=>
        [[0.0, 0.0, 0.0],
        [0.001661879915662385, 6.647519662649539e-05, 0.0],
        [0.08733703272537284, 0.007837938834328333, 0.0],
        [1.7500494766068833e-21, 6.944640780186046e-22, 0.0],
        [0.0, 0.0, 0.0],
        [0.008309870032482439, 0.04819724354918, 0.0],
        [0.0, 6.160364936234087e-08, 0.0],
        [1.232075624245764e-16, 1.1807391399021904e-16, 0.0],
        [3.53098629817181e-16, 1.1913034999418196e-13, 0.0],
        [0.0005115246843140268, 0.0017477093380729217, 0.0],
        [0.04927220197280553, 0.07015025365619772, 0.0],
        [0.0, 0.0, 0.0]],
      :raw_total_sums=>
        [0.0,
        0.022158398875498465,
        1.1197055477611904,
        2.777856312074418e-20,
        0.0,
        0.8309869610316482,
        7.121809175007587e-07,
        5.133648434357349e-15,
        1.8645332731578884e-12,
        0.04262705702616878,
        0.8351220673356872,
        0.0]}
    assert_equal(corrects, results)


    options = {
      :tick       => 2.0,
      :sigma      => 0.1,
      :occupancy  => true,
      :min_energy => nil,
      :max_energy => nil
    }
    results = @p00.dos_for_spin( [1], options, 0)
    corrects = {:energies=>
        [-8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0],
      :orbitals=>
        [[0.0, 0.0, 0.0],
        [0.001661879915662385, 6.647519662649539e-05, 0.0],
        [0.08733703272537284, 0.007837938834328333, 0.0],
        [1.7500494766068833e-21, 6.944640780186046e-22, 0.0],
        [0.0, 0.0, 0.0],
        [0.008309870032482439, 0.04819724354918, 0.0],
        [0.0, 6.160364936234087e-08, 0.0],
        [1.232075624245764e-16, 1.1807391399021904e-16, 0.0],
        [3.53098629817181e-16, 1.1913034999418196e-13, 0.0],
        [0.0005115246843140268, 0.0017477093380729217, 0.0],
        [0.04927220197280553, 0.07015025365619772, 0.0],
        [0.0, 0.0, 0.0]],
      :raw_total_sums=>
        [0.0,
        0.022158398875498465,
        1.1197055477611904,
        2.777856312074418e-20,
        0.0,
        0.8309869610316482,
        7.121809175007587e-07,
        5.133648434357349e-15,
        1.8645332731578884e-12,
        0.04262705702616878,
        0.8351220673356872,
        0.0]}


  end

  def test_left_foot_gaussian
    sigma = 0.1
    tick = 0.01
    min = @p00.left_foot_gaussian(@p00.energies[0][0][0], sigma, tick)
    assert_in_delta(-6.73, min, TOLERANCE)
  end

  def test_right_foot_gaussian
    sigma = 0.1
    tick = 0.01
    max = @p00.right_foot_gaussian(@p00.energies[0][0][7], sigma, tick)
    assert_in_delta(12.95, max, TOLERANCE)
    
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
    sigma      = 1.0
    min_energy = -11.0
    max_energy = 11.0
    tick       = 1.0
    proj = [
      { :energy => -1.0, :orbitals => [1.0, 1.0], :raw_total => 2.0 },
      { :energy =>  1.0, :orbitals => [1.0, 2.0], :raw_total => 1.0 },
    ]
    results = @p00.broadening(proj, sigma, min_energy, max_energy, tick)
    corrects =
      { :energies => [
          -11.0, -10.0, -9.0, -8.0, -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0,
          0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0],
        :orbitals => [
          [7.69459862670642e-23   , 7.69459862670642e-23  ],
          [1.0279773571668917e-18 , 1.0279773571668917e-18],
          [5.052271160482879e-15  , 5.052271237428865e-15 ],
          [9.134721436341952e-12  , 9.13472246431931e-12  ],
          [6.07588790209437e-09   , 6.075892954365453e-09 ],
          [1.4867286494547063e-06 , 1.4867377841751147e-06],
          [0.0001338363016477352  , 0.000133842377530585  ],
          [0.004433335131452742   , 0.004434821850967476  ],
          [0.05412479673895295    , 0.05425862696471783   ],
          [0.24640257293108137    , 0.25083442134301936   ],
          [0.4529332469146208     , 0.5069242134278088    ],
          [0.48394144903828673    , 0.7259121735574301    ],
          [0.4529332469146208     , 0.8518755273160534    ],
          [0.24640257293108137    , 0.48837329745022473   ],
          [0.05412479673895295    , 0.108115763252141     ],
          [0.004433335131452742   , 0.00886518354339075   ],
          [0.0001338363016477352  , 0.0002676665274126206 ],
          [1.4867286494547063e-06 , 2.973448164189004e-06 ],
          [6.07588790209437e-09   , 1.2151770751917655e-08],
          [9.134721436341952e-12  , 1.8269441844706546e-11],
          [5.052271160482879e-15  , 1.0104542244019772e-14],
          [1.0279773571668917e-18 , 2.0559547143337833e-18],
          [7.69459862670642e-23   , 1.538919725341284e-22 ],
        ],
        :raw_total_sums => [
          1.538919725341284e-22   ,
          2.0559547143337833e-18  ,
          1.0104542244019772e-14  ,
          1.8269441844706546e-11  ,
          1.2151770751917655e-08  ,
          2.973448164189004e-06   ,
          0.0002676665274126206   ,
          0.00886518354339075     ,
          0.108115763252141       ,
          0.48837329745022473     ,
          0.8518755273160534      ,
          0.7259121735574301      ,
          0.5069242134278088      ,
          0.25083442134301936     ,
          0.05425862696471783     ,
          0.004434821850967476    ,
          0.000133842377530585    ,
          1.4867377841751147e-06  ,
          6.075892954365453e-09   ,
          9.13472246431931e-12    ,
          5.052271237428865e-15   ,
          1.0279773571668917e-18  ,
          7.69459862670642e-23   
        ]
      }
      assert_equal(corrects.keys, results.keys)
      assert_equal(corrects[:energies].size, results[:energies].size)
      assert_equal(corrects[:orbitals].size, results[:orbitals].size)
      assert_equal(corrects[:raw_total_sums].size, results[:raw_total_sums].size)
      corrects[:energies].size.times do |i|
        assert_in_delta(corrects[:energies][i], results[:energies][i], TOLERANCE)
      end
      corrects[:energies].size.times do |i|
        assert_in_delta(results[:orbitals][i][0] / corrects[:orbitals][i][0], 1.0, TOLERANCE)
        assert_in_delta(results[:orbitals][i][1] / corrects[:orbitals][i][1], 1.0, TOLERANCE)
        assert_in_delta(results[:raw_total_sums][i] / corrects[:raw_total_sums][i], 1.0, TOLERANCE)
      end
  end

  def test_dos_labels
    options = {}
    #assert_equal(['eigenvalue', 's', 'p', 'd', 'raw_total'],
    #             @p00.dos_labels(options))
    assert_equal(['eigenvalue',
                  's_up', 'p_up', 'd_up', 'raw_total_up',
                  's_down', 'p_down', 'd_down', 'raw_total_down'],
                 @p00.dos_labels(options))
    assert_equal(['eigenvalue', 's', 'p', 'd', 'f', 'raw_total'],
                 @p01.dos_labels(options))

    options = { :precise     => true, }
    assert_equal(
      ['eigenvalue',
       "s_up", "py_up", "pz_up", "px_up", "dxy_up", "dyz_up", "dz2_up", "dxz_up", "dx2_up", 'raw_total_up',
       "s_down", "py_down", "pz_down", "px_down", "dxy_down", "dyz_down", "dz2_down", "dxz_down", "dx2_down", 'raw_total_down',
    ],
      @p00.dos_labels(options)
    )
    assert_equal(
      ['eigenvalue', "s", "py", "pz", "px", "dxy", "dyz", "dz2", "dxz", "dx2",
        "f-3", "f-2", "f-1", "f0", "f1", "f2", "f3", 'raw_total'],
        @p01.dos_labels(options)
    )

    options = { :down => true}
    assert_equal(['eigenvalue', 's_up', 'p_up', 'd_up', 'raw_total_up',
                  's_down', 'p_down', 'd_down', 'raw_total_down'],
                 @p00.dos_labels(options))
    assert_equal(['eigenvalue', 's', 'p', 'd', 'f', 'raw_total'],
                 @p01.dos_labels(options))
    #assert_equal(['eigenvalue', 's_up', 'p_up', 'd_up', 'f_up', 'raw_total_up',
    #              's_down', 'p_down', 'd_down', 'f_down', 'raw_total_down'],
    #             @p01.dos_labels(options))
  end

  def test_density_of_states
    #ion_indices = [1]
    #options = {
    #  :tick   => 1.0,
    #  :sigma  => 0.1,
    #  :occupancy => false
    #}
    #pp @p00.density_of_states(ion_indices, options)
    #
    #exit

    #ion_indices = [1]
    #options = {
    #  :tick   => 1.0,
    #  :sigma  => 0.1,
    #  :down  => true,
    #  :occupancy => false
    #}

    #@p00.density_of_states(ion_indices, options)
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

end


