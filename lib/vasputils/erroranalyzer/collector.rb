class ErrorAnalyzer::Collector

  #Argument 'dir' indicate directory including vasp calculations.
  #Assuming the identical geometry in POSCAR and CONTCARS.
  # Not check; because the geometry was optimized and contains slight change.
  # Not Use VaspGeometryOptimizer; because calculations not always use this class.
  #
  #Listed all vaspdir with geometry optimization and converged to @vaspdirs.
  def initialize(dir)
    @vaspdirs = []
    Find.find(dir) do |path|      # シムリンクには効かないので注意
      next unless FileTest.directory? path
      begin
        vd = VaspUtils::VaspDir.new path
      rescue VaspUtils::VaspDir::InitializeError
        next
      end

      next unless vd.incar["ISIF"] == 2 || vd.incar["ISIF"] == 3
      next unless vd.finished?
      next unless vd.outcar[:ionic_steps] == 1
      @vaspdirs << vd
    end
  end

  #Return vaspdirs which satisfy the conditions as argument. 
  #E.g.,
  # {:encut => 400, :kmesh => [1,1,1]}
  # {:encut => 400}
  #If conditions == nil, return all items in @vaspdirs. 
  def collect(conditions)
  end

  #Return as; e.g.,
  # [
  #   [400, 123.456],
  #   [500, 123.567],
  # ]
  def encut_toten_pairs_of_kmesh(kmesh)
  end

  #Return as; e.g.,
  # [
  #   [[1,1,1], 123.456],
  #   [[2,2,2], 123.567],
  # ]
  def kmesh_toten_pairs_of_encut(encut)
  end

  #Return all values of ENCUT as Array.
  #Argument 'conditions' is Hash of conditions;
  #E.g.,
  # {:kmesh => [1,1,1]}
  #If conditions is nil, return all ENCUT's in all vaspdirs.
  def encuts(conditions)
  end

  # Return all k-mesh'es as Array.
  #Argument 'conditions' is Hash of conditions;
  #E.g.,
  # {:encut => 400}
  #If conditions is nil, return all kmesh'es in all vaspdirs.
  def kmeshes(conditions)
  end

end
