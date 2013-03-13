#! /usr/bin/env ruby
# coding: utf-8

require "helper"

class TC_Picker < Test::Unit::TestCase
  #def setup
  #  @cap00 = ConditionAnalyzer::Picker.new
  #end

  def test_pick
    corrects = {
      :encut => 400,
      :kabc => 4,
      :toten => -15.642518
    }
    results = VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-cubic")
    assert_equal(corrects, results)

    corrects = {
      :encut => 400,
      :kac => 4,
      :kb => 2,
      :toten => -15.642518
    }
    results = VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-tetragonal-b")
    assert_equal(corrects, results)

    assert_raise( VaspUtils::ConditionAnalyzer::Picker::InitializeError) {
      VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-unfinished")
    }

    assert_raise( VaspUtils::ConditionAnalyzer::Picker::InitializeError) {
      VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/not_vaspdir")
    }

  end

end

