#! /usr/bin/env ruby
# coding: utf-8

require "vasputils.rb"

# see http://cms.mpi.univie.ac.at/vasp/vasp/INCAR_File.html
#
# INCAR のフォーマット
#   - 基本 1行 1項目。
#   - = 区切りで左辺の項目名に対して右辺の値になる。
#   - 半角＃ のあと、コメント
#
# TODO, Future feature
# INCAR のフォーマット
#   - 右辺のあとの文字列は、セミコロンでなければ無視される。
#   - ; 区切りで1行に複数の項目を設定できる。
#   - \ で次の行に設定を続けることができる。

# Class to utilize INCAR file of VASP.
# まず、自分で使う範囲だけ作る。
# あとで余力があれば精密化する。
module VaspUtils::Incar
  #
  #def initialize()
  #end
  
  # 与えられた IO を読み込み、INCAR として解析したハッシュを返す。
  def self.parse(io)
    results = {}
    io.each_line do |line|
      line.sub!(/\#.*/, "") # コメント文字以降を削除
      next unless /=/ =~ line
      if /(.*)=(.*)/ =~ line
        key = $1.strip
        val = $2.strip
        val.sub!(/\s.*$/, "")
        next if key.empty?
        results[key] = val
      end
    end
    return results
  end

  # 与えられた名前のファイルを INCAR として解析したハッシュを返す。
  def self.load_file(file)
    io = File.open(file, "r")
    return self.parse(io)
  end

  # 与えられたデータ対(ハッシュ)を io に書き出す。
  # io が nil の場合は INCAR 形式文字列を返す。
  # (改行文字を埋め込んでおり、配列化していない)
  def self.dump(pairs, io = nil)
    result = pairs.map { |key, val|
      "#{key} = #{val}"
    }.join("\n")

    if io # is defined
      io.print result
    else
      return result
    end
  end
end

