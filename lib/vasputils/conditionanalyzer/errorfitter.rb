#! /usr/bin/env ruby
# coding: utf-8

require "pp"

#
#
#
module VaspUtils::ConditionAnalyzer::ErrorFitter

    class HashKeyError < Exception; end
    class NoTotenError < Exception; end
    class UnableCalculationError < Exception; end

    #
    #
    def self.fit(hashes)
        keys = hashes.map {|hash| hash.keys}.flatten.uniq
        raise HashKeyError, keys.to_a unless keys.size == 2
        raise NoTotenError, keys.to_a unless keys.include? :toten

        key = (keys - [:toten])[0]

        data = hashes.map do |hash|
            [hash[key], hash[:toten]]
        end

        begin
            case key
            when :ka, :kb, :kc
                #pp data
                #pp  Malge::ErrorFittedFunction::AXInv.new(data)
                result =    Malge::ErrorFittedFunction::AXInv.new(data)
            when :kab, :kbc, :kca
                result =    Malge::ErrorFittedFunction::AXInv2.new(data)
            when :kabc
                result =    Malge::ErrorFittedFunction::AXInv3.new(data)
            when :encut
                result =    Malge::ErrorFittedFunction::AExpBX32.new(data)
            else
                raise "Must not happen."
            end
        rescue Malge::ErrorFittedFunction::UnableCalculationError
            raise VaspUtils::ConditionAnalyzer::ErrorFitter::UnableCalculationError
        end
        result
    end

end


