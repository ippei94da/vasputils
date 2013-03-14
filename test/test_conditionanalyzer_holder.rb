#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"


class VaspUtils::ConditionAnalyzer::Holder
  attr_reader :keys
  attr_reader :conds_results
end

class TC_Hash < Test::Unit::TestCase
  def setup
    @h00 = {:a => 0, :b => 1, :c => 2}
    @h01 = {:a => 0, :b => 1         }
    @h02 = {:a => 0, :b => 2         }
    @h03 = {:a => 0,          :c => 2}
  end

  def test_partial_of?
    assert_equal(true , @h01.partial_of?(@h00))
    assert_equal(false, @h02.partial_of?(@h00))
    assert_equal(true , @h03.partial_of?(@h00))
    assert_equal(false, @h00.partial_of?(@h01))
    assert_equal(false, @h00.partial_of?(@h02))
    assert_equal(false, @h00.partial_of?(@h03))
  end

  def test_minus
    assert_equal({:c => 2}, @h00 - @h01)
    assert_equal({:b => 1}, @h00 - @h03)

    assert_raise(Hash::MismatchError){ @h00 - @h02 }
    assert_raise(Hash::MismatchError){ @h01 - @h00 }
    assert_raise(Hash::MismatchError){ @h02 - @h00 }
    assert_raise(Hash::MismatchError){ @h03 - @h00 }
  end
end


class TC_Holder < Test::Unit::TestCase
  $symprec = 1.0E-5
  $angle_tolerance = -1.0

  def setup
    @h00 = VaspUtils::ConditionAnalyzer::Holder.new([:kab, :kc, :encut, :toten])
  end

  def test_add
    @h00.add({:kab => 4, :kc => 2, :encut => 400, :toten => -12.34})
    @h00.add({:kab => 4, :kc => 2, :encut => 500, :toten => -12.45})
    assert_equal(
      [
        {:kab => 4, :kc => 2, :encut => 400, :toten => -12.34},
        {:kab => 4, :kc => 2, :encut => 500, :toten => -12.45},
      ],
      @h00.conds_results)

    assert_raise(VaspUtils::ConditionAnalyzer::Holder::KeysMismatchError){
      @h00.add({:kabc => 2, :encut => 400, :toten => -12.34})
    }
  end

  def test_project
    @h00.add({:kab => 1, :kc => 1, :encut => 100, :toten => -1.0})
    @h00.add({:kab => 1, :kc => 1, :encut => 200, :toten => -2.0})
    @h00.add({:kab => 1, :kc => 2, :encut => 100, :toten => -3.0})
    @h00.add({:kab => 1, :kc => 2, :encut => 200, :toten => -4.0})
    @h00.add({:kab => 2, :kc => 1, :encut => 100, :toten => -5.0})
    @h00.add({:kab => 2, :kc => 1, :encut => 200, :toten => -6.0})
    @h00.add({:kab => 2, :kc => 2, :encut => 100, :toten => -7.0})
    @h00.add({:kab => 2, :kc => 2, :encut => 200, :toten => -8.0})

    corrects = [
      {:encut => 100, :toten => -1.0},
      {:encut => 200, :toten => -2.0},
    ]
    results = @h00.project({:kab => 1, :kc => 1})
    assert_equal(corrects, results)

    corrects = [
      {:kc => 1, :toten => -1.0},
      {:kc => 2, :toten => -3.0},
    ]
    results = @h00.project({:kab => 1, :encut=> 100})
    assert_equal(corrects, results)

    corrects = [
      {:kab => 1, :toten => -1.0},
      {:kab => 2, :toten => -5.0},
    ]
    results = @h00.project({:kc => 1, :encut=> 100})
    assert_equal(corrects, results)

    corrects = [
      {:kc => 1, :encut => 100, :toten => -1.0},
      {:kc => 1, :encut => 200, :toten => -2.0},
      {:kc => 2, :encut => 100, :toten => -3.0},
      {:kc => 2, :encut => 200, :toten => -4.0},
    ]
    results = @h00.project({:kab => 1})
    assert_equal(corrects, results)
  end

  def test_self_load_dir

    tmp = VaspUtils::ConditionAnalyzer::Holder.load_dir("test/conditionanalyzer/00", $symprec, $angle_tolerance)
    corrects = [
      {:encut => 400, :kabc => 4, :toten => -15.642518},
      {:encut => 400, :kabc => 5, :toten => -15.642518},
      {:encut => 500, :kabc => 4, :toten => -15.642518},
      {:encut => 500, :kabc => 5, :toten => -15.642518},
    ]
    assert_equal(corrects, tmp.conds_results)

    tmp = VaspUtils::ConditionAnalyzer::Holder.load_dir("test/conditionanalyzer/01", $symprec, $angle_tolerance)
    corrects = [
      {:encut=>1000.0, :kab=>4, :kc=>4, :toten=>-3.153327},
      {:encut=>1200.0, :kab=>4, :kc=>4, :toten=>-3.150316},
      {:encut=>1500.0, :kab=>4, :kc=>4, :toten=>-3.151397},
      {:encut=>500.0, :kab=>4, :kc=>4, :toten=>-3.11294},
      {:encut=>600.0, :kab=>4, :kc=>4, :toten=>-3.181593},
      {:encut=>700.0, :kab=>4, :kc=>4, :toten=>-3.165176},
      {:encut=>900.0, :kab=>4, :kc=>4, :toten=>-3.152733},
      {:encut=>500.0, :kab=>16, :kc=>16, :toten=>-2.986564},
      {:encut=>500.0, :kab=>1, :kc=>1, :toten=>-14.265631},
      {:encut=>500.0, :kab=>32, :kc=>32, :toten=>-2.990478},
      {:encut=>500.0, :kab=>32, :kc=>64, :toten=>-2.988209},
      {:encut=>500.0, :kab=>4, :kc=>4, :toten=>-3.11294},
      {:encut=>500.0, :kab=>8, :kc=>8, :toten=>-3.014811}
    ]
    assert_equal(corrects, tmp.conds_results)

  end

end

