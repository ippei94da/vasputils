#!/usr/bin/ruby -w

# class for parsing PROCAR
#
# First written by Atsushi Togo
#   Time-stamp: <2006-07-31 22:54:10 togo>
# Modified by Ippei Kishdia 


#require 'tanakalab/broadning.rb' つかってなさそう。
#raw_total というのはたぶん、PROCAR に出てくる tot とは関係なく、
#k点の重みとバンドエネルギーだけで出せる DOS だと思う。

class VaspUtils::Procar
  attr_reader :energies, :num_bands, :num_ions,
    :num_kpoints, :occupancies, :states, :weights

  #PROCAR_LABELS = [
  #  :ion,
  #  :s,
  #  :py, :pz, :px,
  #  :dxy, :dyz, :dz2, :dxz, :dx2,
  #  :f_3, :f_2, :f_1, :f0, :f1, :f2, :f3, # :f-3, :f-2, :f-1, :f0, :f1, :f2, :f3,
  #  :tot
  #]

  #def initialize( energies, num_bands, num_ions, num_kpoints, occupancies, states, weights)
  def initialize(states, energies, occupancies, weights)
    @states      = states
    @energies    = energies
    @occupancies = occupancies
    @weights     = weights
  end

  # PROCAR 形式ファイルから読み込む。
  # states は5重の配列になっている。外側から、
  # - spin    (item number is ISPIN in INCAR.)
  # - k-point (item number is a number of irreducible k-points.)
  # - band    (item number is NBAND in INCAR.)
  # - ion     (item number is an ion number in POSCAR.)
  # - orbital (item number is count of s, py, pz, px, ....)
  def self.load_file(filename)
    states = Array.new           # [kpoints][bands][ions][orbitals]
    energies = Array.new         # [kpoinst][bands]
    occupancies = Array.new      # [kpoints][bands]
    weights = Array.new          # [kpoints]

    io = open(filename, "r")
    io.gets                     # (line 1)
    line2 = io.gets.strip.split(/\s+|:/) # header (line 2)
      #'# of k-points:    2         # of bands:   8         # of ions:   2'
    line2.delete("")
    num_kpoints = line2[3].to_i
    num_bands = line2[7].to_i
    num_ions = line2[11].to_i

    2.times do |spin|
      states_for_spin = []

      num_kpoints.times do |i|
        io.gets  #empty line before ' k-point    1 :    0.25000000 0.25...'
        headline = io.gets  # header for each kpoint
        break if headline == nil
        headline = headline.strip.split  # header for each kpoint
        weights << headline[-1].to_f
        io.gets
        states_for_bands = Array.new
        occupancies_for_bands = Array.new
        energies_for_bands = Array.new
        num_bands.times do |j|
          line = io.gets.strip.split # header for each band
          energies_for_bands << line[4].to_f
          occupancies_for_bands << line[7].to_f
          io.gets
          io.gets
          states_for_ions = Array.new
          num_ions.times do |k|
            #states = Array.new
            line = io.gets.strip.split
            line.shift ##remove 'ion'
            line.pop   ##remove 'tot'
            states_for_ions << line.map{|i| i.to_f}
          end
          io.gets if num_ions > 1
          io.gets
          #io.gets if f_orbital?
          (num_ions * 2).times {io.gets}
          io.gets
          states_for_bands << states_for_ions
        end
        occupancies << occupancies_for_bands
        energies << energies_for_bands
        states_for_spin << states_for_bands
      end
      states << states_for_spin
      io.gets
    end
    io.close
    self.new(states, energies, occupancies, weights)
  end

  # Gauss function, x=0 centered.
  # Return scalar value (of y).
  def self.gauss_function(sigma, deviation)
    Math.exp(-deviation**(2.0)/(2.0 * (sigma**2.0))) /
      (sigma * Math.sqrt(2 * Math::PI))
  end

  def num_spins
    @states.size
  end

  def num_kpoints
    @states[0].size
  end

  def num_bands
    @states[0][0].size
  end

  def num_ions
    @states[0][0][0].size
  end

  def num_orbitals
    @states[0][0][0][0].size
  end

  def f_orbital?
    result = false
    result = true if 16 == @states[0][0][0][0].size
    result
  end

  def header
    sprintf("# k-points: #{@states.size}  bands: #{@states[0].size}  ions: #{@states[0][0].size}\n")
  end

  #def density_of_states(ion_indices, tick, sigma, occupy = false)
  def density_of_states(ion_indices, options)
    tick       = options[:tick]
    sigma      = options[:sigma]
    occupy     = options[:occupy]
    min_energy = options[:min_energy]
    max_energy = options[:max_energy]

    proj = project_onto_energy(ion_indices)
    if occupy == true
      (num_orbitals).times {|l| proj[:orbitals][l] *= @occupancies[j][i] / 2.0 }
      proj[:raw_total] = @weights[j] * @occupancies[j][i] /2.0
    end
    #pp proj; puts

    unless options[:precise]
      ## sum up orbitals; e.g, py + pz + px = p
      new_proj = Array.new
      proj.each do |band| #band
        orbital_sums = Array.new

        o = band[:orbitals]
        orbital_sums << o[0]
        orbital_sums << o[1] + o[2] + o[3]
        orbital_sums << o[4] + o[5] + o[6] + o[7] + o[8]
        orbital_sums << o[9] + o[10] + o[11] + o[12] + o[13] + o[14] + o[15] if f_orbital?
        new_proj << {
          :energy => band[:energy],
          :orbitals => orbital_sums,
          :raw_total => band[:raw_total]
        }
      end
      proj = new_proj
    end
    #pp proj ; exit

    ## min and max of energy in DOS.
    flat_energies = @energies.flatten.sort
    min_energy ||= left_foot_gaussian(flat_energies[0], sigma, tick)
    max_energy ||= right_foot_gaussian(flat_energies[-1], sigma, tick)

    division_x = ((max_energy - min_energy) / tick).round
    intensities = Array.new(division_x + 1).fill(0.0)


    proj.each do |i|
      p i
    end
    #pp proj
    #exit

    #HERE
    dos = broadening(proj, tick, sigma)

    if options[:precise]
    [ "s",
      "py", "pz", "px",
      "dxy", "dyz", "dz2", "dxz", "dx2",
      "f-3", "f-2", "f-1", "f0", "f1", "f2", "f3"]
    end


  end

  #def each_band(&block)
  #  num_spins.times do |s|
  #    num_kpoints.times do |k|
  #      num_bands.times do |b|
  #        yield @states[s][k][b]
  #      end
  #    end
  #  end
  #end

  private

  # Return minimum value on energy axis.
  # 'mu' is center of Gauss function.
  # 'sigma' is standard_deviation.
  # Choose left neighbor tick of the calculated foot.
  def left_foot_gaussian(mu, sigma, tick)
    min = mu - sigma * 10.0
    min = (min / tick).floor * tick
    return min
  end

  # Return maximum value on energy axis.
  # 'mu' is center of Gauss function.
  # 'sigma' is standard_deviation.
  # Choose right neighbor tick of the calculated foot.
  def right_foot_gaussian(mu, sigma, tick)
    max = mu + sigma * 10.0
    max = (max / tick).ceil * tick
    return max
  end



  #Sum up each orbital component for ions in 'ion_indices' 
  #for all k-points and bands.
  #Return an array of hashes;
  # outer array is all bands of all k-points.
  # inner array is all orbitals.
  #of each orbital component for ions in 'ion_indices' 
  def project_onto_energy(ion_indices) #old name: sum_ions()
    results = Array.new

    # sum up orbitals for ions
    @states[0].size.times do |k|          # for kpoints
      @states[0][0].size.times do |band|         # for band

        # initialize
        projected_orbitals = {}
        projected_orbitals[:energy] = @energies[k][band]
        #projected_orbitals[:weight] = @weights[k]
        projected_orbitals[:orbitals] = Array.new(num_orbitals).fill(0.0)

        ion_indices.each do |ion|
          num_orbitals.times do |orb|
            projected_orbitals[:orbitals][orb] += @states[0][k][band][ion-1][orb]
          end
        end

        (num_orbitals).times {|orb| projected_orbitals[:orbitals][orb] *= @weights[k] * 2.0}
        projected_orbitals[:raw_total] = @weights[k] * 2.0
        results << projected_orbitals
      end
    end

    results.sort_by{|i| i[:energy]}
  end


  # dE : tick
  # proj : projection
  # Energy を 
  def broadening(proj, dE, sigma = 0.1)
    results = Array.new
    (((proj[-1][0] - proj[0][0]) / dE).to_i + 2).times do |i|
      sumArray = Array.new(proj[0].size-1, 0) #each orbital
      energy = proj[0][0] + i*dE
      #STDERR.print("#{energy}\n")
      proj.each do |state|
        gauss = self.class.gauss_function(sigma, energy-state[0])
        sumArray.size.times do |j|
          sumArray[j] += state[j+1] * gauss
        end
      end
      results << [energy]+sumArray
    end

    #proj[:raw_total] もやる。
    results
  end

end

