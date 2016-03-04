#! /usr/bin/env ruby
# coding: utf-8

require 'helper'
#require "test/unit"
#require "vasputils/setting.rb"

class TC_Setting < Test::Unit::TestCase
    def setup
        @s = VaspUtils::Setting.new("test/setting/dot.vasputils")
    end

    def test_initialize
        assert_raise(Errno::ENOENT){VaspUtils::Setting.new("not_exist_file")}
    end

    def test_get
        #assert_raise(VaspUtils::Setting::NoEntryError){@s.get("no_entory_key")}
        #assert_equal("/usr/local/calc/potcar/potpaw_PBE.52", @s.get("potcar_dir"))
        assert_raise(VaspUtils::Setting::NoEntryError){@s["no_entory_key"]}
        assert_equal("/home/ippei/opt/vasp/potcar/potpaw_PBE.52", @s["potcar_dir"])
    end
end

