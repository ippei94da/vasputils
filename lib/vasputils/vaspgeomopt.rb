#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
gem "comana"
require "comana"

#
#
#
class VaspGeomOpt < Comana
  #
  def initialize()
  end

  def send_command
    raise NotImplementedError, "#{self.class}::send_command need to be redefined"
  end

  def set_parameters
    raise NotImplementedError, "#{self.class}::set_parameters need to be redefined"
    @lockdir    = "vaspgeomopt_lock"
    @alive_time = 3600
    @outfiles   = [] # Files only to output should be indicated.
  end

  # Return true if the condition is satisfied.
  # E.g., when calculation output contains orthodox ending sequences.
  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

