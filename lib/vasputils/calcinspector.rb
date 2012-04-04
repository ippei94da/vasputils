#! /usr/bin/env ruby
# coding: utf-8

# 計算の状態を解析するクラス。
class CalcInspector
	#
	#def initialize
	#end

	# 引数 calc で渡された計算の状態を返す。
	# calc は以下のメソッドを持つ必要がある。
	#   - started?
	#   - normal_ended?
	#   - to_be_continued?
	def self.inspect(calc)
		return "YET"       unless calc.started?
		return "STARTED"   unless calc.normal_ended?
		return "NEXT"      if     calc.to_be_continued?
		return "FINISHED"
		#raise "must not occur"
	end

end

