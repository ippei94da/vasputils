#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "stringio"
require "vasputils/calcrepeater.rb"

#	assert_equal( cor, data)
#	assert_in_delta( cor, data, $tolerance )
#	assert_raise( RuntimeError ){}

class DummyCalc
	attr_reader :num

	def initialize
		@num = 0
		@internal_steps = 0
		@lock = false
	end

	def calculatable?
		return (! @lock)
	end

	def calculate
		@lock = true
		# calculate
		10.times { @internal_steps += 1 }
	end

	def normal_ended?
		return @internal_steps == 10
	end

	def to_be_continued?
		return @num < 3
	end

	def next
		@num += 1
		@lock = false
		@internal_steps = 0
	end

	def teardown
		# do nothing
	end

	def name
		"calc00"
	end
end

class TC_CalcRepeater < Test::Unit::TestCase
	def setup
		@cr00 = CalcRepeater.new
		@dc00 = DummyCalc.new
	end

	def test_repeat
		io = StringIO.new
		assert_equal(0, @dc00.num)
		@cr00.repeat(@dc00, io)
		assert_equal(3, @dc00.num)
	end


end

