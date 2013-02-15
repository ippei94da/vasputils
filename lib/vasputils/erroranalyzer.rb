#Analyzer of dependence of TOTEN on conditions.
#Current version can deal with only encut and k-mesh.
#Only TOTEN is evaluated.
#
#NOTE: to deal with k-mesh withmonkhorst or gammacenter and shift.
#But it needs Kmesh class.

require "pp"
require "find"
require "vasputils"
require "rubygems"
require "malge"

class VaspUtils::ErrorAnalyzer

  class UnsufficientDataError < Exception; end

  attr_reader :converged_calculations

  #Argument 'dir' indicate directory including vasp calculations.
  #Assuming the identical geometry in POSCAR and CONTCARS.
  # Not check; because the geometry was optimized and contains slight change.
  # Not Use VaspGeometryOptimizer; because calculations not always use this class.
  #
  #@converged_calculations includes conditions and results by
  #all calculation which are converged in geometry optimization.
  #An item of the array is a hash. E.g., 
  #{:encut => 400, :kmesh => [4,4,4], :toten => -12.34}
  def initialize(dir)
    @converged_calculations = []
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

      @converged_calculations <<
        {
          :encut => vd.incar["ENCUT"].to_i,
          :kmesh => vd.kpoints[:mesh],
          :toten => vd.outcar[:totens][-1],
        }
    end
  end

  ##Return converged_calculations which satisfy the conditions as argument.
  ##Example of argument, conditions:
  ## {:encut => 400, :kmesh => [1,1,1]}
  ## {:encut => 400}
  ##If conditions == nil, return all items in @converged_calculations. 
  #def select(conditions = nil)
  #  if conditions
  #    @converged_calculations.select{|vd| vd.
  #  else
  #    return @converged_calculations
  #  end
  #end

  #Return as; e.g.,
  # [
  #   [400, 123.456],
  #   [500, 123.567],
  # ]
  def encut_toten_pairs_of_kmesh(kmesh)
    calcs = @converged_calculations.select{|calc| calc[:kmesh] == kmesh }
    calcs.map! { |calc| [ calc[:encut], calc[:toten] ] }
    calcs = calcs. sort_by { |pair| pair[0] } . uniq
    calcs
  end

  #Return as; e.g.,
  # [
  #   [[1,1,1], 123.456],
  #   [[2,2,2], 123.567],
  # ]
  def kmesh_toten_pairs_of_encut(encut)
    calcs = @converged_calculations.select{|calc| calc[:encut] == encut }
    calcs.map! { |calc| [ calc[:kmesh], calc[:toten] ] }
    calcs = calcs.sort_by { |pair| pair[0][0] * pair[0][1] * pair[0][2] } . uniq
  end

  #Return all values of ENCUT as Array; e.g., [400, 500]
  #Argument 'conditions' is Hash of conditions; e.g.,
  # {:kmesh => [1,1,1]}
  #If 'conditions' is nil, return all ENCUT's in all converged_calculations.
  def encuts(conditions = nil)
    @converged_calculations.map{|calc| calc[:encut]}.sort.uniq
  end

  #Return all k-mesh'es as Array; e.g., [[4,4,4], [5,5,5]]
  #Argument 'conditions' is Hash of conditions; e.g.,
  # {:encut => 400}
  #If 'conditions' is nil, return all kmesh'es in all converged_calculations.
  def kmeshes(conditions = nil)
    @converged_calculations.map{|calc| calc[:kmesh]}.uniq.sort
  end

  #
  def fit_kpoints_totens(encut)
    data_pairs = kmesh_toten_pairs_of_encut(encut).map do |pair|
      n_k = pair[0][0] * pair[0][1] * pair[0][2]
      toten = pair[1]
      [n_k, toten]
    end
    if data_pairs.size > 2
      func = Malge::ErrorFittedFunction::AXInv.new(data_pairs)
    else
      raise UnsufficientDataError, data_pairs.to_s
    end
    func
  end

  def fit_encutsinv_totens(encut)
    TODO
  end

  def fit_encutsinv32_totens(encut)
    TODO
  end

  def fit_encutsexp_totens(encut)
    TODO
  end

  def fit_encutsexp32_totens(encut)
    TODO
  end



end

#TODO
#  #Return [a_0, a_1] in the equation : |y - a_0| = a_1 / n_k;
#  #where n_k indicates total number of kpoints.
#  #Varying k-mesh with fixed other conditions as argument.
#  #E.g.,
#  # {:encut = 400}
#  def fit_inverse_kpoints(conditions)
#  end
#
#  #Return [a_0, a_1] in the equation : |y - a_0| = a_1 / E_co^{3/2}
#  #where E_co indicates a cutoff energy, ENCUT.
#  #Varying E_co with fixed other conditions as argument.
#  #E.g.,
#  # {:kmesh = [1,1,1]}
#  def fit_inverse_encut_3_2(conditions)
#  end
#
#  それぞれの条件で誤差の期待値がいくらになるか。
#  たとえば 300〜1000 eV に振った条件の中で
#  計算コストと勘案して、最もリーズナブルな計算条件を探したいときに。
#  def expected_errors(coefficients, conditions)
#  end
#
