#! /usr/bin/env zsh

poscar povray POSCAR > cell.inc
povray main-x.pov
povray main-y.pov
povray main-z.pov
povray main-w.pov

convert +append main-x.png main-y.png append2-xy.png
convert +append main-z.png main-w.png append2-zw.png
convert -append append2-zw.png append2-xy.png all.png
