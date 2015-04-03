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
    path1 = Pathname.new(path0)
    poscar0 = VaspUtils::Poscar.load_file(path0)
    poscar1 = VaspUtils::Poscar.load_file(path1)

    Dir.mkdir new_dir_name
    (num_images + 2).times do |i|
      subdir_name = new_dir_name + sprintf("/%02d", i)
      ratio = i.to_f/(num_images + 1).to_f 
      poscar = VaspUtils::Poscar.interpolate(poscar0, poscar1, ratio, periodic)
      #pp poscar
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

    paths.each do |path|
      FileUtils.cp path new_dir_name
    end
    if paths["INCAR"] 
      incar = Incar.load_file paths["INCAR"] 
      incar.add("IMAGES", num_images)
      incar.add("SPRING", 0)
    end
    incar.dump paths["INCAR"] 
  end


end


##!! interpolate
##
#### option analysis
##OPTIONS = {}
##op = OptionParser.new
##op.banner = [
##    "Usage: #{File.basename("#{__FILE__}")}",
##].join("\n")
##op.on("-a"    , "--aho"    , "descriptionA"){    OPTIONS[:aho] = true}
##op.on("-b val", "--bak=val", "descriptionB"){|v| OPTIONS[:bak] = v}
##op.parse!(ARGV)
##
##
##poscar0 = ARGV.shift
##poscar1 = ARGV.shift
##
###! /usr/bin/env ruby
### coding: utf-8
##
##require "pp"
##
##if ((@ARGV < 2) || (3 < @ARGV)){
##  die "USAGE: interpolatePOSCAR2 CONTCAR1 CONTCAR2 [num_images]\n";
##}
##
##($poscar1Name, $poscar2Name, $images) = @ARGV;
##if (! $images) {
##  $images = 1;         # INCAR:IMAGES のデフォルト値
##}
##
#### 2つの入力ファイルからディレクトリ名を切り出す
##$poscar1Dir = $poscar1Name;
##$poscar1Dir =~ s|/[^/]+||;
##
##$poscar2Dir = $poscar2Name;
##$poscar2Dir =~ s|/[^/]+||;
##
##
#### EBM 初期ファイルを生成するディレクトリ
##$targetDir = "EBM--"."$poscar1Dir"."--"."$poscar2Dir";
##if (-e "$targetDir") {
##  die "$targetDir already exist.\n";
##} else {
##  $command = "mkdir $targetDir";
##  system("$command");
##  print "$command\n";
##}
##
#
#
#
#    end
#
#
#
#    #INCAR, KPOINTS, POTCAR があれば $targetDir にコピー
#
#    #INCAR をいじる
#    #IMAGES = num_images
#    #SPRING = 0
#
#    #{00..xx} に POSCAR を作る ####################################
#    #  # 原子座標の処理
#    #  {
#    #$_ =~ /\s*(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s*(.*)$/;
#    #($coord1[1], $coord1[2], $coord1[3], $other1) = ($1, $2, $3, $4);
#    ##$poscar2[$m] =~ /\s*(\d\.\d+)\s+(\d\.\d+)\s+(\d\.\d+)\s*(.*)$/;
#    #$poscar2[$m] =~ /\s*(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s+(-{0,1}\d\.\d+)\s*(.*)$/;
#    #($coord2[1], $coord2[2], $coord2[3], $other2) = ($1, $2, $3, $4);
#    ##
#    ##
#    ## 座標を決定する
#    #for ($k = 1; $k <= 3; $k ++) {
#    #    # 同じ座標がセルを地球周りしてないか、していたら大きい方を小さく
#    #    if ($coord1[$k] - $coord2[$k] > 0.5) {
#    #  $coord1[$k] -= 1;
#    #  print "atom of line $m moves a half of supercell.\n";
#    #    } elsif ($coord1[$k] - $coord2[$k] < -0.5) {
#    #  $coord2[$k] -= 1;
#    #  print "atom of line $m moves a half of supercell.\n";
#    #    }
#
#    #    $coord_out[$k] = 
#    #  (($images + 1 - $n) * $coord1[$k] + $n * $coord2[$k] )
#    #  / ($images + 1);
#    #}
