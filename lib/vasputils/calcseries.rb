#! /usr/bin/env ruby
# coding: utf-8

require "vasputils/vaspdir.rb"

# 連続性のある一連の計算を表現するクラス。
# 収束までに何度も繰り返すような計算を想定し、
# これらが1つのディレクトリにまとめられていることを前提とする。
# 計算は ASCII ソートできる順に
# 名前が付けられていることを前提とする。
class CalcSeries

	class FinishedCalcError < Exception; end

	#
	def initialize(dir)
		@dir = dir
		@calculations = belonged_calculations
	end

	# Guess and return calculation type of an rgument 'file'.
	# Argument 'file' can be a normal file or a directory.
	# Return a calc class instance, e.g., VaspDir.
	# If the file is unknown type, raise CalcSeriesUnknownCalcError 
	#
	# MEMO: Now, always return VaspDir.
	def self.guess(file)
		return VaspDir
	end

	# Return the final calculation that achieve to be convergence,
	# whose state is FINISHED.
	# If there are multiple FINISHED calcs,
	# raise CalcSeriesMultipleFinishedError.
	# If there is no FINISHED calcs, return nil.
	def finished_calc
		#tmp = @calculations.select{|calc| calc.normal_ended? && (! calc.to_be_continued?)}
		tmp = @calculations.select{|calc| (! calc.to_be_continued?)}
		#pp tmp.size
		if tmp.size > 1
			message = "Multiplicated finished calcs; #{tmp.map{|calc| calc.name}.join(', ')}"
			raise FinishedCalcError, message
		elsif tmp.size == 0
			message = "No finished calc."
			raise FinishedCalcError, message
		else
			return tmp[0]
		end
	end

	# Return sum of number of 'internal steps',
	# whish is returned by 'internal_steps' of each calculation.
	# E.g., in case of VaspDir/try01, try02,...
	#   internal_steps of VaspDir/try01 was 10, 
	#   internal_steps of VaspDir/try02 was 3, 
	def internal_steps
		@calculations.inject(0.0) do |sum, item|
			sum += item.internal_steps
		end
	end

	# 外部ループ。
	# vaspdir では ionic steps を返す筈。
	def external_steps
		@calculations.inject(0.0) do |sum, item|
			sum += item.external_steps
		end
	end

	# 全ての経過時間の合計を返す。
	def elapsed_time
		@calculations.inject(0.0) do |sum, item|
			sum += item.elapsed_time
		end
	end

	# 最後の計算が normal_ended ならば true。
	# それ以外は false
	def normal_ended?
		begin
			#pp finished_calc
			return finished_calc.normal_ended?
		rescue FinishedCalcError
			return false
		end
	end

	private

	# 配下の calculation を VaspDir のようなインスタンスにし、
	# それらをまとめた配列を返す。
	def belonged_calculations
		Dir.glob("#{@dir}/*").sort.map do |file|
			self.class.guess(file).new(file)
		end
	end
end

