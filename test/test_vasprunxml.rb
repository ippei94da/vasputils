#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_VasprunXml < Test::Unit::TestCase
    def setup
        #@v00 = VaspUtils::VasprunXml.new
        @v00 = VaspUtils::VasprunXml.load_file('test/vasprunxml/singlepoint.xml')
        @v01 = VaspUtils::VasprunXml.load_file('test/vasprunxml/geomopt.xml')
    end

    def test_load_file
        correct = [
            [ 327.28361242,   -291.24674632,      0.00000000],
            [-291.24674632,    327.28361242,      0.00000000],
            [   0.00000000,      0.00000000,     28.53476763],
        ]
        assert_equal(correct, @v00.stress)

        correct = [
            [-1.90067153,     -0.00000000,     -0.00000000],
            [ 0.00000000,     -1.90067153,      0.00000000],
            [-0.00000000,      0.00000000,     -1.90067153],
        ]
        assert_equal(correct, @v01.stress)
    end
end

