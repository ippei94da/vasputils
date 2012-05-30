#! /usr/bin/env ruby
# coding: utf-8

require "vasputils/vaspdir.rb"

# 
# 
# 
class VaspConditionFinder


  def initialize(dir)
    @dir = dir # redefine in subclass. 
    @lockdir    = "lock_vaspcondfind"
    @alive_time = 3600

    @previous_condition = nil
    @condition = [ 0, 0, 0, 0 ] #indicate ka, kb, kc, encut

    @kpoint_candidates = list_kpoints
    @encut_candidates  = list_encuts
  end

  private

  def calculate
    @previous_condition = Marshal.load(Marshal.dump(@condition))

    #@condition を起点として、
    #ENCUT の最適化し、精度以下となる最低の条件を @condition に登録。
    #ka の最適化し、精度以下となる最低の条件を @condition に登録。
    #kb の最適化し、精度以下となる最低の条件を @condition に登録。
    #kc の最適化し、精度以下となる最低の条件を @condition に登録。

    #k の gamma center / hexagonal
    #k の shift
    #spin の有無。当面は有りを前提。INCAR で ISPIN をチェックする。
  end

  # Do nothing.
  def prepare_next
  end

  def finished?
    @previous_condition == @condition
  end

  def lowest_encut
    min_dir = Dir.glob(@dir + "/*/*").min_by { |dir| VaspDir.new(dir).incar["ENCUT"] }
    VaspDir.new(min_dir).incar["ENCUT"].to_i
  end

  def list_encuts
    results = []
    (lowest_encut/100).upto 10 do |i|
      results << i * 100
    end
    results
  end

  # Using lattice constants of POSCAR, which is an initial value.
  #
  def list_kpoints
    #vd = VaspDir.new(Dir.glob(@dir + "/*/try00")[0])
    #results = []
    #vd.poscar.axes.get_lattice_constants[0..2].map do |length|
    #end
  end
end

