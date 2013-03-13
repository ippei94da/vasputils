#! /usr/bin/env ruby
# coding: utf-8

#
#
#
module VaspUtils::ConditionAnalyzer::Picker

  class InitializeError < Exception; end
  #
  #def initialize(vaspdir)
  #end

  def self.pick(dir, symprec, angle_tolerancce)
    raise InitializeError unless FileTest.directory? dir
    begin
      vd = VaspUtils::VaspDir.new dir
    rescue VaspUtils::VaspDir::InitializeError
      raise InitializeError unless FileTest.directory? dir
    end
    ibrion = vd.incar["IBRION"].to_i
    raise InitializeError if ibrion == -1
    raise InitializeError unless vd.finished?
    raise InitializeError unless vd.outcar[:ionic_steps] == 1

    independencies = vd.poscar.axis_independencies(symprec, angle_tolerancce)

    results = {
      :encut => vd.incar.encut,
      :ka => vd.incar.encut,
    }

  end

end

