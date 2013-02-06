require "pp"
require "find"
require "vasputils"

class VaspUtils::ErrorAnalyzer::Collector
  attr_reader :converged_dirs

  #Argument 'dir' indicate directory including vasp calculations.
  #Assuming the identical geometry in POSCAR and CONTCARS.
  # Not check; because the geometry was optimized and contains slight change.
  # Not Use VaspGeometryOptimizer; because calculations not always use this class.
  #
  #Listed all vaspdir with geometry optimization and converged to @converged_dirs.
  def initialize(dir)
    @converged_dirs = []
    Find.find(dir) do |path|      # シムリンクには効かないので注意
      next unless FileTest.directory? path
      begin
        vd = VaspUtils::VaspDir.new path
      rescue VaspUtils::VaspDir::InitializeError
        next
      end
      ibrion = vd.incar["IBRION"].to_i
      next if ibrion == -1
      next unless vd.finished?
      next unless vd.outcar[:ionic_steps] == 1

      @converged_dirs << vd
    end
  end

  ##Return converged_dirs which satisfy the conditions as argument.
  ##Example of argument, conditions:
  ## {:encut => 400, :kmesh => [1,1,1]}
  ## {:encut => 400}
  ##If conditions == nil, return all items in @converged_dirs. 
  #def select(conditions = nil)
  #  if conditions
  #    @converged_dirs.select{|vd| vd.
  #  else
  #    return @converged_dirs
  #  end
  #end

  #Return as; e.g.,
  # [
  #   [400, 123.456],
  #   [500, 123.567],
  # ]
  def encut_toten_pairs_of_kmesh(kmesh)
    @converged_dirs.select{|dir| dir.kpoints[:mesh] == kmesh }.map do |vd|
      [ vd.incar["ENCUT"].to_i, vd.outcar[:totens][-1] ]
    end
  end

  #Return as; e.g.,
  # [
  #   [[1,1,1], 123.456],
  #   [[2,2,2], 123.567],
  # ]
  def kmesh_toten_pairs_of_encut(encut)
    @converged_dirs.select{|dir| dir.incar["ENCUT"].to_i == encut }.map do |vd|
      [ vd.kpoints[:mesh], vd.outcar[:totens][-1] ]
    end
  end

  #Return all values of ENCUT as Array; e.g., [400, 500]
  #Argument 'conditions' is Hash of conditions; e.g.,
  # {:kmesh => [1,1,1]}
  #If 'conditions' is nil, return all ENCUT's in all converged_dirs.
  def encuts(conditions = nil)
    @converged_dirs.map{|vd| vd.incar["ENCUT"].to_i}.uniq.sort
  end

  #Return all k-mesh'es as Array; e.g., [[4,4,4], [5,5,5]]
  #Argument 'conditions' is Hash of conditions; e.g.,
  # {:encut => 400}
  #If 'conditions' is nil, return all kmesh'es in all converged_dirs.
  def kmeshes(conditions = nil)
    @converged_dirs.map{|vd| vd.kpoints[:mesh]}.uniq.sort
  end

end
