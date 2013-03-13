#! /usr/bin/env ruby
# coding: utf-8

require "helper"

class TC_Analyzer < Test::Unit::TestCase
  def setup
    @a00 = VaspUtils::ConditionAnalyzer::Analyzer.new(dir)
  end

end

