#! /usr/bin/env ruby
# coding: utf-8

# Module dearing with KPOINTS.
module Kpoints
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

    #pp io.readline.strip.split(/\s+/).map{|i| i.to_i}
    results[:mesh] = io.readline.strip.split(/\s+/).map{|i| i.to_i}
    #pp io.readline.strip.split(/\s+/).map{|i| i.to_f}
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

