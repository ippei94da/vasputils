#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/calcseries.rb"

class CalcSeries
	public :belonged_calculations
end

class TC_CalcSeries < Test::Unit::TestCase
	def setup
		@cs00 = CalcSeries.new("test/calcseries/dup_finished"   )
		@cs01 = CalcSeries.new("test/calcseries/normal_finished")
		@cs02 = CalcSeries.new("test/calcseries/not_finished"   )
	end

	def test_self_guess
		assert_equal(VaspDir, CalcSeries.guess("test/calcseries/dup_finished"    ))
		assert_equal(VaspDir, CalcSeries.guess("test/calcseries/normal_finished"))
		assert_equal(VaspDir, CalcSeries.guess("test/calcseries/not_finished"    ))
	end

	def test_finished_calc
		assert_raise(CalcSeries::FinishedCalcError){@cs00.finished_calc}
		assert_equal("test/calcseries/normal_finished/try01", @cs01.finished_calc.name)
		assert_raise(CalcSeries::FinishedCalcError){@cs02.finished_calc}
	end

#	def test_internal_steps
#		assert_equal(26, @cs00.internal_steps)
#		assert_equal(36, @cs01.internal_steps)
#		assert_equal(23, @cs02.internal_steps)
#	end
#
#	def test_external_steps
#		assert_equal(2, @cs00.external_steps)
#		assert_equal(4, @cs01.external_steps)
#		assert_equal(3, @cs02.external_steps)
#	end
#
#	def test_elapsed_time
#		assert_in_delta(328.268, @cs00.elapsed_time)
#		assert_in_delta(328.268, @cs01.elapsed_time)
#		assert_in_delta(164.134, @cs02.elapsed_time)
#	end
#
#	def test_belonged_calculations
#		t = @cs00.belonged_calculations
#		assert_equal(2, t.size)
#		assert_equal(VaspDir, t[0].class)
#		assert_equal(VaspDir, t[1].class)
#		#pp t
#		assert_equal("test/calcseries/dup_finished/try00", t[0].name)
#		assert_equal("test/calcseries/dup_finished/try01", t[1].name)
#
#		t = @cs01.belonged_calculations
#		assert_equal(2, t.size)
#		assert_equal(VaspDir, t[0].class)
#		assert_equal(VaspDir, t[1].class)
#		assert_equal("test/calcseries/normal_finished/try00", t[0].name)
#		assert_equal("test/calcseries/normal_finished/try01", t[1].name)
#
#		t = @cs02.belonged_calculations
#		assert_equal(1, t.size)
#		assert_equal(VaspDir, t[0].class)
#		assert_equal("test/calcseries/not_finished/try00", t[0].name)
#	end
#
#	def test_normal_ended?
#		assert_equal(false, @cs00.normal_ended?)
#		assert_equal(true , @cs01.normal_ended?)
#		assert_equal(false, @cs02.normal_ended?)
#	end

end

