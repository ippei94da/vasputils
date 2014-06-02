#! /usr/bin/env ruby
# coding: utf-8

require "pp"

#
#
#
module VaspUtils::ConditionAnalyzer::Picker

    class InitializeError < Exception; end
    #
    #def initialize(vaspdir)
    #end

    #Return hash summarize information of a converged VaspDir.
    #E.g., when tetragonal lattice whose main axis is b.
    # corrects = {
    #       :encut => 400.0,
    #       :kca => 4,
    #       :kb => 2,
    #       :toten => -15.642518
    # }
    #Raise InitializeError if the dir is not VaspDir.
    #Raise InitializeError if the dir is not converged.
    def self.pick(dir, symprec, angle_tolerancce)
        raise InitializeError unless FileTest.directory? dir
        begin
            vd = VaspUtils::VaspDir.new dir
        rescue VaspUtils::VaspDir::InitializeError
            raise InitializeError
        end
        #ibrion = vd.incar["IBRION"].to_i
        #raise InitializeError if ibrion == -1
        raise InitializeError unless vd.finished?
        raise InitializeError unless vd.outcar[:ionic_steps] == 1

        results = {:encut => vd.incar["ENCUT"].to_f}

        independencies = vd.poscar.axis_independencies(symprec, angle_tolerancce)
        k_axes = [:ka, :kb, :kc] if independencies == [true , true , true ]
        k_axes = [:kab, :kc] if independencies == [false, false, true ]
        k_axes = [:kbc, :ka         ] if independencies == [true , false, false]
        k_axes = [:kca, :kb      ] if independencies == [false, true , false]
        k_axes = [:kabc              ] if independencies == [false, false, false]
        kmeshes = vd.kpoints[:mesh]
        k_axes.each do |k_axis|
            #pp k_axis
            case k_axis
            when :ka, :kab, :kabc
                results[k_axis] = kmeshes[0]
            when :kb, :kbc
                results[k_axis] = kmeshes[1]
            when :kc, :kca
                results[k_axis] = kmeshes[2]
            else
                raise "Must not happen."
            end
        end

        results[:toten] = vd.outcar[:totens][-1]

        results
    end

end

