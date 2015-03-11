#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_VaspDummy < Test::Unit::TestCase
    def setup
        @vd00 = VaspUtils::VaspDir.new
    end
end
