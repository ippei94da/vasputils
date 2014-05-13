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

    # Argument 'ary' is Array of Integer's.
    # Return all variation of integers less than Integer's.
    def self.mesh_points(ary)
        if ary.size == 1
            results = Array.new
            ary[0].times do |i|
                results[i] = [i]
            end
            return results
        elsif ary.size > 1
            variation = ary.shift
            right_ary = self.mesh_points(ary)

            results = Array.new
            variation.times do |i|
                right_ary.each do |ary|
                    #p [i, *ary]
                    results.push([i, *ary])
                end
            end
            return results
        else
            raise RuntimeError, "Must not happen!"
        end
    end

    def generate
        keys = @options.keys.sort
        values = keys.map { |key| @options[key] }
        sizes = keys.map { |key| @options[key].size }
        mesh_points = self.class.mesh_points(sizes)
        #p keys
        #p values
        #p sizes
        #p mesh_points

        mesh_points.each do |condition|
            keys.size.times 

        end

    end

end

