#! /usr/bin/env ruby
# coding: utf-8

require "helper"

class TC_Picker < Test::Unit::TestCase
    $symprec = 1.0e-5
    $angle_tolerance = -1.0
    #def setup
    #    @cap00 = ConditionAnalyzer::Picker.new
    #end

    def test_pick
        corrects = {
            :encut => 400.0,
            :kabc => 4,
            :toten => -15.642518
        }
        results = VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-cubic", $symprec, $angle_tolerance)
        assert_equal(corrects, results)

        corrects = {
            :encut => 400.0,
            :kca => 4,
            :kb => 2,
            :toten => -15.642518
        }
        results = VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-tetragonal-b", $symprec, $angle_tolerance)
        assert_equal(corrects, results)

        corrects = {
            :encut => 500.0,
            :kab => 4,
            :kc => 4,
            :toten => -3.112940
        }
        results = VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/hexiagonal", $symprec, $angle_tolerance)
        assert_equal(corrects, results)

        assert_raise( VaspUtils::ConditionAnalyzer::Picker::InitializeError) {
            VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/encut400_k444-unfinished", $symprec, $angle_tolerance)
        }

        assert_raise( VaspUtils::ConditionAnalyzer::Picker::InitializeError) {
            VaspUtils::ConditionAnalyzer::Picker.pick( "test/conditionanalyzer/picker/not_vaspdir", $symprec, $angle_tolerance)
        }

    end

end

