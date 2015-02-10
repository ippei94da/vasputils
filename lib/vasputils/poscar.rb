#! /usr/bin/ruby
# coding: utf-8

require "rubygems"
#gem "crystalcell"
require "crystalcell"

# Class to manage POSCAR format of VASP.
# 
# parse と dump のどちらかだけでなく、両方を統括して扱うクラス。
#
# MEMO
# POSCAR 自身は元素の情報を持っていない。
# POSCAR が native に持っている情報だけを取り扱う。
# Poscar では個々の原子が何の element であるかという情報を取り扱わない。
# 1番目の種類の原子種が何かだけを扱う。
# こうしておくことで POTCAR がない環境でも POSCAR を扱うことができる。
#
# VASP 5 系を使うようになれば事情が変わるだろう。
class VaspUtils::Poscar

    class ElementMismatchError < Exception; end
    class ParseError < Exception; end

    def initialize(hash)
        hash.each do |key,val|
            @comment            = if :comment            ==key
            @scale              = if :scale              ==key
            @axes               = if :axes               ==key
            @elements           = if :elements           ==key
            @nums_elements      = if :nums_elements      ==key
            @selective_dynamics = if :selective_dynamics ==key
            @direct             = if :direct             ==key
            @atoms              = if :atoms              ==key
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
            if vals[0].to_i == 0
                elements = vals
                nums_elements = io.readline.strip.split(/\s+/).map{|i| i.to_i}
            else
                elements = []
                vals.size.times { |i| elements << i }
                nums_elements = vals.map{|i| i.to_i}
            end

            # 'Selective dynamics' or not (bool)
            line = io.readline
            if line =~ /^\s*s/i
                selective_dynamics = true
                line = io.readline      # when this situation, reading one more line is nessesarry
            end

            if (line =~ /^\s*d/i) # allow only 'Direct' now
                direct = true
            else
                raise "Not 'direct' indication."
            end

            # atom positions
            # e.g., positions_of_elements
            # e.g., movable_flags_of_elements

            atoms = []
            nums_elements.size.times do |elem_index|
                nums_elements[elem_index].times do |index|
                items = io.readline.strip.split(/\s+/)
                pos = items[0..2].map {|coord| coord.to_f}

                mov_flags = []
                if items.size >= 6 then
                    items[3..5].each do |i|
                        (i =~ /^t/i) ? mov_flags << true : mov_flags << false
                    end
                    atoms << CrystalCell::Atom.new(elements[elem_index], pos, mov_flags)
                else
                    atoms << CrystalCell::Atom.new(elements[elem_index], pos)
                end
                end
            end
        rescue EOFError
            raise ParseError, "end of file reached"
        end

        #cell = CrystalCell::Cell.new(axes, atoms)
        #cell.comment = comment
        #cell
        options = {
            :comment            = comment            
            :scale              = scale              
            :axes               = axes               
            :elements           = elements           
            :nums_elements      = nums_elements      
            :selective_dynamics = selective_dynamics 
            :direct             = direct             
            :atoms              = atoms              
        }
        self.new(options)
    end

    # file で与えられた名前のファイルを読み込んで CrystalCell::Cell クラスインスタンスを返す。
    # 構文解析できなければ例外 Poscar::ParseError を投げる。
    def self.load_file(file)
        io = File.open(file, "r")
        self.parse(io)
    end

    # POSCAR 形式で書き出す。
    # cell は CrystalCell::Cell クラスインスタンスと同等のメソッドを持つもの。
    # elems は書き出す元素の順番。
    #       elems が cell の持つ元素リストとマッチしなければ
    #       例外 Poscar::ElementMismatchError を投げる。
    # io は書き出すファイルハンドル。
    # 'version' indicates a poscar style for vasp 4 or 5.
    def self.dump(cell, elems, io, version = 5)
        unless (Mapping::map?(cell.elements.uniq, elems){ |i, j| i == j })
            raise ElementMismatchError,
            "elems [#{elems.join(",")}] mismatches to cell.elements [#{cell.elements.join(",")}."
        end

        io.puts cell.comment
        io.puts "1.0" #scale
        3.times do |i|
            io.printf("  % 18.15f    % 18.15f    % 18.15f\n", cell.axes[i][0], cell.axes[i][1], cell.axes[i][2]
            )
        end

        # Element symbols for vasp 5.
        if version >= 5
            io.puts cell.atoms.map {|atom| atom.element}.uniq.join(" ")
        end

        # Atom numbers.
        elem_list = Hash.new
        elems.each do |elem|
            elem_list[ elem ] = cell.atoms.select{ |atom| atom.element == elem }
        end
        io.puts(elems.map { |elem| elem_list[elem].size }.join(" "))

        # Selective dynamics
        # どれか1つでも getMovableFlag が真であれば Selective dynamics をオンにする
        selective_dynamics = false
        cell.atoms.each do |atom|
            if atom.movable_flags
                selective_dynamics = true
                io.puts "Selective dynamics"
                break
            end
        end

        elems.each do |elem|
            elem_list[ elem ].each do |atom|
                if atom.movable_flags
                    selective_dynamics = true
                    break
                end
            end
            break if selective_dynamics
        end

        io.puts "Direct"

        # positions of atoms
        elems.each do |elem|
            elem_list[ elem ].each do |atom|
                tmp =    sprintf(
                    "    % 18.15f    % 18.15f    % 18.15f",
                    * atom.position)
                if selective_dynamics
                    if atom.movable_flags == nil
                        tmp += " T T T"
                    else
                        atom.movable_flags.each do |mov|
                            (mov == true) ?  tmp += " T" : tmp += " F"
                        end
                    end
                end
                io.puts tmp
            end
        end
    end

end

