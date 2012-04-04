# OUTCAR をパースする。
# 精確には行わず、必要な情報だけをピックアップする感じ。
#
# あまり頑張らないことにした理由は以下。
#   OUTCAR がどう出力されるのかがよくわからない。
#   本来は vasp のソースを見て決めるべきだろう。
#   やるとすればかなり大掛かりなプロジェクトになるが、そのわりには旨味が少ない。
#   grep でなんとかなるし。
#
# 基本的に終了した計算から情報を取り出すには vasprun.xml を読む。
# OUTCAR は終了する前も含めてなんか簡単に見るために使う、という位置付けで。

module Outcar
	#toten は全 electronic and ionic steps のを flat に並べただけのもの。
	#必要なら構造化するが、現状その予定はない。
	#attr_reader :name
	#attr_reader :ionic_steps, :electronic_steps, :totens, :volumes, :elapsed_time

	def self.load_file(file)
		results = {}
		results[:name] = file
		results[:irreducible_kpoints] = nil
		results[:electronic_steps   ] = 0
		results[:ionic_steps        ] = 0
		results[:totens             ] = []
		results[:volumes            ] = []
		results[:elapsed_time       ] = nil
		results[:normal_ended       ] = false

		lines = File.readlines(file)
		lines.each do |line|
			if /Found\s+(\d+)\s+irreducible k-points/i =~ line
				results[:irreducible_kpoints] = $1.to_i
			end

			if /^-* Iteration\s+(\d+)/ =~ line
				results[:ionic_steps     ] = $1.to_i
				results[:electronic_steps] += 1
			end

			#if /free\s+energy\s+TOTEN\s+=\s(.*)\s+eV/ =~ line
			if /TOTEN\s+=\s(.*)\s+eV/ =~ line
				results[:totens] << $1.to_f
			end

			if /volume of cell :\s+(\d+\.\d+)$/ =~ line
				results[:volumes] << $1.to_f
			end

			if (/Elapsed time \(sec\):\s+(\d+\.\d+)/ =~ line)
				results[:elapsed_time] = $1.to_f
			end
		end

		results[:normal_ended] = true if (/Voluntary context switches:/ =~ lines[-1])

		results
	end
end
