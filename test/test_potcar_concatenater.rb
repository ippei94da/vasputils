#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils.rb"
require "vasputils/setting.rb"
require "vasputils/potcar/concatenater.rb"

class VaspUtils::Potcar::Concatenater
  public :dump
end

class TC_Concatenater < Test::Unit::TestCase
  def setup
    settings = VaspUtils::Setting.new("test/potcar/test.vasputils")
    potcar_path = settings.get "potcar_path"
    elem_potcar = settings.get "element_potcar"

    @c = VaspUtils::Potcar::Concatenater.new(potcar_path, elem_potcar)
  end

  def test_dump
    # concatenating
    assert_equal(
      "H\n",
      @c.dump(["H"])
    )
    assert_equal(
      "H\nLi_sv\n",
      @c.dump(["H", "Li"])
    )
    assert_raise(VaspUtils::Potcar::Concatenater::NoPotcarError){@c.dump(["H", "Li", "not_exist_element"])}


    # return string if io is nil.
    assert_equal(
      "H\n",
      @c.dump(["H"], nil)
    )

    # write io
    outfile = "test/potcar/tmp.POTCAR"
    FileUtils.rm(outfile) if File.exist? outfile
    File.open(outfile, "w") do |io|
      @c.dump(["H"], io)
    end
    assert_equal(
      "H\n",
      File.read(outfile)
    )

    FileUtils.rm(outfile) if File.exist? outfile
  end

end

