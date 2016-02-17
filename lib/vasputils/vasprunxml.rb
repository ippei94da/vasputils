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

  def bases
    results = @data.xpath("/modeling/calculation").map do |c|
      c.xpath("./structure/crystal/varray[@name='basis']/v").map do |axis|
        axis.text.strip.split.map {|i| i.to_f}
      end
    end
  end

  def positions_list
    @data.xpath("/modeling/calculation").map do |c|
      c.xpath("./structure/varray[@name='positions']/v").map do |pos|
        pos.text.strip.split.map {|i| i.to_f}
      end
    end
    #t = @data.xpath("/modeling/calculation/structure/crystal/varray[@name='basis']/v").map { |i| pp i.text.strip.split.map{|j| j.to_f}}
    #pp t.methods.sort
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

  def total_dos
    @data.xpath("/modeling/calculation/dos/total/array/set/set[@comment='spin 1']/r").children.map do |elem|
      elem.to_s.strip.split.map{|i| i.to_f}
      #elem.class
      #elem.methods.sort
    end
  end

  def total_dos_labels
    @data.xpath("/modeling/calculation/dos/total/array/field").map{|i| i.children.to_s}
  end

  def fermi_energy
    @data.xpath("/modeling/calculation/dos/i[@name='efermi']").children.to_s.to_f
  end

  def num_atoms
    #@data.xpath("/modeling/calculation/dos/i[@name='efermi']").children.to_s.to_f
  end

  def num_spins
  end

end

