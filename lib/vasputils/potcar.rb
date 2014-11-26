#! /usr/bin/ruby
# coding: utf-8
#
#require "vasputils.rb"

#
# Class for dealing with POTCAR.
#
module VaspUtils::Potcar
    def self.load_file(file)
        results = {}
        results[:name] = file

        elements = Array.new
        File.open( file, "r" ).each do |line|
            if line =~ /VRHFIN\s*=\s*([A-Za-z]*)/
                elements << $1
            end
        end
        results[:elements] = elements
        results
    end
end
