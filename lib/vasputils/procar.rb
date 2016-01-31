#!/usr/bin/ruby -w

# class for parsing PROCAR
#
# First written by Atsushi Togo
#   Time-stamp: <2006-07-31 22:54:10 togo>
# Modified by Ippei Kishdia 


#require 'tanakalab/broadning.rb' つかってなさそう。

class VaspUtils::Procar
  attr_reader :energies, :num_bands, :num_ions,
    :num_kpoints, :occupancies, :states, :weights

  def initialize( energies, num_bands, num_ions, num_kpoints, occupancies, states, weights)
    @energies    = energies
    @num_bands   = num_bands
    @num_ions    = num_ions
    @num_kpoints = num_kpoints
    @occupancies = occupancies
    @states      = states
    @weights      = weights
  end

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
          #pp line
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
          #io.gets if @fOrbital
          (num_ions * 2).times {io.gets}
          io.gets
          states_for_bands << states_for_ions
        end
        occupancies << occupancies_for_bands
        energies << energies_for_bands
        states_for_spin << states_for_bands
      end
      states << states_for_spin
      #pp occupancies
      #pp energies
      #pp states
      #pp self.new(energies, num_bands, num_ions, num_kpoints, occupancies, states, weights)
      #pp io.gets
      io.gets
    end
    io.close
    #pp self.new(energies, num_bands, num_ions, num_kpoints, occupancies, states, weights)
    self.new(energies, num_bands, num_ions, num_kpoints, occupancies, states, weights)
  end

  def getNumEnergies
    @energies.size * @energies[0].size
  end

  def f_orbital?
    #pp @states[0][0][0][0].size
    result = false
    result = true if 16 == @states[0][0][0][0].size
    result
  end

  def get_all(occupy = false)
    ion_indices = Array.new
    @states[0][0].size.times {|i| ion_indices << i+1}
    projection(ion_indices, occupy)
  end

  def header
    sprintf("# k-points: #{@states.size}  bands: #{@states[0].size}  ions: #{@states[0][0].size}\n")
  end

  def density_of_states(ion_indices, tick, sigma)
    proj = projection(ion_indices)

    states = Array.new
    proj.each do |a|
      p = a[2] + a[3] + a[4]
      d = a[5] + a[6] + a[7] + a[8] + a[9]
      f = a[10] + a[11] + a[12] + a[13] + a[14] + a[15] + a[16] if @f_orbital
      if @f_orbital
        states << [a[0], a[1], p, d, f, a[10]] if @f_orbital
      else
        states << [a[0], a[1], p, d, a[10]]
      end
    end
    #pp proj
    #pp states
    exit
    dos = broadning(states, tick, sigma)

  end

  private

  #Sum up each orbital component for ions in 'ion_indices' 
  #for all k-points and bands.
  #Return an duplex array;
  # outer array is all bands of all k-points.
  # inner array is all orbitals.
  #of each orbital component for ions in 'ion_indices' 
  #def sum_ions(ion_indices, occupy = false)
  def projection(ion_indices, occupy = false)
    results = Array.new
    @states[0][0].size.times do |i|         # for band
      @states[0].size.times do |j|          # for kpoints
        projected_orbitals = {}

        #num_items = 9
        #num_items = 16 if @fOrbital
        #sumState = Array.new(num_items, 0)

        ion_indices.each do |k|
          projected_orbitals[:energy] = @energies[j][i]
          (num_items).times do |l|
            sumState[l] += @states[0][j][i][k-1][l]
          end
        end

        if occupy == true
          (num_items).times {|l| sumState[l] *= @occupancies[j][i] * @weights[j]}
          total = @occupancies[j][i] * @weights[j]
        else
          (num_items).times {|l| sumState[l] *= @weights[j] * 2}
          total = @weights[j] * 2
        end
        results << [@energies[j][i]] + sumState + [total]
      end
    end
    results.sort!
    pp results
    results
  end


  def gaussFunction(deviation,sigma)
    1/sigma/Math.sqrt(2*Math::PI)*Math.exp(-deviation**2/(2*sigma**2))
  end

  # dE : tick
  def broadning(projection, dE, sigma = 0.1)
    results = Array.new
    #pp projection;exit
    (((projection[-1][0] - projection[0][0]) / dE).to_i + 2).times do |i|
      sumArray = Array.new(projection[0].size-1, 0) #each orbital
      #pp sumArray;exit
      energy = projection[0][0] + i*dE
      #STDERR.print("#{energy}\n")
      projection.each do |state|
        #pp state; exit

        gauss = gaussFunction(energy-state[0], sigma)
        sumArray.size.times do |j|
          sumArray[j] += state[j+1] * gauss
        end
      end
      results << [energy]+sumArray
    end
    #pp results; exit
    results
  end


end

