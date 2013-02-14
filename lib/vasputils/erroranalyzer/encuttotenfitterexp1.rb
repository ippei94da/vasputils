#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
require "malge"
require "vasputils"

#
#
#
class VaspUtils::ErrorAnalyzer::EncutTotenFitterExp1
  #Argument 'data_pairs' is an array of [x_i, y_i].
  def initialize(data_pairs)
    @data_pairs = data_pairs
  end

  #Return [a, b] in 'y = a e^{bx}' fitted by least square method.
  #y is TOTEN, x is cutoff energy,
  #Assuming y[i_x_max] is true value, an array of [x_i, y_i] is mapped TOTEN
  #an array of [x_i, (y_i - y[i_x_max])] and delete last values.
  #Then, fitting to y = a e^{bx} will be done.
  def fit
    y_high = @data_pairs.max_by { |pair| pair[0] }[1]
    pairs = @data_pairs.map { |pair| [pair[0], Math::log((pair[1] - y_high).abs)] }
    pairs.delete_at -1

    coefficients = Malge::LeastSquare.least_square_1st_degree(pairs)
    coefficients[0] = Math::exp coefficients[0]
    coefficients
  end

  #Return expected error at each k-mesh using :fit method.
  def expected_errors
    coefficients = fit
    @data_pairs.map do |pair|
      [pair[0],
        coefficients[0] * Math::exp(coefficients[1] *pair[0])
      ]
    end
  end
end

