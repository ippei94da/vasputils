#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "stringio"
require "vasputils.rb"
require "vasputils/kpoints.rb"

class TC_Kpoints < Test::Unit::TestCase

    $tolerance = 1E-10

    def setup
        @k00 = VaspUtils::Kpoints.load_file('test/kpoints/g123-456')
        @k01 = VaspUtils::Kpoints.load_file('test/kpoints/m123-456')
        @k02 = VaspUtils::Kpoints.load_file('test/kpoints/bench.Hg')
    end

    def test_reader
        assert_equal("Automatic mesh", @k00.comment   )
        assert_equal(:automatic      , @k00.scheme    )
        assert_equal([1, 2, 3]       , @k00.mesh      )
        assert_equal([0.4, 0.5, 0.6] , @k00.shift     )
        assert_equal(:gamma_center   , @k00.type      )
        assert_equal('1,2,3'         , @k00.size_str    )

        assert_equal("Automatic mesh", @k01.comment   )
        assert_equal(:automatic      , @k01.scheme    )
        assert_equal([1, 2, 3]       , @k01.mesh      )
        assert_equal([0.4, 0.5, 0.6] , @k01.shift     )
        assert_equal(:monkhorst      , @k01.type      )
        assert_equal('1,2,3'         , @k00.size_str    )

        assert_equal("K dimer"       , @k02.comment   )
        assert_equal(:explicit       , @k02.scheme    )
        assert_equal(nil             , @k02.mesh      )
        assert_equal([[0.0, 0.0, 0.0, 1.0]], @k02.points    )
        assert_equal(nil             , @k02.shift     )
        assert_equal(nil             , @k02.type      )
        assert_equal('1'             , @k02.size_str    )
    end


    #def test_self_parse
    #    io = StringIO.new
    #    io.puts "Automatic mesh"
    #    io.puts "0"
    #    io.puts "Monkhorst Pack"
    #    io.puts "    1  2    3"
    #    io.puts "    0.4    0.5  0.6"
    #    io.rewind
    #    k00 = VaspUtils::Kpoints.parse(io)
    #    assert_equal("Automatic mesh", k00[:comment])
    #    assert_equal(:monkhorst, k00[:type])
    #    assert_equal([1, 2, 3], k00[:mesh])
    #    #pp k00
    #    assert_in_delta(0.4, k00[:shift][0], $tolerance)
    #    assert_in_delta(0.5, k00[:shift][1], $tolerance)
    #    assert_in_delta(0.6, k00[:shift][2], $tolerance)

    #    io = StringIO.new
    #    io.puts "Automatic mesh"
    #    io.puts "0"
    #    io.puts "Gamma-Center"
    #    io.puts "    1  2    3"
    #    io.puts "    0.4    0.5  0.6"
    #    io.rewind
    #    k01 = VaspUtils::Kpoints.parse(io)
    #    assert_equal("Automatic mesh", k01[:comment])
    #    assert_equal(:gamma_center, k01[:type])
    #    assert_equal([1, 2, 3], k01[:mesh])
    #    assert_in_delta(0.4, k01[:shift][0])
    #    assert_in_delta(0.5, k01[:shift][1])
    #    assert_in_delta(0.6, k01[:shift][2])
    #end

    #def test_self_load_file
    #    k00 = VaspUtils::Kpoints.load_file("test/kpoints/m123-456")
    #    assert_equal("Automatic mesh", k00[:comment])
    #    assert_equal(:monkhorst, k00[:type])
    #    assert_equal([1, 2, 3], k00[:mesh])
    #    assert_in_delta(0.4, k00[:shift][0])
    #    assert_in_delta(0.5, k00[:shift][1])
    #    assert_in_delta(0.6, k00[:shift][2])

    #    k01 = VaspUtils::Kpoints.load_file("test/kpoints/g123-456")
    #    assert_equal("Automatic mesh", k01[:comment])
    #    assert_equal(:gamma_center, k01[:type])
    #    assert_equal([1, 2, 3], k01[:mesh])
    #    assert_in_delta(0.4, k01[:shift][0])
    #    assert_in_delta(0.5, k01[:shift][1])
    #    assert_in_delta(0.6, k01[:shift][2])
    #end

    def test_dump
        hash = {
            :comment => "Automatic mesh",
            :type => :monkhorst,
            :mesh => [1, 2, 3],
            :shift => [0.4, 0.5, 0.6],
        }
        io = StringIO.new
        VaspUtils::Kpoints.new(hash).dump(io)
        io.rewind
        results = io.readlines
        corrects = [
            "Automatic mesh\n",
            "0\n",
            "Monkhorst\n",
            "1 2 3\n",
            "0.4 0.5 0.6\n",
        ]
        corrects.each_with_index do |line, index|
            assert_equal(line, results[index], "line #{index + 1}")
        end
        assert_equal(corrects.size, results.size)

        hash = {
            :comment => "Automatic mesh",
            :type => :gamma_center,
            :mesh => [1, 2, 3],
            :shift => [0.4, 0.5, 0.6],
        }
        io = StringIO.new
        VaspUtils::Kpoints.new(hash).dump(io)
        io.rewind
        results = io.readlines
        corrects = [
            "Automatic mesh\n",
            "0\n",
            "Gamma_center\n",
            "1 2 3\n",
            "0.4 0.5 0.6\n",
        ]
        corrects.each_with_index do |line, index|
            assert_equal(line, results[index], "line #{index + 1}")
        end
        assert_equal(corrects.size, results.size)
    end


end

