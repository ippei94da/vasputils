#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
require "malge"
require "vasputils"

#
#
#
class VaspUtils::ErrorAnalyzer::EncutTotenFitterExp
  #
  def initialize(data_pairs)
    @data_pairs = data_pairs
  end

  #Fit to the equation belowby least square method.
  #|E_t - a_0| = a_1 / E_c,
  #where E_t is TOTEN, E_c is cutoff energy,
  #and a_0 and a_1 is coefficient to be returned.
  def fit
    highest_pair = @data_pairs.max_by do |pair|
      pair[0]
    end
    highest_toten = highest_pair[1]

    pairs = @data_pairs.map do |pair|
      inv_cutoff = 1.0/pair[0].to_f
      raw_toten = pair[1]
      toten = (raw_toten - highest_toten).abs
      [inv_cutoff, toten]
    end
    coefficients = Malge::LeastSquare.least_square_1st_degree(pairs)
    coefficients[0] += highest_toten
    coefficients
  end

  #Return expected error at each k-mesh using :fit method.
  def expected_errors
    coefficients = fit
    @data_pairs.map do |pair|
      [pair[0], coefficients[1] *(1.0/ pair[0].to_f)]
    end
  end
end

