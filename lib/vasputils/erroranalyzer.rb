#Analyzer of dependence of TOTEN on conditions.
#Current version can deal with only encut and k-mesh.
#Only TOTEN is evaluated.
#
#NOTE: to deal with k-mesh withmonkhorst or gammacenter and shift.
# But it needs Kmesh class.

require "vasputils.rb"
module VaspUtils::ErrorAnalyzer; end

#require "vasputils/erroranalyzer/collector.rb"
#
#
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
