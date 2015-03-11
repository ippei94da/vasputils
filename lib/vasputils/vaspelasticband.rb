#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "fileutils"


class VaspUtils::VaspElasticBand < Comana::ComputationManager
  # path0 and path1 for POSCAR's
  def self.generate(path0, path1, new_dir_name, num_images = 1)
    Dir.mkdir new_dir_name

    (num_images + 2).times do |i|
      Dir.mkdir new_dir_name + sprintf("/%02d", i)
    end

    poscar0 = VaspUtils::Poscar.load_file(path0)
    poscar1 = VaspUtils::Poscar.load_file(path1)

    lattice_axes = poscar0.latticeaxes

    #原子数が合わないときにエラー？
    (num_images + 2).times do |image_id|
      atoms0 = poscar0.atoms
      atoms0.size.times do |i|
        3.times do |axis|
          coord0 = atoms0[i].coordinates[axis]
          coord1 = atoms1[i].coordinates[axis]

          if (coord1 - coord0)> 0.5
            coord1 -= 1.0 
          elsif (coord1 - coord0) < -0.5
            coord1 += 1.0 
          end

          new_coord =
            coord0 * (image_id) / (num_images +1)+ 
            coord0 * (num_images +1 - image_id) / (num_images +1)+ 
        end

      end


    end

    def 


    #INCAR, KPOINTS, POTCAR があれば $targetDir にコピー

    #INCAR をいじる
    #IMAGES = num_images
    #SPRING = 0

    #{00..xx} に POSCAR を作る ####################################
    #  # 原子座標の処理
    #  {
    #$_ =~ /\s*(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s*(.*)$/;
    #($coord1[1], $coord1[2], $coord1[3], $other1) = ($1, $2, $3, $4);
    ##$poscar2[$m] =~ /\s*(\d\.\d+)\s+(\d\.\d+)\s+(\d\.\d+)\s*(.*)$/;
    #$poscar2[$m] =~ /\s*(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s*(.*)$/;
    #($coord2[1], $coord2[2], $coord2[3], $other2) = ($1, $2, $3, $4);
    ##
    ##
    ## 座標を決定する
    #for ($k = 1; $k <= 3; $k ++) {
    #    # 同じ座標がセルを地球周りしてないか、していたら大きい方を小さく
    #    if ($coord1[$k] - $coord2[$k] > 0.5) {
    #  $coord1[$k] -= 1;
    #  print "atom of line $m moves a half of supercell.\n";
    #    } elsif ($coord1[$k] - $coord2[$k] < -0.5) {
    #  $coord2[$k] -= 1;
    #  print "atom of line $m moves a half of supercell.\n";
    #    }

    #    $coord_out[$k] = 
    #  (($images + 1 - $n) * $coord1[$k] + $n * $coord2[$k] )
    #  / ($images + 1);
    #}
  end

  def self.interpolate_coord(coord0, coord1, nth, num_image)

  end


  def self

  private

end

