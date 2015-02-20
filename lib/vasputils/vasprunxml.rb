#! /usr/bin/env ruby
# coding: utf-8

require 'nokogiri'

#
#
#
class VaspUtils::VasprunXml
    attr_reader :data

    #
    def initialize(data)
        @data = data
    end

    def self.load_file(path)
        data = Nokogiri::XML(open(path))
        self.new(data)
    end

    # Return stress tensor of last ionic step
    def stress
        items = @data.xpath("/modeling/calculation/varray[@name='stress']/v").children
        items = items.map do |line|
            line.to_s.strip.split(/ +/).map {|item| item.to_f}
        end
        items[-3..-1]
    end
end

