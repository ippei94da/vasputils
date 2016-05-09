#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class VaspUtils::VasprunXml
  attr_reader :data

  class IllegalArgumentError < StandardError; end

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

  def bases
    results = @data.xpath("/modeling/calculation").map do |c|
      c.xpath("./structure/crystal/varray[@name='basis']/v").map do |axis|
        axis.text.strip.split.map {|i| i.to_f}
      end
    end
    results
  end

  def positions_list
    @data.xpath("/modeling/calculation").map do |c|
      c.xpath("./structure/varray[@name='positions']/v").map do |pos|
        pos.text.strip.split.map {|i| i.to_f}
      end
    end
  end

  def nums_elements
    @data.xpath("/modeling/atominfo/array[@name='atomtypes']/set/rc").map do |elem|
      elem.xpath('./c').children[0].text.to_i
    end
  end

  def elements
    @data.xpath("/modeling/atominfo/array[@name='atomtypes']/set/rc").map do |elem|
      elem.xpath('./c').children[1].text
    end
  end

  # Return an array of [energy, total, integrated] for spin.
  # 'spin' is indicated by number started from 1 (should be 1 or 2).
  # If the 'spin' does not exist, raise IllegalArgumentError
  def total_dos(spin)
    if (spin < 1) || (num_spins < spin)
      raise IllegalArgumentError, "'spin' is indicated as #{spin}"
    end

    result = @data.xpath("/modeling/calculation/dos/total/array/set/set[@comment='spin #{spin}']/r").children.map do |elem|
      elem.to_s.strip.split.map{|i| i.to_f}
    end
    result
  end

  def total_dos_labels
    @data.xpath("/modeling/calculation/dos/total/array/field").map{|i| i.children.to_s}
  end

  def partial_dos_labels
    @data.xpath("/modeling/calculation/dos/partial/array/field").map{|i| i.children.to_s.strip}
  end

  def partial_dos(ion, spin)
    if (spin < 1) || (num_ions < ion)
      raise IllegalArgumentError, "'ion' is indicated as #{ion}"
    end

    if (spin < 1) || (num_spins < spin)
      raise IllegalArgumentError, "'spin' is indicated as #{spin}"
    end

    result = @data.xpath("/modeling/calculation/dos/partial/array/set/set[@comment='ion #{ion}']/set[@comment='spin #{spin}']/r").children.map do |elem|
      elem.to_s.strip.split.map{|i| i.to_f}
    end
    result
  end

  def fermi_energy
    @data.xpath("/modeling/calculation/dos/i[@name='efermi']").children.to_s.to_f
  end

  def num_atoms
    @data.xpath("/modeling/atominfo/atoms").children.to_s.to_i
  end
  alias num_ions num_atoms

  def num_spins
    @data.xpath("/modeling/parameters/separator[@name='electronic']/separator[@name='electronic spin']/i[@name='ISPIN']").children.to_s.to_i
  end

  # energies of each ionic step
  def calculation_energies
    #pp @data.xpath("/modeling/calculation/energy/i[@name='e_fr_energy']").children.to_s.to_f
    @data.xpath("/modeling").children.each do |i|
      pp i
    end
    exit
  end
end

