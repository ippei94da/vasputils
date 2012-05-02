#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
gem "comana"
require "comana"

#
#
#
class VaspGeomOpt < Comana

  def calculate
    最新の状態を確認する。

    配下のディレクトリをすべて確認する。
      VaspDir 以外のものは無視。
      VaspDir のうち、名前が最後のものだけ注目。それ以外は無視。
        <=> が定義できるような命名規則がある筈で、
        それは大抵単純な昇順ソートでいけるようなものだろう。
      注目した VaspDir が yet なら実行し、続ける。
      yet 以外なら例外。

    VaspDir になっているか。


    raise NotImplementedError, "#{self.class}::send_command need to be redefined"

  end

  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

