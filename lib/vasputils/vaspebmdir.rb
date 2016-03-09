#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "fileutils"


class VaspUtils::VaspEbmDir < Comana::ComputationManager

  # path0 and path1 for POSCAR's
  # INCAR などは以下から検索して最初に見つかった物をベースとする。
  #   path0 と同じディレクトリ
  #   path1 と同じディレクトリ
  #   path0 の親ディレクトリ
  #   path1 の親ディレクトリ
  def self.generate(path0, path1, new_dir_name, num_images, periodic)
    path0 = Pathname.new(path0)
    path1 = Pathname.new(path1)
    poscar0 = VaspUtils::Poscar.load_file(path0)
    poscar1 = VaspUtils::Poscar.load_file(path1)

    Dir.mkdir new_dir_name
    (num_images + 2).times do |i|
      subdir_name = new_dir_name + sprintf("/%02d", i)
      ratio = i.to_f/(num_images + 1).to_f 
      poscar = VaspUtils::Poscar.interpolate(poscar0, poscar1, ratio, periodic)
      Dir.mkdir subdir_name
      File.open("#{subdir_name}/POSCAR", "w") do |io|
        poscar.dump(io)
      end
    end

    dir0 = path0.dirname
    dir1 = path1.dirname
    paths = {}
    ['INCAR', 'KPOINTS', 'POTCAR'].each do |basename|
      path = 
        [dir0, dir1, dir0.parent, dir1.parent].find { |dir|
          File.exist?(dir + basename)
        }
      paths[basename] = path if path
    end

    paths.each do |file, path|
      FileUtils.cp( "#{path}/#{file}", new_dir_name.to_s)
    end

    incar_path = "#{new_dir_name}/INCAR" 
    incar = VaspUtils::Incar.load_file incar_path

    incar.data["IMAGES"] = num_images.to_s
    incar.data["SPRING"] = 0.to_s
    File.open( incar_path, "w") do |io|
      incar.dump(io)
    end
  end
end

