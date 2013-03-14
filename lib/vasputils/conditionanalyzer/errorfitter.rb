#! /usr/bin/env ruby
# coding: utf-8

require "pp"

#
#
#
module VaspUtils::ConditionAnalyzer::ErrorFitter

  class TypeError < Exception; end

  #
  #
  def self.fit(hashes)
    keys = hashes.map {|hash| hash.keys}.flatten.uniq
    raise TypeError, keys.to_a unless keys.size == 2
    raise TypeError, keys.to_a unless keys.include? :toten

    key = (keys - [:toten])[0]

    data = hashes.map do |hash|
      [hash[key], hash[:toten]]
    end

    case key
    when :ka, :kb, :kc
      return Malge::ErrorFittedFunction::AXInv.new(data)
    when :kab, :kbc, :kca
      return Malge::ErrorFittedFunction::AXInv2.new(data)
    when :kabc
      return Malge::ErrorFittedFunction::AXInv3.new(data)
    when :encut
      pp Malge::ErrorFittedFunction::AExpBX32.new(data)
      return Malge::ErrorFittedFunction::AExpBX32.new(data)
    else
      raise "Must not happen."
    end
  end

end


