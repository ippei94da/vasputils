#! /usr/bin/env ruby
# coding: utf-8

require "pp"

#
#
#
class VaspUtils::Potcar::Concatenater
    class NoPotcarError < Exception; end

    # 'potcar_path' indicates a storage directory of POTCARs.
    # 'elem_potcar' indicates a correspondence
    # between element symbol and prior POTCAR as Hash.
    def initialize(potcar_path, elem_potcar)
        @potcar_path = potcar_path
        @elem_potcar = elem_potcar
    end

    # Concatenate POTCARs.
    # Write to io if defined
    # Return string if io is nil.
    def dump(elements, io = nil)
        result = elements.map { |elem|
            raise NoPotcarError unless @elem_potcar.include? elem
            filename = @potcar_path + "/" + @elem_potcar[elem] + "/POTCAR"
            File.read filename
        }.join("")

        if io # is defined
            io.print result
        else
            return result
        end
    end
end

