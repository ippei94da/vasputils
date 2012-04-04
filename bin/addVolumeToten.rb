#! /usr/bin/ruby

#標準入力から文字列リストを受け取り、
#ファイル名と思しきものがあれば、それに最終的な volume と TOTEN を追加する。
#CONTCAR も指定できるが、同じディレクトリに OUTCAR が存在する必要がある。

require "vasputils/outcarparser.rb"

STDIN.each do |line|
	file = line.strip.sub( 'CONTCAR', 'OUTCAR' )
	if File.exist?( file )
		outcar = ParseOutcar.new( file )
		volume = outcar.volumes[-1]
		toten = outcar.totens[-1]
		printf( "%s, %6.2f, %f\n", line.chomp, volume, toten )
	else
		puts line
	end
end
