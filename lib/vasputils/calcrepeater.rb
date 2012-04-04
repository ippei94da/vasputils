#! /usr/bin/env ruby
# coding: utf-8

require "pp"
#
#
#
class CalcRepeater

	#def initialize
	#end

	# 引数 calc は以下のメソッドを持っている必要がある。
	def repeat(calc, io = STDOUT)
		while true
			io.puts "Calculation started: #{calc.name}."
			calc.calculate
			break unless calc.normal_ended?
			break unless calc.to_be_continued?
			calc.next
			io.puts "Next to #{calc.name}."
		end
		calc.teardown
		puts "Calculation got converged: #{calc.name}."
	end
end

