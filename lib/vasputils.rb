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
require "vasputils/erroranalyzer/collector.rb"
require "vasputils/erroranalyzer/encuttotenfitter1.rb"
require "vasputils/erroranalyzer/encuttotenfitter32.rb"
require "vasputils/erroranalyzer/encuttotenfitterexp.rb"
require "vasputils/erroranalyzer/encuttotenfitterexp32.rb"
require "vasputils/erroranalyzer/kmeshtotenfitter.rb"

#module VaspUtils
#  TOLERANCE = 1e-10
#
#  class ArgumentError < Exception; end
#
#  # lattice_constants must have three floats.
#  # return array of array of three integers. e.g.,
#  # [
#  #   [1,1,1],
#  #   [2,1,1],
#  #   [3,1,1],
#  #   [3,2,2],
#  #   [4,2,2],
#  #   [5,2,2],
#  # ]
#  # which is sorted.
#  def self.generate_kmeshes(lattice_constants, max_length)
#    raise ArgumentError, lattice_constants.inspect unless lattice_constants.size == 3
#
#    # まず波長リストを作る
#    lengths = []
#    3.times do |i|
#      l = lattice_constants[i] 
#      counter = 0
#      do
#        cur_length = l * (2 ** counter)
#        lengths << cur_length
#        counter += 1
#      while cur_length < max_length
#    end
#    lengths.sort!
#
#    # TOLERANCE 以下の近しいものをまとめる。
#    (lengths.size - 1).times do |i|
#      lengths[i]
#    end
#
#    #TODO
#
#    ##3.times do |i|
#    ##  (max_length / lattice_constants[i]).to_i
#    ##end
#
#    #results = []
#    #tmp = [1,1,1]
#    #results.push tmp.clone
#
#
#    #lattice_constants.min
#
#    #while true
#    #  break if (
#    #    (lattice_constants[0] * tmp[0] > max_length) &&
#    #    (lattice_constants[1] * tmp[1] > max_length) &&
#    #    (lattice_constants[2] * tmp[2] > max_length)
#    #  )
#
#    #end
#
#
#    #return results
#  end
#end
