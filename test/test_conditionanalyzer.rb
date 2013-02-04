#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/conditionanalyzer.rb"

class TC_ConditionAnalyzer < Test::Unit::TestCase
  def setup
    @ca00 = ConditionAnalyzer.new
  end

end

