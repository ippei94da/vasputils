# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vasputils"
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ippei94da"]
  s.date = "2012-05-29"
  s.description = "This gem provides parsers for some of input and output files for VASP.\n    This will provide support command for computations."
  s.email = "ippei94da@gmail.com"
  s.executables = ["addVolumeToten.rb", "latticeconstants", "lsvasp", "lsvaspdir", "lsvaspseries", "qsubvasp", "runvasp", "symposcar"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/addVolumeToten.rb",
    "bin/latticeconstants",
    "bin/lsvasp",
    "bin/lsvaspdir",
    "bin/lsvaspseries",
    "bin/qsubvasp",
    "bin/runvasp",
    "bin/symposcar",
    "lib/vasputils.rb",
    "lib/vasputils/calcinspector.rb",
    "lib/vasputils/incar.rb",
    "lib/vasputils/kpoints.rb",
    "lib/vasputils/outcar.rb",
    "lib/vasputils/poscar.rb",
    "lib/vasputils/potcar.rb",
    "lib/vasputils/vaspdir.rb",
    "lib/vasputils/vaspgeomopt.rb",
    "memo.txt",
    "test/calcseries/dup_finished/try00/CONTCAR",
    "test/calcseries/dup_finished/try00/INCAR",
    "test/calcseries/dup_finished/try00/KPOINTS",
    "test/calcseries/dup_finished/try00/OUTCAR",
    "test/calcseries/dup_finished/try00/POSCAR",
    "test/calcseries/dup_finished/try00/POTCAR",
    "test/calcseries/dup_finished/try00/lock",
    "test/calcseries/dup_finished/try01/CONTCAR",
    "test/calcseries/dup_finished/try01/INCAR",
    "test/calcseries/dup_finished/try01/KPOINTS",
    "test/calcseries/dup_finished/try01/OUTCAR",
    "test/calcseries/dup_finished/try01/POSCAR",
    "test/calcseries/dup_finished/try01/POTCAR",
    "test/calcseries/dup_finished/try01/lock",
    "test/calcseries/normal_finished/try00/CONTCAR",
    "test/calcseries/normal_finished/try00/INCAR",
    "test/calcseries/normal_finished/try00/KPOINTS",
    "test/calcseries/normal_finished/try00/OUTCAR",
    "test/calcseries/normal_finished/try00/POSCAR",
    "test/calcseries/normal_finished/try00/POTCAR",
    "test/calcseries/normal_finished/try00/lock",
    "test/calcseries/normal_finished/try01/CONTCAR",
    "test/calcseries/normal_finished/try01/INCAR",
    "test/calcseries/normal_finished/try01/KPOINTS",
    "test/calcseries/normal_finished/try01/OUTCAR",
    "test/calcseries/normal_finished/try01/POSCAR",
    "test/calcseries/normal_finished/try01/POTCAR",
    "test/calcseries/normal_finished/try01/lock",
    "test/calcseries/not_finished/try00/CONTCAR",
    "test/calcseries/not_finished/try00/INCAR",
    "test/calcseries/not_finished/try00/KPOINTS",
    "test/calcseries/not_finished/try00/OUTCAR",
    "test/calcseries/not_finished/try00/POSCAR",
    "test/calcseries/not_finished/try00/POTCAR",
    "test/calcseries/not_finished/try00/lock",
    "test/helper.rb",
    "test/incar/INCAR.00",
    "test/incar/INCAR.01",
    "test/kpoints/g123-456",
    "test/kpoints/m123-456",
    "test/outcar/01-03-INT.OUTCAR",
    "test/outcar/01-13-FIN.OUTCAR",
    "test/outcar/02-05-FIN.OUTCAR",
    "test/outcar/03-05-FIN.OUTCAR",
    "test/outcar/10-01-FIN.OUTCAR",
    "test/poscar/NOT_POSCAR",
    "test/poscar/POSCAR.00",
    "test/poscar/POSCAR.01",
    "test/poscarparser/POSCAR.00",
    "test/poscarparser/POSCAR.01",
    "test/potcar/POTCAR",
    "test/potcar/POTCAR.allElement",
    "test/potcar/POTCAR.dummy",
    "test/repeatVasp/Iter2-Nsw2.00/INCAR",
    "test/repeatVasp/Iter2-Nsw2.00/KPOINTS",
    "test/repeatVasp/Iter2-Nsw2.00/POSCAR",
    "test/repeatVasp/Iter2-Nsw2.00/POTCAR",
    "test/repeatVasp/test.sh",
    "test/test_calcinspector.rb",
    "test/test_incar.rb",
    "test/test_kpoints.rb",
    "test/test_outcar.rb",
    "test/test_poscar.rb",
    "test/test_potcar.rb",
    "test/test_vaspdir.rb",
    "test/test_vaspgeomopt.rb",
    "test/vaspdir/finished/CONTCAR",
    "test/vaspdir/finished/INCAR",
    "test/vaspdir/finished/KPOINTS",
    "test/vaspdir/finished/OUTCAR",
    "test/vaspdir/finished/POSCAR",
    "test/vaspdir/finished/POTCAR",
    "test/vaspdir/lack-INCAR/KPOINTS",
    "test/vaspdir/lack-INCAR/POSCAR",
    "test/vaspdir/lack-INCAR/POTCAR",
    "test/vaspdir/lack-KPOINTS/INCAR",
    "test/vaspdir/lack-KPOINTS/POSCAR",
    "test/vaspdir/lack-KPOINTS/POTCAR",
    "test/vaspdir/lack-POSCAR/INCAR",
    "test/vaspdir/lack-POSCAR/KPOINTS",
    "test/vaspdir/lack-POSCAR/POTCAR",
    "test/vaspdir/lack-POTCAR/INCAR",
    "test/vaspdir/lack-POTCAR/KPOINTS",
    "test/vaspdir/lack-POTCAR/POSCAR",
    "test/vaspdir/locked/INCAR",
    "test/vaspdir/locked/KPOINTS",
    "test/vaspdir/locked/POSCAR",
    "test/vaspdir/locked/POTCAR",
    "test/vaspdir/not-yet/INCAR",
    "test/vaspdir/not-yet/KPOINTS",
    "test/vaspdir/not-yet/POSCAR",
    "test/vaspdir/not-yet/POTCAR",
    "test/vaspdir/started/CONTCAR",
    "test/vaspdir/started/INCAR",
    "test/vaspdir/started/KPOINTS",
    "test/vaspdir/started/OUTCAR",
    "test/vaspdir/started/POSCAR",
    "test/vaspdir/started/POTCAR",
    "test/vaspgeomopt/ended-Iter1/try00/CONTCAR",
    "test/vaspgeomopt/ended-Iter1/try00/INCAR",
    "test/vaspgeomopt/ended-Iter1/try00/KPOINTS",
    "test/vaspgeomopt/ended-Iter1/try00/OUTCAR",
    "test/vaspgeomopt/ended-Iter1/try00/POSCAR",
    "test/vaspgeomopt/ended-Iter1/try00/POTCAR",
    "test/vaspgeomopt/ended-Iter1/try01/INCAR",
    "test/vaspgeomopt/ended-Iter1/try01/KPOINTS",
    "test/vaspgeomopt/ended-Iter1/try01/OUTCAR",
    "test/vaspgeomopt/ended-Iter1/try01/POSCAR",
    "test/vaspgeomopt/ended-Iter1/try01/POTCAR",
    "test/vaspgeomopt/ended-Iter2/try00/CONTCAR",
    "test/vaspgeomopt/ended-Iter2/try00/INCAR",
    "test/vaspgeomopt/ended-Iter2/try00/KPOINTS",
    "test/vaspgeomopt/ended-Iter2/try00/OUTCAR",
    "test/vaspgeomopt/ended-Iter2/try00/POSCAR",
    "test/vaspgeomopt/ended-Iter2/try00/POTCAR",
    "test/vaspgeomopt/ended-Iter2/try01/INCAR",
    "test/vaspgeomopt/ended-Iter2/try01/KPOINTS",
    "test/vaspgeomopt/ended-Iter2/try01/OUTCAR",
    "test/vaspgeomopt/ended-Iter2/try01/POSCAR",
    "test/vaspgeomopt/ended-Iter2/try01/POTCAR",
    "test/vaspgeomopt/not-yet/try00/INCAR",
    "test/vaspgeomopt/not-yet/try00/KPOINTS",
    "test/vaspgeomopt/not-yet/try00/POSCAR",
    "test/vaspgeomopt/not-yet/try00/POTCAR",
    "test/vaspgeomopt/prepare_next/try00/CHG",
    "test/vaspgeomopt/prepare_next/try00/CHGCAR",
    "test/vaspgeomopt/prepare_next/try00/CONTCAR",
    "test/vaspgeomopt/prepare_next/try00/DOSCAR",
    "test/vaspgeomopt/prepare_next/try00/EIGENVAL",
    "test/vaspgeomopt/prepare_next/try00/INCAR",
    "test/vaspgeomopt/prepare_next/try00/KPOINTS",
    "test/vaspgeomopt/prepare_next/try00/OSZICAR",
    "test/vaspgeomopt/prepare_next/try00/OUTCAR",
    "test/vaspgeomopt/prepare_next/try00/PCDAT",
    "test/vaspgeomopt/prepare_next/try00/POSCAR",
    "test/vaspgeomopt/prepare_next/try00/POTCAR",
    "test/vaspgeomopt/prepare_next/try00/WAVECAR",
    "test/vaspgeomopt/prepare_next/try00/XDATCAR",
    "test/vaspgeomopt/prepare_next/try00/vasprun.xml",
    "test/vaspgeomopt/started/try00/INCAR",
    "test/vaspgeomopt/started/try00/KPOINTS",
    "test/vaspgeomopt/started/try00/POSCAR",
    "test/vaspgeomopt/started/try00/POTCAR",
    "test/vaspgeomopt/till01/try00/CONTCAR",
    "test/vaspgeomopt/till01/try00/INCAR",
    "test/vaspgeomopt/till01/try00/KPOINTS",
    "test/vaspgeomopt/till01/try00/OUTCAR",
    "test/vaspgeomopt/till01/try00/POSCAR",
    "test/vaspgeomopt/till01/try00/POTCAR",
    "test/vaspgeomopt/till01/try01/INCAR",
    "test/vaspgeomopt/till01/try01/KPOINTS",
    "test/vaspgeomopt/till01/try01/POSCAR",
    "test/vaspgeomopt/till01/try01/POTCAR",
    "vasputils.gemspec"
  ]
  s.homepage = "http://github.com/ippei94da/vasputils"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Utilities for VASP, first-principles calculation code."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, [">= 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 1.1.3"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<crystalcell>, [">= 0.0.0"])
      s.add_development_dependency(%q<mageo>, [">= 0.0.0"])
      s.add_development_dependency(%q<malge>, [">= 0.0.1"])
      s.add_development_dependency(%q<maset>, [">= 0.0.0"])
      s.add_development_dependency(%q<comana>, [">= 0.0.9"])
      s.add_development_dependency(%q<builtinextension>, [">= 0.0.3"])
    else
      s.add_dependency(%q<rdoc>, [">= 3.12"])
      s.add_dependency(%q<bundler>, [">= 1.1.3"])
      s.add_dependency(%q<jeweler>, [">= 1.8.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<crystalcell>, [">= 0.0.0"])
      s.add_dependency(%q<mageo>, [">= 0.0.0"])
      s.add_dependency(%q<malge>, [">= 0.0.1"])
      s.add_dependency(%q<maset>, [">= 0.0.0"])
      s.add_dependency(%q<comana>, [">= 0.0.9"])
      s.add_dependency(%q<builtinextension>, [">= 0.0.3"])
    end
  else
    s.add_dependency(%q<rdoc>, [">= 3.12"])
    s.add_dependency(%q<bundler>, [">= 1.1.3"])
    s.add_dependency(%q<jeweler>, [">= 1.8.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<crystalcell>, [">= 0.0.0"])
    s.add_dependency(%q<mageo>, [">= 0.0.0"])
    s.add_dependency(%q<malge>, [">= 0.0.1"])
    s.add_dependency(%q<maset>, [">= 0.0.0"])
    s.add_dependency(%q<comana>, [">= 0.0.9"])
    s.add_dependency(%q<builtinextension>, [">= 0.0.3"])
  end
end

