#! /usr/bin/env ruby
# coding: utf-8

require 'yaml'
#require 'vasputils'


# Class to deal with private settings for VaspUtils.

class VaspUtils::Setting
  class NoEntryError < Exception; end

  #
  def initialize(file = ENV["HOME"] + "/.vasputils")
    @data = YAML.load_file(file)
  end

  # Return value corresponding to a key.
  # Raise VaspUtils::Setting::NoEntryError if the key is not exist.
  def [](key)
    unless @data.include? key 
      raise NoEntryError, key
    end
    @data[key]
  end

  #def get(key)
  #  unless @data.include? key 
  #    raise NoEntryError, key
  #  end
  #  @data[key]
  #end
end

