#! /usr/bin/ruby
# coding: utf-8

# Class to manage XDATCAR format of VASP.
# 
# 基本的に、読み込みだけを行う。
class VaspUtils::Xdatcar

  class ElementMismatchError < Exception; end
  class ParseError < Exception; end

  attr_reader :comment, :scale, :elements, :nums_elements,
    :direct, :steps_positions
  attr_accessor :axes

  def initialize(hash)
    hash.each do |key,val|
      @comment            = val if :comment            ==key
      @scale              = val if :scale              ==key
      @axes               = val if :axes               ==key
      @elements           = val if :elements           ==key
      @nums_elements      = val if :nums_elements      ==key
      #@selective_dynamics = val if :selective_dynamics ==key
      @direct             = val if :direct             ==key
      @steps_positions     = val if :steps_positions          ==key
    end
  end

  # io を読み込んで Xdatcar クラスインスタンスを返す。
  # 構文解析できなければ例外 Xdatcar::ParseError を投げる。
  def self.parse(io)
    # analyze XDATCAR.

    begin
      #line 1: comment (string)
      comment = io.readline.chomp

      #line 2: universal scaling factor (float)
      scale = io.readline.to_f
      raise "Xdatcar.load_file cannot use negative scaling factor.\n" if scale < 0

      #line 3-5: axes (3x3 Array of float)
      axes = []
      3.times do |i| #each axis of a, b, c.
        vec = io.readline.strip.split(/\s+/) #in x,y,z directions
        axes << vec.collect! { |j| j.to_f * scale } #multiply scaling factor
      end

      vals = io.readline.strip.split(/\s+/)
      elements = nil
      if vals[0].to_i == 0
        elements = vals
        vals = io.readline.strip.split(/\s+/)
      end
      nums_elements = vals.map{|i| i.to_i}

      io.readline # should be empty line
      steps_positions = []
      index = 0
      io.readlines.each do |line|
        steps_positions[index] ||= []
        if line =~ /^\s*$/
          index += 1
        else
          steps_positions[index] << line.strip.split(/\s+/).map {|coord| coord.to_f}
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
      :steps_positions          => steps_positions         ,
    }
    self.new(options)
  end

  # file で与えられた名前のファイルを読み込んで self クラスインスタンスを返す。
  # 構文解析できなければ例外 Xdatcar::ParseError を投げる。
  def self.load_file(file)
    io = File.open(file, "r")
    self.parse(io)
  end

end

