#!/usr/bin/ruby -w

# class for parsing PROCAR
#
# First written by Atsushi Togo, <2006-07-31 22:54:10 togo>
# Modified by Ippei Kishdia 

#raw_total というのはたぶん、PROCAR に出てくる tot とは関係なく、
#k点の重みとバンドエネルギーだけで出せる DOS だと思う。
#


class VaspUtils::Procar
  attr_reader :energies, :num_bands, :num_ions,
    :num_kpoints, :occupancies, :states, :weights

  ## factor of sigma to ignore small value of foot of Gauss function. 
  GAUSS_WIDTH_FACTOR = 10.0

  def initialize(states, energies, occupancies, weights)
    @states      = states
    @energies    = energies
    @occupancies = occupancies
    @weights     = weights
    #pp @energies;
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
      energies_for_spin = []
      occupancies_for_spin = []

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
        occupancies_for_spin << occupancies_for_bands
        energies_for_spin << energies_for_bands
        states_for_spin << states_for_bands
      end
      occupancies << occupancies_for_spin unless occupancies_for_spin.empty?
      energies << energies_for_spin unless energies_for_spin.empty?
      states << states_for_spin unless states_for_spin.empty?
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

  # Return an array of Density of States(DOS) data.
  # The array is a duplex array.
  #   Outer: every energy points of tick.
  #   Inner: [energy, orbital1, orbital2, ..., raw_total]
  # If options[:precise] is true, then precise orbitals (py, pz, px, etc) are
  # dividedly outputed.
  # If options[:occupancy] is true, each band component is substituted to occupation.
  def density_of_states(ion_indices, options)
    doses = Array.new(num_spins)
    @states.size.times do |spin_index|
      doses[spin_index] = dos_for_spin(ion_indices, options, spin_index)
    end
    
    pp doses
    HERE
    if options[:down]
    end
  end

  def dos_labels(options)
    results = []
    results << 'eigenvalue'

    if options[:precise]
      s = ['s']
      p = ['py', 'pz', 'px']
      d = ['dxy', 'dyz', 'dz2', 'dxz', 'dx2']
      f = ['f-3', 'f-2', 'f-1', 'f0', 'f1', 'f2', 'f3']
    else
      s = ['s']
      p = ['p']
      d = ['d']
      f = ['f']
    end

    results << s + p + d
    results << f if f_orbital?
    results << 'raw_total'
    results.flatten
  end

  private

  def dos_for_spin(ion_indices, options, spin_index)
    proj = project_onto_energy(spin_index, ion_indices)

    ## num_spin==1 && occupancy==true :   0〜2
    ## num_spin==2 && occupancy==true :   0〜1
    ## num_spin==1 && occupancy==false:   0〜2
    ## num_spin==2 && occupancy==false:   0〜1
    #
    #pp @occupancies; exit
    #if options[:occupancy] == true
    #  (num_orbitals).times {|l| proj[:orbitals][l] *= @occupancies[spin_index][i] }
    #  proj[:raw_total] *= @occupancies[j][i]
    #end
    if num_spins == 1
      (num_orbitals).times {|l| proj[:orbitals][l] *= 2.0}
      proj[:raw_total] *=  2.0
    end

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

    broadening(proj, options)
  end


  # Return minimum value on energy axis.
  # 'mu' is center of Gauss function.
  # 'sigma' is standard_deviation.
  # Choose left neighbor tick of the calculated foot.
  def left_foot_gaussian(mu, sigma, tick)
    min = mu - sigma * GAUSS_WIDTH_FACTOR
    min = (min / tick).floor * tick
    return min
  end

  # Return maximum value on energy axis.
  # 'mu' is center of Gauss function.
  # 'sigma' is standard_deviation.
  # Choose right neighbor tick of the calculated foot.
  def right_foot_gaussian(mu, sigma, tick)
    max = mu + sigma * GAUSS_WIDTH_FACTOR
    max = (max / tick).ceil * tick
    return max
  end


  #Sum up each orbital component for ions in 'ion_indices' 
  #for all k-points and bands.
  #Return an array of hashes;
  # outer array is all bands of all k-points.
  # inner array is all orbitals.
  #of each orbital component for ions in 'ion_indices' 
  def project_onto_energy(spin_index, ion_indices) #old name: sum_ions()
    results = Array.new
    #pp @states;exit

    # sum up orbitals for ions
    @states[spin_index].size.times do |k|          # for kpoints
      @states[spin_index][0].size.times do |band|  # for band

        # initialize
        proj_orbs = {} # projected_orbitals
        proj_orbs[:energy] = @energies[spin_index][k][band]
        #proj_orbs[:weight] = @weights[spin_index][k]
        proj_orbs[:orbitals] = Array.new(num_orbitals).fill(0.0)

        ion_indices.each do |ion|
          num_orbitals.times do |orb|
            proj_orbs[:orbitals][orb] += @states[spin_index][k][band][ion-1][orb]
          end
        end
        #pp proj_orbs

        ## not multiply 2.0 here.
        (num_orbitals).times {|orb| proj_orbs[:orbitals][orb] *= @weights[k]}
        proj_orbs[:raw_total] = @weights[k]
        results << proj_orbs
      end
    end
    #pp results

    results.sort_by{|i| i[:energy]}
  end


  # dE : tick
  # proj : projection
  # Energy を 
  def broadening(proj, options)
    tick       = options[:tick]
    sigma      = options[:sigma]
    min_energy = options[:min_energy]
    max_energy = options[:max_energy]

    ### min and max of energy in DOS.
    flat_energies = proj.map {|i| i[:energy]}.sort

    min_energy ||= left_foot_gaussian(flat_energies[0], sigma, tick)
    max_energy ||= right_foot_gaussian(flat_energies[-1], sigma, tick)
    energy_width = max_energy - min_energy
    division_x = (energy_width / tick).round
    num_points = division_x + 1 #for energy points
    num_orb = proj[0][:orbitals].size

    results = Array.new(num_points)
    (num_points).times do |i|
      cur_energy = min_energy + energy_width * (i.to_f / division_x.to_f)

      orbital_sums = Array.new(num_orb).fill(0.0) #each orbital
      raw_total_sum = 0.0
      proj.each do |band|
        next if (cur_energy - band[:energy]).abs > sigma * GAUSS_WIDTH_FACTOR
          ## To speed up.

        gauss = self.class.gauss_function(sigma, cur_energy - band[:energy])
        band[:orbitals].size.times do |j|
          orbital_sums[j] += band[:orbitals][j] * gauss
        end
        raw_total_sum += band[:raw_total] * gauss
      end
      results[i] = [cur_energy] + orbital_sums + [raw_total_sum]
    end
    results

  end

end

