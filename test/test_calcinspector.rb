#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/calcinspector.rb"

class YetCalc
  def started?        ; return false; end
  def normal_ended?   ; return false; end
  def to_be_continued?; return false; end
  def finished?       ; return false; end
end

class StartedCalc
  def started?        ; return true ; end
  def normal_ended?   ; return false; end
  def to_be_continued?; return false; end
  def finished?       ; return false; end
end

class NextCalc
  def started?        ; return true ; end
  def normal_ended?   ; return true ; end
  def to_be_continued?; return true ; end
  def finished?       ; return false; end
end

class FinishedCalc
  def started?        ; return true ; end
  def normal_ended?   ; return true ; end
  def to_be_continued?; return false; end
  def finished?       ; return true ; end
end

class TC_ListCalculation < Test::Unit::TestCase
  def setup
    @dc00 = YetCalc.new
    @dc01 = StartedCalc.new
    @dc02 = NextCalc.new
    @dc03 = FinishedCalc.new
  end

  def test_self_inspect
    assert_equal("YET",      CalcInspector.inspect(@dc00))
    assert_equal("STARTED",  CalcInspector.inspect(@dc01))
    assert_equal("NEXT",     CalcInspector.inspect(@dc02))
    assert_equal("FINISHED", CalcInspector.inspect(@dc03))
  end



end

