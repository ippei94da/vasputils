#! /usr/bin/env ruby
# coding: utf-8

require "vasputils.rb"

# Module dearing with KPOINTS.
# This can deal with only Automatic mesh style of KPOINTS,
# i.e., this cannot deal with other various styles of KPOINTS.
module VaspUtils::Kpoints
  def self.parse(io)
    results = {}
    results[:comment] = io.readline.chomp

    raise "Not automatic generating KPOINTS! 2nd line must be 0." unless io.readline == "0\n"

    line = io.readline
    case line
    when /^m/i; then; results[:type] = :monkhorst
    when /^g/i; then; results[:type] = :gamma_center
    else
      raise "Kpoints module can deal with only monkhorst and gamma-center."
    end

    results[:mesh] = io.readline.strip.split(/\s+/).map{|i| i.to_i}
    results[:shift] = io.readline.strip.split(/\s+/).map{|i| i.to_f}

    return results
  end

  # 
  def self.load_file(file)
    self.parse(File.open(file, "r"))
  end

  def self.dump(data, io)
    io.puts "Automatic mesh"
    io.puts "0"
    io.puts data[:type].to_s.capitalize
    io.puts data[:mesh].join(" ")
    io.puts data[:shift].join(" ")
  end
end

