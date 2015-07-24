#! /usr/bin/env zsh

poscar2pov -e 'Li,Ge,O' POSCAR > cell.inc
cp ../lib/povrayutils/CameraRotating/* ./
cp ../lib/povrayutils/RotateVector.inc ./
./main.zsh
echo "See main.gif"
