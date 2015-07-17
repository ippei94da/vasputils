#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class VaspUtils::SinglePointCondition
  class InvalidOptionError < Exception; end
  class ArgumentError < Exception; end

  #
  def initialize
  end

  def self.integers(str)
    str.split(",").map{|val| val.to_i}
  end

  def self.floats(str)
    str.split(",").map{|val| val.to_f}
  end

  def self.check_sanity_options(options)
    counts = {:a => 0, :b => 0, :c => 0}
    if options.keys.include?(:ka)
      counts[:a] += 1
    end
    if options.keys.include?(:kb)
      counts[:b] += 1
    end
    if options.keys.include?(:kc)
      counts[:c] += 1
    end
    if options.keys.include?(:kab)
      counts[:a] += 1
      counts[:b] += 1
    end
    if options.keys.include?(:kbc)
      counts[:b] += 1
      counts[:c] += 1
    end
    if options.keys.include?(:kca)
      counts[:c] += 1
      counts[:a] += 1
    end
    if options.keys.include?(:kabc)
      counts[:a] += 1
      counts[:b] += 1
      counts[:c] += 1
    end

    if counts[:a] > 1
      raise InvalidOptionError,  "Error: ka mesh is duplicated."
    end
    if counts[:b] > 1
      raise InvalidOptionError,  "Error: kb mesh is duplicated."
    end
    if counts[:c] > 1
      raise InvalidOptionError,  "Error: kc mesh is duplicated."
    end
  end

  # Argument 'ary' is Array of Integer's.
  # Return all variation of integers less than Integer's.
  def self.mesh_points(ary)
    raise ArgumentError, "Argument ary is empty: #{ary.inspect}" if ary.empty?
    raise ArgumentError, "Argument ary is not Array: #{ary.inspect}" unless ary.is_a? Array

    if ary.size == 1
      results = Array.new
      ary[0].times do |i|
        results[i] = [i]
      end
      return results
    elsif ary.size > 1
      variation = ary.shift
      right_ary = self.mesh_points(ary)

      results = Array.new
      variation.times do |i|
        right_ary.each do |ary|
          results.push([i, *ary])
        end
      end
      return results
    else
      raise RuntimeError, "Must not happen!"
    end
  end

  def self.hash_to_s(hash)
    strs = []
    #pp hash
    hash.keys.sort.each do |key|
      if key == :encut
        val = sprintf("%06.1f", hash[key])
      else # k*
        val = sprintf("%02d", hash[key])
        #val = hash[key].to_s
      end
      strs.push( key.to_s + "_" + val)
    end
    result = strs.join(",")
    result
  end

  # src_vaspdir : template VaspDir
  # tgt_dir : target directory to include new VaspDir's.
  def generate_condition_dirs(src_vaspdir, options, tgt_dir = ".")
    self.class.check_sanity_options(options)

    @options = {}
    [:ka, :kb, :kc, :kab, :kbc, :kca, :kabc].each do |key|
      next unless options[key]
      @options[key] = self.class.integers(options[key])
    end
    [:encut].each do |key|
      next unless options[key]
      @options[key] = self.class.floats(options[key])
    end

    keys = @options.keys.sort
    # as order of 'keys'
    #


    sizes = []
    keys.each do |key|
      sizes.push( @options[key].size)
    end

    mesh_indices = self.class.mesh_points(sizes)

    conditions_list = []
    mesh_indices.each do |ary|
      conditions = {}
      keys.size.times do |i|
        key = keys[i]
        conditions[key] = @options[key][ary[i]]
      end
      conditions_list << conditions
    end

    src_vaspdir = VaspUtils::VaspDir.new(src_vaspdir)
    conditions_list.each do |conditions|
      dirname = self.class.hash_to_s(conditions)
      if File.exist? dirname
        puts "#{dirname} is already exist."
        next
      end
      dirname = tgt_dir + "/" + dirname
      src_vaspdir.mutate(dirname, conditions)
    end
  end

end

