Red [
  author: Pep Diz
  description: un programa para facer debuxos draw no speccy
  Needs: 'View
]
 msgbox: function [msg [string!]] [
    view/flags [
        title "Mensaxe"
        msg-text: text msg center return
        btn: button "OK" [unview]
        do [btn/offset/x: msg-text/offset/x + (msg-text/size/x / 2) - (btn/size/x / 2)]
    ] [modal popup]
]

 f: func [l i /local m c j] [m: copy tail l repeat c i [j: c - 1 * 3 + 1 append m l/:j append m l/(j + 1) append m l/(j + 2)]]
 
 add-cmd: func [l c] [
   either empty? l [append l c] [append l reduce [": " c]]
 ]
 tp: func [p] [as-pair first p (175 - second p)]
 dp: func [p1 p2] [as-pair (first p2 - first p1) (second p2 - second p1)]
 toCoord: func [p] [to string! reduce [first p "," second p]]

 zx-transform: function [line-cmds] [
  lineas: copy ""
  if not (empty? line-cmds) [
   pv1: none
   pv2: none
   foreach [cmd p1 p2] line-cmds [ 
     if not p1 = pv2 [add-cmd lineas rejoin ['PLOT " " toCoord tp p1]] 
     add-cmd lineas rejoin ['DRAW " " toCoord dp tp p1 tp p2] 
     pv1: p1 pv2: p2      
   ]
  ]
  lineas  
 ]
    
 r-click: func [e] [
      p: e/offset
      l/data: p
      if s/data < 100% [m: f lista to integer! (length? lista) * s/data / 3 lista: copy m]
      s/data: 100%
 ]
 
 l-click: func [e /local a m] [
  if canvas/draw = none [canvas/draw: copy []] 
  if s/data < 100% [m: f lista to integer! (length? lista) * s/data / 3 p: third at m (length? m) - 2 lista: copy m]
  append lista compose [line (p) (e/offset)]
  p: e/offset
  canvas/draw: lista
  l/data: p
  s/data: 100%
 ]

 cleanup: func [] [lineas: copy "" lista: copy [] canvas/draw: copy [] p: 0x175 l/data: p] 

 ver-zx: function [] [msgbox zx-transform canvas/draw]
 save-zx: function [] [if (sf: request-file/save/file/title %zx-draw.bas "Gardar como...") [write sf zx-transform canvas/draw]]

 p: 0x175
 lista: copy []
 
 view [title "Speccy garabatos" 
   button "gardar" [save-zx] button "ver" [ver-zx] button "limpar" [cleanup] l: text return
   s: slider 255x20 100% 
     on-change [
       canvas/draw: f lista to integer! (length? lista) * face/data / 3
       p: third at canvas/draw (length? canvas/draw) - 2 
       l/data: p
     ] 
   return
   canvas: base 255x175 on-down [l-click event] on-alt-down [r-click event]
   
 ]
 
