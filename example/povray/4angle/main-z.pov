#include "shapes.inc"

// Camera
background{color rgb <1,1,1>}
#default{ texture{ finish{
  ambient 0.4
  phong 0.6
  phong_size 10.0
} } }

camera{
  perspective // orthographic //or
  location < 3.0000, 3.0000,13.0000 >
  right    <-1.0000, 0.0000, 0.0000 >
  up       < 0.0000, 1.0000, 0.0000 >
  sky      < 0.0000, 0.0000, 1.0000 >
  look_at  < 3.0000, 3.0000, 3.0000 > // 最後に置くことが推奨されている。
}

light_source {< 0.0000,-1.0000, 1.0000 >
  color <1,1,1> * 1.5
  parallel
  point_at < 0.0000, 0.0000, 0.0000 >
}

#include "cell.inc"
