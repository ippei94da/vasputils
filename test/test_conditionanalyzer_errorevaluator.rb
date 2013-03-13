#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_ErrorEvaluator < Test::Unit::TestCase
  #def setup
  #  @ee00 = VaspUtils::ConditionAnalyzer::ErrorEvaluator.new
  #end

  def test_self_evaluate_k1_totens

    data = [
      {:ka => 1, :toten => - 6.0},
      {:ka => 2, :toten => - 8.0},
      {:ka => 4, :toten => - 9.0},
      {:ka => 8, :toten => -10.0},
    ]
    results = VaspUtils::ConditionAnalyzer::ErrorEvaluator.evaluate_k1_totens(data)
    corrects = 

  end

end

