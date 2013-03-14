require "rubygems"
#gem     "mageo"
require "mageo"

module VaspUtils; end

require "vasputils/incar.rb"
require "vasputils/kpoints.rb"
require "vasputils/outcar.rb"
require "vasputils/poscar.rb"
require "vasputils/potcar.rb"
require "vasputils/potcar/concatenater.rb"
require "vasputils/setting.rb"
require "vasputils/vaspdir.rb"
require "vasputils/vaspgeometryoptimizer.rb"
require "vasputils/vaspkpointsfinder.rb"
require "vasputils/erroranalyzer.rb"

require "vasputils/conditionanalyzer.rb"
require "vasputils/conditionanalyzer/errorfitter.rb"
require "vasputils/conditionanalyzer/holder.rb"
require "vasputils/conditionanalyzer/picker.rb"
