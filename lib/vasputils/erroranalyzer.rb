#! /usr/bin/env ruby
# coding: utf-8

#
#
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

  # Return all values of ENCUT as Array.
  def encuts
  end

  # Return all k-mesh'es as Array.
  def kmeshes
  end

  ## Return all k_a's as Array.
  #def kas
  #end

  ## Return all k_b's as Array.
  #def kbs
  #end

  ## Return all k_c's as Array.
  #def kcs
  #end

  # Return [a_0, a_1] in the equation : |y - a_0| = a_1 / n_k .
  #
  # Fixed ENCUT and varying k-mesh(n_k)
  def least_square_encut(encut)
  end


  for kpoints 



end

