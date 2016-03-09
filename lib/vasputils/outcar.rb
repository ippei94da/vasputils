#! /usr/bin/env ruby
# coding: utf-8
#
#require "vasputils.rb"

# OUTCAR をパースする。
# 精確には行わず、必要な情報だけをピックアップする感じ。
#
# あまり頑張らないことにした理由は以下。
#       OUTCAR がどう出力されるのかがよくわからない。
#       本来は vasp のソースを見て決めるべきだろう。
#       やるとすればかなり大掛かりなプロジェクトになるが、そのわりには旨味が少ない。
#       grep でなんとかなるし。
#
# 基本的に終了した計算から情報を取り出すには vasprun.xml を読む。
# だが、計算途中の状態を知りたいとうのもよくある要求。
# こういう場合には vasprun.xml はきちんと閉じた xmlにならないので
# 使えない。
# OUTCAR は終了する前も含めてなんか簡単に見るために使う、という位置付けで。
module VaspUtils::Outcar
  #toten は全 electronic and ionic steps のを flat に並べただけのもの。
  #必要なら構造化するが、現状その予定はない。
  #attr_reader :name
  #attr_reader :ionic_steps, :electronic_steps, :totens, :volumes, :elapsed_time

  def self.load_file(file)
    raise Errno::ENOENT unless File.exist?(file)

    results = {}
    results[:name] = file
    #results[:irreducible_kpoints] = nil
    #results[:electronic_steps   ] = 0
    #results[:ionic_steps                ] = 0
    #results[:totens                         ] = []
    #results[:volumes                        ] = []
    results[:elapsed_time               ] = nil
    results[:normal_ended               ] = false

    lines = `grep Iteration #{file}`.split("\n")
    results[:electronic_steps] = lines.size
    /^-* Iteration\s+(\d+)/ =~ lines[-1]
    results[:ionic_steps         ] = $1.to_i

    results[:totens] = `grep TOTEN #{file}`.split("\n").map do |line|
      /TOTEN\s+=\s(.*)\s+eV/ =~ line
      $1.to_f
    end

    line = `tail -q -n 8 #{file}| head -n 1`
    if (/Elapsed time \(sec\):\s+(\d+\.\d+)/ =~ line)
      results[:elapsed_time] = $1.to_f
    end

    line = `tail -q -n 1 #{file}`
    results[:normal_ended] = true if (/Voluntary context switches:/ =~ line)

    results
  end
end
