#! /usr/bin/env ruby
# coding: utf-8

require "find"

class Hash
  #Return true if all keys and values are parfectly included in other.
  def partial_of?(other)
    self.each do |key, val|
      return false unless val == other[key]
    end
    return true
  end

  class MismatchError < Exception; end

  def -(other)
    raise MismatchError unless other.partial_of? self
    results = Marshal.load(Marshal.dump(self))
    other.keys.each do |key|
      results.delete key
    end
    return results
  end
end

#
#
#
class VaspUtils::ConditionAnalyzer::Holder

  attr_reader :conds_results, :keys

  class KeysMismatchError < Exception; end

  #Setup an empty instance.
  #Argument 'keys' indicates allowed hash-keys to "add" method..
  def initialize(keys)
    @keys = keys
    @conds_results = []
  end

  def self.load_dir(dir, symprec, angle_tolerance)
    conds_results = []
    Find.find(dir) do |path|
      #pp path
      begin
        conds_results << VaspUtils::ConditionAnalyzer::Picker.pick(path, symprec, angle_tolerance)
      rescue VaspUtils::ConditionAnalyzer::Picker::InitializeError
        next
      end
    end
    results = self.new(conds_results[0].keys)
    conds_results.each do |cr|
      results.add cr
    end
    results
  end

  #Add entry.
  def add(cond_result)
    raise KeysMismatchError unless cond_result.keys == @keys
    @conds_results << cond_result
  end

  #Make projection of fixed condition as 'fixed_conds'.
  #Return Array of Hash of residual keys and values.
  def project(fixed_conds)
    results = []
    @conds_results.each do |cond_result|
      begin
        results << cond_result - fixed_conds
      rescue Hash::MismatchError
        next
      end
    end
    return results
  end
end

