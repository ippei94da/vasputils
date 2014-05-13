#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_ErrorFitter < Test::Unit::TestCase
    $tolerance = 1E-10

    def test_self_fit
        data = [
            {:ka => 1, :toten => - 6.0},
            {:ka => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(1.6, result.coefficients[0], $tolerance)

        data = [
            {:kb => 1, :toten => - 6.0},
            {:kb => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(1.6, result.coefficients[0], $tolerance)

        data = [
            {:kc => 1, :toten => - 6.0},
            {:kc => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(1.6, result.coefficients[0], $tolerance)

        data = [
            {:kab => 1, :toten => - 6.0},
            {:kab => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(32.0/17.0, result.coefficients[0], $tolerance)

        data = [
            {:kbc => 1, :toten => - 6.0},
            {:kbc => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(32.0/17.0, result.coefficients[0], $tolerance)

        data = [
            {:kca => 1, :toten => - 6.0},
            {:kca => 2, :toten => - 8.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(32.0/17.0, result.coefficients[0], $tolerance)

        data = [
            {:kabc => 1, :toten => - 8.0},
            {:kabc => 2, :toten => - 6.0},
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AXInv3, result.class)
        assert_equal(1, result.coefficients.size)
        assert_in_delta(128.0/65.0, result.coefficients[0], $tolerance)

        data = [
            {:encut => 0.0, :toten => 100.0 + 3.0* 2.0**(-2.0 *  0      )},
            {:encut => 1.0, :toten => 100.0 + 3.0* 2.0**(-2.0 * 1.0  ) },
            {:encut => 2.0, :toten => 100.0 + 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0)))},
            {:encut => 3.0, :toten => 100.0                     },
        ]
        result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        assert_equal(Malge::ErrorFittedFunction::AExpBX32, result.class)
        assert_in_delta(3.0, result.coefficients[0], $tolerance)
        assert_in_delta(- 2.0*Math::log(2.0), result.coefficients[1], $tolerance)


        data = [
            {:ka => 1, :toten => - 6.0},
            {:ka => 2, :toten => - 8.0},
            {:ka => 4, :toten => - 9.0},
            {:ka => 8, :toten => -10.0, :kb => 0},
        ]
        assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::HashKeyError){
            VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        }

        data = [
            {:ka => 1, :kb => - 6.0},
            {:ka => 2, :kb => - 8.0},
            {:ka => 4, :kb => - 9.0},
            {:ka => 8, :kb => -10.0},
        ]
        assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::NoTotenError){
            VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        }

        data = [
            {:encut => 100, :toten => - 3.0},
            {:encut => 200, :toten => - 7.0},
        ]
        assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::UnableCalculationError){
            VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        }

        data = [
            {:encut => 0.0, :toten => 100.0},
            {:encut => 1.0, :toten => 100.0},
            {:encut => 2.0, :toten => 100.0},
            {:encut => 3.0, :toten => 100.0},
        ]
        assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::UnableCalculationError){
            VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        }

        #data = [
        #    {:encut => 1000.0, :toten => -3.153327},
        #    {:encut => 1200.0, :toten => -3.150316},
        #    {:encut => 1500.0, :toten => -3.151397},
        #    {:encut =>  500.0, :toten => -3.112940},
        #    {:encut =>  600.0, :toten => -3.181593},
        #    {:encut =>  700.0, :toten => -3.165176},
        #    {:encut =>  900.0, :toten => -3.152733},
        #    {:encut =>  500.0, :toten => -3.112940},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #TODO


        #data = [
        #    {:ka => 1, :toten => - 6.0},
        #    {:ka => 2, :toten => - 8.0},
        #    {:ka => 4, :toten => - 9.0},
        #    {:ka => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        #assert_equal([4.0], result.coefficients)

        #data = [
        #    {:kb => 1, :toten => - 6.0},
        #    {:kb => 2, :toten => - 8.0},
        #    {:kb => 4, :toten => - 9.0},
        #    {:kb => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        #assert_equal([4.0], result.coefficients)

        #data = [
        #    {:kc => 1, :toten => - 6.0},
        #    {:kc => 2, :toten => - 8.0},
        #    {:kc => 4, :toten => - 9.0},
        #    {:kc => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv, result.class)
        #assert_equal([4.0], result.coefficients)

        #data = [
        #    {:kab => 1, :toten =>   6.0},
        #    {:kab => 2, :toten => - 6.0},
        #    {:kab => 4, :toten => - 9.0},
        #    {:kab => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        #assert_equal([16.0], result.coefficients)

        #data = [
        #    {:kbc => 1, :toten =>   6.0},
        #    {:kbc => 2, :toten => - 6.0},
        #    {:kbc => 4, :toten => - 9.0},
        #    {:kbc => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        #assert_equal([16.0], result.coefficients)

        #data = [
        #    {:kca => 1, :toten =>   6.0},
        #    {:kca => 2, :toten => - 6.0},
        #    {:kca => 4, :toten => - 9.0},
        #    {:kca => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv2, result.class)
        #assert_equal([16.0], result.coefficients)

        #data = [
        #    {:kabc => 1, :toten =>  54.0},
        #    {:kabc => 2, :toten => - 2.0},
        #    {:kabc => 4, :toten => - 9.0},
        #    {:kabc => 8, :toten => -10.0},
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AXInv3, result.class)
        #assert_equal([64.0], result.coefficients)

        #data = [
        #    {:encut => 0.0, :toten => 100.0 + 3.0* 2.0**(-2.0 *    0        )},
        #    {:encut => 1.0, :toten => 100.0 + 3.0* 2.0**(-2.0 * 1.0    ) },
        #    {:encut => 2.0, :toten => 100.0 + 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0)))},
        #    {:encut => 3.0, :toten => 100.0                     },
        #]
        #result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #assert_equal(Malge::ErrorFittedFunction::AExpBX32, result.class)
        #assert_in_delta(3.0, result.coefficients[0], $tolerance)
        #assert_in_delta(- 2.0*Math::log(2.0), result.coefficients[1], $tolerance)


        #data = [
        #    {:ka => 1, :toten => - 6.0},
        #    {:ka => 2, :toten => - 8.0},
        #    {:ka => 4, :toten => - 9.0},
        #    {:ka => 8, :toten => -10.0, :kb => 0},
        #]
        #assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::HashKeyError){
        #    VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #}

        #data = [
        #    {:ka => 1, :kb => - 6.0},
        #    {:ka => 2, :kb => - 8.0},
        #    {:ka => 4, :kb => - 9.0},
        #    {:ka => 8, :kb => -10.0},
        #]
        #assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::NoTotenError){
        #    VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #}

        #data = [
        #    {:encut => 100, :toten => - 3.0},
        #    {:encut => 200, :toten => - 7.0},
        #]
        #assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::UnableCalculationError){
        #    VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #}

        #data = [
        #    {:encut => 0.0, :toten => 100.0},
        #    {:encut => 1.0, :toten => 100.0},
        #    {:encut => 2.0, :toten => 100.0},
        #    {:encut => 3.0, :toten => 100.0},
        #]
        #assert_raise(VaspUtils::ConditionAnalyzer::ErrorFitter::UnableCalculationError){
        #    VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        #}

        ##data = [
        ##  {:encut => 1000.0, :toten => -3.153327},
        ##  {:encut => 1200.0, :toten => -3.150316},
        ##  {:encut => 1500.0, :toten => -3.151397},
        ##  {:encut =>  500.0, :toten => -3.112940},
        ##  {:encut =>  600.0, :toten => -3.181593},
        ##  {:encut =>  700.0, :toten => -3.165176},
        ##  {:encut =>  900.0, :toten => -3.152733},
        ##  {:encut =>  500.0, :toten => -3.112940},
        ##]
        ##result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
        ##TODO



    end

end

