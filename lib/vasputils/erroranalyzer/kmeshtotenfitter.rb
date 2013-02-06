#! /usr/bin/env ruby
# coding: utf-8

require "vasputils.rb"
require "vasputils/erroranalyzer.rb"
require "rubygems"
require "malge"

#
#
#
class VaspUtils::ErrorAnalyzer::KmeshTotenFitter
  #
  def initialize(data_pairs)
    @data_pairs = data_pairs
  end

  #Return total number of kpoints in k-mesh. E.g.,
  # total_kpoints([1,2,5]) => 10
  def self.total_kpoints(mesh)
    return mesh[0] * mesh[1] * mesh[2]
  end

  #Fit to the equation belowby least square method.
  #|E_t - a_0| = a_1 / n_k,
  #where E_t is TOTEN, n_k is number of kpoints,
  #and a_0 and a_1 is coefficient to be returned.
  def fit
    highest_pair = @data_pairs.max_by do |pair|
      self.class.total_kpoints pair[0]
    end
    highest_toten = highest_pair[1]

    pairs = @data_pairs.map do |pair|
      n_k = 1.0 / self.class.total_kpoints(pair[0])
      raw_toten = pair[1]
      toten = (raw_toten - highest_toten).abs
      [n_k, toten]
    end
    coefficients = Malge::LeastSquare.least_square_1st_degree(pairs)
    coefficients[0] += highest_toten
    coefficients
  end

  #Return expected error at each k-mesh using :fit method.
  def expected_errors
    coefficients = fit
    @data_pairs.map do |pair|
      n_k = self.class.total_kpoints(pair[0])
      [pair[0], coefficients[1] *(1.0/n_k.to_f)]
    end
  end
end

