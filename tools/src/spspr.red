Red [
  Author: {Pep Diz}
  Description: {Basic sprite editor mainly for zx spectrum}
  ToDo: {
     - handle colors and palettes
     - export to different image formats
  }     
  Needs: 'View
]

dimensions: [ "8x8" "8x16" "16x8" "16x16" "16x32" "32x16" "32x32" ]
sprite: none 

draw-grid:  function [] [
  w: first canvas/size h: second canvas/size
  d: to pair! pick dim/data dim/selected
  mc: second d c: 0
  loop mc [
    append canvas/draw compose [line (as-pair 0 c) (as-pair w c)]
    c: c + to integer! (w / mc)
  ]
  mc: first d c: 0
  loop mc [
    append canvas/draw compose [line (as-pair c 0) (as-pair c h)]
    c: c + to integer! (h / mc)
  ]
]

draw-image: function [] [
  canvas/draw: copy []
  p: canvas/size / sprite/size      
  wb: first p hb: second p
  repeat x first sprite/size [
    repeat y second sprite/size [
       i: as-pair x y
       cx: (x - 1) * wb cy: (y - 1) * hb
       append canvas/draw compose [fill-pen (sprite/(i)) box (as-pair cx cy) (as-pair (cx + wb) (cy + hb))]
    ]
  ]
]

toggle-box: function [f e] [
  unless none? sprite [ 
   if e/type = 'down [
      p: canvas/size / (to pair! pick dim/data dim/selected)       
      wb: first p hb: second p
      x: first e/offset y: second e/offset 
      fila: y / hb + 1 
      col: x / wb + 1
      i: as-pair col fila 
      either sprite/(i) = 0.0.0 [sprite/(i): 255.255.255] [sprite/(i): 0.0.0]
      draw-image       
   ]
  ]
]

novo: func [] [
  unless none? dim/selected [
    sprite: make image! reduce [(to pair! pick dim/data dim/selected) 255.255.255]
    canvas/draw: copy []  
    draw-grid
  ]
]

fl: func [f s a] [either tail? s [a] [r: fl :f next s (f a (first s))]]
sum: func [a b] [a + b]

to-zx: function ["garda sprites en caraceres por filas"] [
{ ejemplo
  8x8 (char):  f1c1 f1c2 f1c3 ... f1c8 f2c1 ... f8c8
  16x16: char1 char2 char3 char4 = f1c1 ... f1c8 f2c1 ... f8c8 f1c9 ... f1c16 f8c16 ... f32c32
}
  w: make vector! [128 64 32 16 8 4 2 1]
  v: make vector! 8
  ldata: copy []
  cf: 0 cc: 0
  while [cf < second sprite/size] [
    repeat y 8 [ 
      repeat x 8 [
         j: as-pair (cc + x) (cf + y) 
         v/(x): either sprite/(j) = 0.0.0 [0] [1]
      ]
      append ldata fl :sum (v * w) 0         
    ] 
    cc: cc + 8
    if cc >= first sprite/size [cc: 0 cf: cf + 8]
  ]
  r: "DATA "
  foreach v ldata [ 
    append r reduce [v ","]
  ]   
  remove at r length? r
  r
]

save-zx: function [] [
  fn: request-file/save/file %sprite.bas
  unless suffix? fn [append fn %.bas]  
  fn: request-file/save/file "sprite.bas"
  unless suffix? fn [append fn %.png]
  write fn to-zx
]

save-png: function [] [
  fn: request-file/save/file "sprite.png"
  unless suffix? fn [append fn %.png]
  save/as fn sprite 'png
]

ver: function [] [
  view/flags [image sprite return button "OK" [unview] button "Gardar png" [save-png] ] 
    [modal popup no-title no-buttons]  
]

ver-zx: function [] [
  view/flags [
    tbas: area "" return button "OK" [unview] button "Gardar" [save-zx]
    do [tbas/text: to-zx] 
  ] [modal popup no-title no-buttons]  
]

view [title "editor de sprites"
    text "Columnas x Filas" dim: drop-list data dimensions [novo] 
    button "imaxe" [ver] button "zx" [ver-zx] return    
    canvas: base 640x640 white on-down [toggle-box face event]
]