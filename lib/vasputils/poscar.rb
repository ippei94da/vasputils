#! /usr/bin/ruby
# coding: utf-8

require "rubygems"
#gem "crystalcell"
require "crystalcell"

# Class to manage POSCAR format of VASP.
# 
# parse と dump のどちらかだけでなく、両方を統括して扱うクラス。
class VaspUtils::Poscar

  class ElementMismatchError < Exception; end
  class ParseError < Exception; end

  attr_reader :comment, :scale, :elements, :nums_elements,
    :selective_dynamics, :direct, :positions
  attr_accessor :axes

  def initialize(hash)
    hash.each do |key,val|
      @comment            = val if :comment            ==key
      @scale              = val if :scale              ==key
      @axes               = val if :axes               ==key
      @elements           = val if :elements           ==key
      @nums_elements      = val if :nums_elements      ==key
      @selective_dynamics = val if :selective_dynamics ==key
      @direct             = val if :direct             ==key
      @positions          = val if :positions          ==key
    end
  end

  # io を読み込んで Poscar クラスインスタンスを返す。
  # 構文解析できなければ例外 Poscar::ParseError を投げる。
  def self.parse(io)
    # analyze POSCAR.

    begin
      #line 1: comment (string)
      comment = io.readline.chomp

      #line 2: universal scaling factor (float)
      scale = io.readline.to_f
      raise "Poscar.load_file cannot use negative scaling factor.\n" if scale < 0

      #line 3-5: axes (3x3 Array of float)
      axes = []
      3.times do |i| #each axis of a, b, c.
        vec = io.readline.strip.split(/\s+/) #in x,y,z directions
        axes << vec.collect! { |i| i.to_f * scale } #multiply scaling factor
      end

      # Element symbol (vasp 5). Nothing in vasp 4.

      #elements = io.readline.strip.split(/\s+/).map{|i| i.to_i}
      vals = io.readline.strip.split(/\s+/)
      elements = nil
      if vals[0].to_i == 0
        elements = vals
        vals = io.readline.strip.split(/\s+/)
      end
      nums_elements = vals.map{|i| i.to_i}

      # 'Selective dynamics' or not (bool)
      line = io.readline
      selective_dynamics = false
      if line =~ /^\s*s/i
        selective_dynamics = []
        line = io.readline      # when this situation, reading one more line is nessesarry
      end

      if (line =~ /^\s*d/i) # allow only 'Direct' now
        direct = true
      else
        raise "Not 'direct' indication."
      end

      positions = []
      nums_elements.size.times do |elem_index|
        nums_elements[elem_index].times do |index|
          items = io.readline.strip.split(/\s+/)
          positions << items[0..2].map {|coord| coord.to_f}

          if selective_dynamics
            mov_flags = []
            if items.size >= 6 then
              items[3..5].each do |i|
                (i =~ /^t/i) ? mov_flags << true : mov_flags << false
              end
              selective_dynamics << mov_flags
            end
          end
        end
      end
    rescue EOFError
      raise ParseError, "end of file reached"
    end

    options = {
      :comment            => comment           ,
      :scale              => scale             ,
      :axes               => axes              ,
      :elements           => elements          ,
      :nums_elements      => nums_elements     ,
      :selective_dynamics => selective_dynamics,
      :direct             => direct            ,
      :positions              => positions             ,
    }
    self.new(options)
  end

  # file で与えられた名前のファイルを読み込んで CrystalCell::Cell クラスインスタンスを返す。
  # 構文解析できなければ例外 Poscar::ParseError を投げる。
  def self.load_file(file)
    io = File.open(file, "r")
    self.parse(io)
  end

  # CrystalCell::Cell クラスインスタンスから
  # Poscar クラスインスタンスを生成
  def self.load_cell(cell)
    elements = cell.elements.sort.uniq

    atoms = cell.atoms.sort_by{|atom| atom.element}

    nums_elements = {}
    atoms.each do |atom|
      nums_elements[atom.element] ||= 0
      nums_elements[atom.element] += 1
    end
    nums_elements = elements.map{|elem| nums_elements[elem]}

    positions = []
    movable_flags = []
    selective_dynamics = false
    atoms.each do |atom|
      positions << atom.position
      movable_flags << atom.movable_flags
      selective_dynamics = true if movable_flags
    end

    selective_dynamics = movable_flags if movable_flags

    options = {
      :comment            => cell.comment           ,
      :scale              => 1.0               ,
      :axes               => cell.axes.to_a,
      :elements           => elements          ,
      :nums_elements      => nums_elements     ,
      :selective_dynamics => selective_dynamics,
      :direct             => true,
      :positions          => positions             ,
    }
    self.new(options)
  end

  # POSCAR 形式で書き出す。
  # cell は CrystalCell::Cell クラスインスタンスと同等のメソッドを持つもの。
  # elems は書き出す元素の順番。
  #       elems が cell の持つ元素リストとマッチしなければ
  #       例外 Poscar::ElementMismatchError を投げる。
  #       nil ならば、原子の element でソートした順に出力する。
  #
  # io は書き出すファイルハンドル。
  # 'version' indicates a poscar style for vasp 4 or 5.
  #def dump(io, elems = nil, version = 5)
  def dump(io, version = 5)
    #elems = @elements.sort unless elems
    #unless (Mapping::map?(@elements.uniq, elems){ |i, j| i == j })
    #    raise ElementMismatchError,
    #    "elems [#{elems.join(",")}] mismatches to cell.elements [#{cell.elements.join(",")}."
    #end

    io.puts @comment
    io.puts "1.0" #scale
    3.times do |i|
      io.printf("  % 18.15f    % 18.15f    % 18.15f\n", @axes[i][0], @axes[i][1], @axes[i][2]
      )
    end

    # Element symbols for vasp 5.
    #pp @elements
    if version >= 5
      io.puts @elements.join(' ')
    end

    # Atom numbers.
    io.puts @nums_elements.join(' ')

    # Selective dynamics
    io.puts "Selective dynamics" if @selective_dynamics
    io.puts "Direct"

    #pp @selective_dynamics

    # positions of atoms
    @positions.size.times do |i|
      str = sprintf("    % 18.15f    % 18.15f    % 18.15f", * @positions[i])
      if @selective_dynamics
        #pp @movable_flags
        if @movable_flags
          @movable_flags[i].each do |flag|
            (flag == true) ?  str += " T" : str += " F"
          end
        else
          str += " T T T"
        end
      end
      io.puts str
    end
  end

  def to_cell
    axes = CrystalCell::LatticeAxes.new( @axes)

    atoms = []
    total_id = 0
    #pp @positions
    @nums_elements.each_with_index do |num, elem_id|
      num.times do |atom_id|
        element = elem_id
        element = @elements[elem_id] if @elements

        movable_flags = nil
        if @selective_dynamics
          movable_flags = @selective_dynamics[total_id]
        end
        atoms << CrystalCell::Atom.new(
          element, 
          @positions[total_id],
          movable_flags
        )
        total_id += 1
      end
    end

    cell = CrystalCell::Cell.new(axes, atoms)
  end

  # selective_dynamics は常に on にする。
  # 各要素の真偽値は 2つの POSCAR の論理積。
  # 指定がなければ true と見做す。
  # ratio は poscar1 の比率。0だと poscar0 に、
  # 1だとposcar1 となる。
  # Return Poscar class instance
  def self.interpolate(poscar0, poscar1, ratio, periodic = false)
    axes0 = poscar0.axes
    axes1 = poscar1.axes
    new_axes = []
    3.times do |i|
      new_axes << self.interpolate_coords(axes0[i], axes1[i], ratio)
    end

    raise PoscarMismatchError unless poscar0.elements == poscar1.elements
    raise PoscarMismatchError unless poscar0.nums_elements == poscar1.nums_elements

    new_positions = []
    new_selective_dynamics = []
    poscar0.positions.size.times do |i|
      ##positions
      coord0 = poscar0.positions[i]
      coord1 = poscar1.positions[i]
      coord1 = self.periodic_nearest(coord0, coord1) if periodic
      new_positions << self.interpolate_coords(
        coord0, coord1, ratio)

      ##selective_dynamics
      いないばあい
      もいっこループ
      sd0 = poscar0.selective_dynamics[i]
      sd1 = poscar1.selective_dynamics[i]
      new_selective_dynamics << (sd0 && sd1)
    end

    hash = {
      :comment => "Generated by interpolation of #{ratio}",
      :scale   => 1.0,
      :axes    => new_axes,
      :elements           => poscar0.elements,
      :nums_elements      => poscar0.nums_elements,
      :selective_dynamics => new_selective_dynamics
      :direct             => true,
      :positions          => new_positions
    }
    correct = VaspUtils::Poscar.new(hash)

  end

  # selective_dynamics は常に on にする。
  def interpolate(poscar, ratio, periodic = false)
    self.class.interpolate(self, poscar, ratio, periodic = false)
  end

  def self.interpolate_coords(coord0, coord1, ratio)
    ((coord0.to_v3d * (1-ratio) + coord1.to_v3d * ratio)).to_a
  end

  # 
  def self.periodic_nearest(coord0, coord1)
    pcell = CrystalCell::PeriodicCell.new( [
      [1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0],
    ])
    result = coord1.to_v3di + pcell.nearest_direction( coord0.to_v3di, coord1.to_v3di)
    result.to_a
  end

  def ==(other)
    result = true
    result = false unless @comment             == other.comment            
    result = false unless @scale               == other.scale              
    result = false unless @axes                == other.axes               
    result = false unless @elements            == other.elements           
    result = false unless @nums_elements       == other.nums_elements      
    result = false unless @selective_dynamics  == other.selective_dynamics 
    result = false unless @direct              == other.direct             
    result = false unless @positions           == other.positions          
    result
  end


  private

end

