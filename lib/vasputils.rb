require "rubygems"
require "malge"
require "pathname"
require "mageo"
require "comana"
require "crystalcell"
require "float/equalindelta"
require "string/integer"
require "string/float"
require "gnuplot"
require 'nokogiri'

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
require "vasputils/vasprunxml.rb"
require "vasputils/vaspebmdir.rb"
require "vasputils/xdatcar.rb"
