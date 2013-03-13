#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class VaspUtils::ConditionAnalyzer::Analyzer
  #
  def initialize(dir)
    @holder = VaspUtils::ConditionAnalyzer::Holder.new
    Find.find(dir) do |path|
      cond_result = VaspUtils::ConditionAnalyzer::Picker.pick(path)
      @holder.add { cond_result }
    end
  end

  def expected_error(conds)

  end
end

