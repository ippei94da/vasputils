#! /usr/bin/env ruby
# coding: utf-8

#require "vasputils.rb"

# Module dearing with KPOINTS.
# This can deal with only Automatic mesh style of KPOINTS,
# i.e., this cannot deal with other various styles of KPOINTS.
class VaspUtils::Kpoints

    attr_reader :comment, :mesh, :shift, :type, :scheme

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

    def self.dump(data, io)
        io.puts "Automatic mesh"
        io.puts "0"
        io.puts data[:type].to_s.capitalize
        io.puts data[:mesh].join(" ")
        io.puts data[:shift].join(" ")
    end

    def initialize(path)
        io = File.open(path, "r")
        @comment = io.readline.chomp

        #raise "Not automatic generating KPOINTS! 2nd line must be 0." unless io.readline =~ /^0$/
        num = io.readline.to_i
        if num == 0
            @scheme = :automatic
            line = io.readline
            case line
            when /^m/i; then; @type = :monkhorst
            when /^g/i; then; @type = :gamma_center
            else
                raise "Kpoints module can deal with only monkhorst and gamma-center."
            end

            @mesh = io.readline.strip.split(/\s+/).map{|i| i.to_i}
            @shift = io.readline.strip.split(/\s+/).map{|i| i.to_f}
        else
            @scheme = :explicit
            @mesh = []
            num.times do |i|
                @mesh << io.readline.strip.split(/\s+/).map{|v| v.to_f}
            end
        end
    end

    def points_str
        if @scheme == :automatic
            return @mesh.join(",")
        else
            return @mesh.size.to_s
        end
    end

end

