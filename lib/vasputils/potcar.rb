#! /usr/bin/ruby
# coding: utf-8
#
#require "vasputils.rb"

#
# Class for dealing with POTCAR.
#
class VaspUtils::Potcar
    attr_reader :elements

    def initialize(elements)
        @elements = elements
    end

    def self.load_file(path)
        elements = Array.new
        File.open( path, "r" ).each do |line|
            if line =~ /VRHFIN\s*=\s*([A-Za-z]*)/
                elements << $1
            end
        end
        self.new(elements)
    end
end
