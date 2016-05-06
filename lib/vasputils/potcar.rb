#! /usr/bin/ruby
# coding: utf-8

#
# Class for dealing with POTCAR.
#
class VaspUtils::Potcar
  attr_reader :elements, :enmaxes

  def initialize
    @elements = []
    @enmaxes = []
  end


  def self.load_file(path)
    result = self.new
    #elements = Array.new
    File.open( path, "r" ).each do |line|
      if line =~ /VRHFIN\s*=\s*([A-Za-z]*)/
        result.elements << $1
      elsif line =~ /ENMAX\s*=\s*(\d+\.\d+)/
        result.enmaxes << $1.to_f
      end
    end
    result
  end
end
