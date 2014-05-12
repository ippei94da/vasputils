#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class VaspUtils::ConditionVarier
    class InvalidOptionError < Exception; end

    #
    def initialize(standard_vaspdir, options)
        @standard_vaspdir = VaspUtils::VaspDir.new(standard_vaspdir)
        self.class.check_sanity_options(options)

        @options = {}
        [:ka, :kb, :kc, :kab, :kbc, :kca, :kabc].each do |key|
            next unless options[key]
            @options[key] = self.class.integers(options[key])
        end
        [:encut].each do |key|
            next unless options[key]
            @options[key] = self.class.floats(options[key])
        end
        
    end

    def self.integers(str)
        str.split(",").map{|val| val.to_i}
    end

    def self.floats(str)
        str.split(",").map{|val| val.to_f}
    end

    def self.check_sanity_options(options)
        counts = {:a => 0, :b => 0, :c => 0}
        if options.keys.include?(:ka)
            counts[:a] += 1
        end
        if options.keys.include?(:kb)
            counts[:b] += 1
        end
        if options.keys.include?(:kc)
            counts[:c] += 1
        end
        if options.keys.include?(:kab)
            counts[:a] += 1
            counts[:b] += 1
        end
        if options.keys.include?(:kbc)
            counts[:b] += 1
            counts[:c] += 1
        end
        if options.keys.include?(:kca)
            counts[:c] += 1
            counts[:a] += 1
        end
        if options.keys.include?(:kabc)
            counts[:a] += 1
            counts[:b] += 1
            counts[:c] += 1
        end

        if counts[:a] > 1
            raise InvalidOptionError,  "Error: ka mesh is duplicated."
        end
        if counts[:b] > 1
            raise InvalidOptionError,  "Error: kb mesh is duplicated."
        end
        if counts[:c] > 1
            raise InvalidOptionError,  "Error: kc mesh is duplicated."
        end
    end

    def self.nth_combination(ary)
        size = ary.inject(1){|n, item| n *= item}
        #pp size
        size.times do |i|
            #pp i
        end
    end

    def generate
        keys = @options.keys.sort
        conditions = []
        #keys.size 
        num = @options.values.inject(1){|n, ary| n *= ary.size}
        #p num
        #num.times do |
        #keys.each do |key|
        #    pp @options[key]
        #end
        #keys.size.times do |i|

            #keys.each do |key|
        #end
    end

end

