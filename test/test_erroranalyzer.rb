#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer.rb"

class TC_ErrorAnalyzer < Test::Unit::TestCase
  def setup
    @ea00 = ErrorAnalyzer.new
  end

end

