#! /usr/bin/env ruby
# coding: utf-8

#require "vasputils.rb"

# Class to dearl with KPOINTS.
# This can deal with only Automatic mesh style of KPOINTS,
# i.e., this cannot deal with other various styles of KPOINTS.
class VaspUtils::Kpoints

    attr_reader :comment, :mesh, :shift, :type, :scheme, :points

    class UnsupportedFormat < Exception; end


    #def self.parse(io)
    #    results = {}
    #    results[:comment] = io.readline.chomp

    #    raise "Not automatic generating KPOINTS! 2nd line must be 0." unless io.readline =~ /^0$/

    #    line = io.readline
    #    case line
    #    when /^m/i; then; results[:type] = :monkhorst
    #    when /^g/i; then; results[:type] = :gamma_center
    #    else
    #        raise "Kpoints module can deal with only monkhorst and gamma-center."
    #    end

    #    results[:mesh] = io.readline.strip.split(/\s+/).map{|i| i.to_i}
    #    results[:shift] = io.readline.strip.split(/\s+/).map{|i| i.to_f}

    #    return results
    #end

    ## 
    #def self.load_file(file)
    #    self.parse(File.open(file, "r"))
    #end

    def initialize(hash)
        hash.each do |key,val|
            @comment = val if :comment == key
            @mesh    = val if :mesh    == key
            @points  = val if :points  == key
            @scheme  = val if :scheme  == key
            @shift   = val if :shift   == key
            @type    = val if :type    == key
        end
    end

    def self.load_file(path)
        io = File.open(path, "r")
        comment = io.readline.chomp

        #raise "Not automatic generating KPOINTS! 2nd line must be 0." unless io.readline =~ /^0$/
        num = io.readline.to_i
        if num == 0
            scheme = :automatic
            line = io.readline
            case line
            when /^m/i; then; type = :monkhorst
            when /^g/i; then; type = :gamma_center
            else
                raise "Unsupported automatic generation of KPOINTS."
            end

            mesh = io.readline.strip.split(/\s+/).map{|i| i.to_i}
            shift = io.readline.strip.split(/\s+/).map{|i| i.to_f}
            points = nil
        else
            scheme = :explicit
            mesh = nil
            points = []

            coordinate_style = io.readline
            unless coordinate_style =~ /^[c|k]/i
                raise "Unsupported coordinate style of KPOINTS."
            end
            num.times do |i|
                points << io.readline.strip.split(/\s+/).map{|v| v.to_f}
            end
        end

        options = {
            :comment => comment,
            :mesh    => mesh   ,
            :points  => points ,
            :scheme  => scheme ,
            :shift   => shift  ,
            :type    => type   ,
        }
        self.new(options)
    end

    # Dump in KPOINTS style.
    # Only automatic generation scheme is supported.
    def dump(io)
        io.puts "Automatic mesh"
        io.puts "0"
        io.puts @type.to_s.capitalize
        io.puts @mesh.join(" ")
        io.puts @shift.join(" ")
    end

end

