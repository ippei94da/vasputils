module VaspUtils; end

require "vasputils/incar.rb"
require "vasputils/kpoints.rb"
require "vasputils/outcar.rb"
require "vasputils/poscar.rb"
require "vasputils/potcar.rb"
require "vasputils/vaspdir.rb"
require "vasputils/vaspgeometryoptimizer.rb"
require "vasputils/vaspkpointsfinder.rb"

module VaspUtils
  # lattice_constants must have three floats.
  # return array of array of three integers. e.g.,
  # [
  #   [1,1,1],
  #   [1,1,2],
  #   [1,2,1],
  #   [1,2,2],
  # ]
  def generate_kmeshes(lattice_constants, max_length)
    
  end
end
