#! /usr/bin/env ruby
# coding: utf-8

#Analyzer of dependence of TOTEN on conditions.
#Current version can deal with only encut and k-mesh.
#Only TOTEN is evaluated.
#
#NOTE: to deal with k-mesh withmonkhorst or gammacenter and shift.
# But it needs Kmesh class.
#
class ErrorAnalyzer
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

  #Return all values of ENCUT as Array.
  #Argument 'conditions' is Hash of conditions;
  #E.g.,
  # {:kmesh = [1,1,1]}
  #If conditions is nil, return all ENCUT's in all vaspdirs.
  def encuts(conditions)
  end

  # Return all k-mesh'es as Array.
  #Argument 'conditions' is Hash of conditions;
  #E.g.,
  # {:encut = 400}
  #If conditions is nil, return all kmesh'es in all vaspdirs.
  def kmeshes(conditions)
  end

  #Return [a_0, a_1] in the equation : |y - a_0| = a_1 / n_k;
  #where n_k indicates total number of kpoints.
  #Varying k-mesh with fixed other conditions as argument.
  #E.g.,
  # {:encut = 400}
  def fit_inverse_kpoints(conditions)
  end

  #Return [a_0, a_1] in the equation : |y - a_0| = a_1 / E_co^{3/2}
  #where E_co indicates a cutoff energy, ENCUT.
  #Varying E_co with fixed other conditions as argument.
  #E.g.,
  # {:kmesh = [1,1,1]}
  def fit_inverse_encut_3_2(conditions)
  end

  それぞれの条件で誤差の期待値がいくらになるか。
  たとえば 300〜1000 eV に振った条件の中で
  計算コストと勘案して、最もリーズナブルな計算条件を探したいときに。
  def expected_errors(coefficients, conditions)
  end

  #Return a certain vaspdir.
  #Argument 'conditions' is Hash of conditions;
  #E.g.,
  # {:encut = 400}
  # {:kmesh = [1,1,1]}
  def vaspdir(conditions)
  end


  for kpoints 



end

