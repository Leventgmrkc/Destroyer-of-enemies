patches-own [elevation obstacle? hangar? base? target? military-base? Cost-path enemies-area?  visited? active? Final-Cost p-valids]
breed [envconstructors envconstructor]

breed [TB2s TB2]
breed [Akıncıs Akıncı]
breed [Aksungurs Aksungur]

breed [PantsirS1s PantsirS1]
breed [Hisar-As Hisar-A]
breed [Tor-M2KMs Tor-M2KM]
breed[searchers searcher]

breed [cars car]
cars-own[ leader follower]

TB2s-own[ fuel location map-analysis]
Akıncıs-own[ fuel location map-analysis]
Aksungurs-own[ fuel location map-analysis]

PantsirS1s-own [ number-of-missile radar shooting-range ]
Hisar-As-own [ number-of-missile radar shooting-range ]
Tor-M2KMs-own [ number-of-missile radar shooting-range ]


searchers-own [
  memory               ; Stores the path from the start node to here
  cost                 ; Stores the real cost from the start node
   ; Stores the total expected cost from Start to the Goal that is being
                       ;   computed
  localization         ; The node where the searcher is

]



globals[
  military-base-xcor
  military-base-ycor
  base-xcor
  base-ycor
]

to setup

  clear-all

  create-PantsirS1
  create-Hisar-A
  create-Tor-M2KM
  setup-patches
  create-akıncı
  create-TB2
  create-Aksungur
  create-car
  set p-valids patches with [pcolor != brown]
  crt 1
  [
    ht
    set sıze 1
    set pen-sıze 2
    set pcolor red
    set shape "square"
  ]

  reset-ticks


end

to go
  ;if ticks >= 1000 [ stop ]  ;; stop after 500 ticks

  move-akıncı
  move-TB2
  move-aksungur
  move-car

  tick
end

;creating air-defence systems
to create-PantsirS1

  create-PantsirS1s Number-of-PantsirS1

  ask pantsirS1s [
    let x -28 + random 60
    let y -28 + random 60
    setxy x y
    set color red + 1
    set sıze 3
    set pcolor blue - 4
    set shape "arrow"
  ]
end

to create-Hisar-A

  create-Hisar-As Number-of-Hisar-A

  ask hisar-As [
    let x -28 + random 60
    let y -28 + random 60
    setxy x y
    set color red - 1
    set sıze 3
    set pcolor blue - 4
    set shape "arrow"
  ]
end

to create-Tor-M2KM

  create-Tor-M2KMs Number-of-Tor-M2KM

  ask tor-M2KMs [
    let x -30 + random 60
    let y -30 + random 60
    setxy x y
    set color red - 3
    set sıze 3
    set pcolor blue - 4
    set shape "arrow"
  ]
end



to setup-patches
  ask patches[
    set visited? false
    set active? false
    set Cost-path 0
    set obstacle? false
    set hangar? false ; where uavs will land
    set base? false   ; where uavs take off
    set target? false ;target of our convoi
    set military-base? false ; hangar,base, and target
    set enemies-area? false ; enemies
    set elevation (random 10000)
  ]

  ask patches with [pcolor = blue - 4] [             ; diğer hava savunma sistemleri ile çok yakın olmasın diye bir alan belirtmek için
     ask patches in-radius ( 4 + random-float 2.5)[
        set enemies-area? true
     ]
  ]

  diffuse elevation 1
  ask patches[
    set pcolor scale-color green elevation 1000 9000
  ]



  ;create military-base point
  ask patches with[ pxcor >= min-pxcor  and pxcor <= min-pxcor + 1 and pycor >= min-pycor and pycor <= min-pycor + 3][set pcolor 2]
  ask patches with[ pxcor >= min-pxcor + 2  and pxcor <= min-pxcor + 3 and pycor >= min-pycor and pycor <= min-pycor + 8][set pcolor gray set base? true]
  ask patches with[ pxcor >= min-pxcor + 4  and pxcor <= min-pxcor + 5 and pycor >= min-pycor and pycor <= min-pycor + 8][
    set pcolor 7
    set base? true
    set base-xcor pxcor
    set base-ycor pycor
  ]
  ask patches with[ pxcor >= min-pxcor + 4 and pxcor <= min-pxcor + 13 and pycor >= min-pycor and pycor <= min-pycor][set pcolor black set hangar? true]
  ask patches with[ pxcor >= min-pxcor and pxcor <= -20 and pycor >= min-pycor and pycor <= -15] [ set military-base? true]

  ;create target point
  ask n-of 1 patches with [obstacle? = false and enemies-area? = false and pxcor < 30  and pxcor >= 15  and pycor < 30 and pycor >= 15 ] [
    ask patches in-radius 1
    [
       set military-base-xcor pxcor
       set military-base-ycor pycor
       set pcolor yellow
       ask patches in-radius(6) [ set military-base? true]
    ]
  ]


  ; create river
  if n-rivers > 0[
      ; ucundan büyümeyi sağlayacak olan constructor
      create-envconstructors n-rivers  [
        ; We place it river randomly on the map
        ifelse random-float 1 <= 0.5 [
          set xcor 0
          set ycor random max-pycor
          set headıng 180
        ]
        [
          set ycor 0
          set xcor random max-pxcor
          set headıng 0
        ]

        ; growing river
        repeat (2 * max-pxcor ) + (2 * max-pycor) [
          ; change directory
          rt random 30 - 15
          ; forward
          fd 1
          ; create a bridge
          ask patch-here [
           if military-base? = false and enemies-area? = false[
            ; Pont
            ifelse random-float 1.5 <= 0.1 [
              set obstacle? false

              set pcolor orange
            ]
            [
              set pcolor blue
              set obstacle? true
            ]
          ]
        ]
        ]
        die
      ]

  ]

  ; create lakes
  ask n-of lakes patches [
     ifelse random-float 2 <= 0.5 [
       ask n-of 1 patches with [ pcolor = blue and military-base? = false and enemies-area? = false] [
         set pcolor magenta
       ]
     ]
     [
      ask n-of 1 patches with [ obstacle? = false and military-base? = false and enemies-area? = false ] [
        set pcolor magenta
      ]
     ]
  ]

  ask patches with [pcolor = magenta] [
    ask patches in-radius ( 4 + random-float 2.5)
    [
      set obstacle? true
      set pcolor scale-color blue elevation 1000 9000
    ]
  ]

  ; create mountains
  ask n-of hill patches with [obstacle? = false and military-base? = false and enemies-area? = false]
  [
        set pcolor brown
  ]

  ask patches with [pcolor = brown] [
    ask patches in-radius ( 4 + random-float 2.5)
    [
      set obstacle? true
      set pcolor scale-color brown elevation 2000 13000
    ]
  ]

end

; Creating UAVs
to create-akıncı
  create-akıncıs Number-of-Akıncı
  ask akıncıs [
    set headıng 0
    set color magenta
    set sıze 3
    move-to one-of patches with [base? = true]
    set fuel 100
    set shape "airplane"
  ]
end
to move-akıncı
  ask akıncıs[
    right random 50
    left random 30
    forward 1
  ]
end

to create-TB2
  create-TB2s Number-of-TB2
  ask TB2s [
    set headıng 0
    set color orange
    set sıze 3
    move-to one-of patches with [base? = true]
    set fuel 100
    set shape "airplane"
  ]
end
to move-TB2
  ask TB2s[
    right random 50
    left random 30
    forward 1
  ]
end


to create-aksungur
  create-aksungurs Number-of-Aksungur
  ask aksungurs [
    set headıng 0
    set color black
    set sıze 3
    move-to one-of patches with [base? = true]
    set fuel 100
    set shape "airplane"
  ]
end
to move-aksungur
  ask aksungurs[
    right random 50
    left random 30
    forward 1
  ]
end

; creating convoy
to create-car
  create-cars number-of-car
  ask cars[
    set headıng 0
    move-to one-of patches with [base? = true]
    set shape "truck"
    set sıze 3
    set color pink
    set follower true
  ]
  ask one-of cars[
    set shape "car"
    set headıng 0
    set color red
    set leader true
  ]

end

to wiggle [angle]
  right random-float angle
  left random-float angle
end
to move-car
  ask cars with[leader = true]                                      ;; the leader ant wiggles and moves
     [ wiggle 45
       correct-path
       if (xcor > (military-base-xcor - 5 ))                    ;; leader heads straight for food, if it is close
         [ facexy military-base-xcor military-base-ycor ]
       if xcor < military-base-xcor                            ;; do nothing if you're at or past the food
         [ fd 0.5 ] ]
  ask cars with[follower = true]
     [ face one-of cars with[leader = true]                        ;; follower ants follow the ant ahead of them
       if time-to-start? and (xcor < military-base-xcor)        ;; followers wait a bit before leaving nest
         [ fd 0.5 ] ]
end

to-report time-to-start?
  report ([xcor] of (turtle (who - 1))) > (base-xcor + 1 + random 1 )
end
to correct-path
  ifelse headıng > 90
    [ rt 90 ]
    [ if patch-at 1 -1 = base?
        [set headıng 180 ]
     if patch-at 1 -1 = base?
        [set headıng 180] ]
end



to-report Total-expected-cost [#Goal]
  report Cost-path + Heuristic #Goal
end







;ASTAR ALGORITH

to-report A* [#Start #Goal #valid-map]
  ; clear all the information in the agents, and reset them
  ask #valid-map with [visited?]
  [
    set leader nobody
    set Cost-path 0
    set visited? false
    set active? false
  ]
  ; Active the starting point to begin the searching loop
  ask #Start
  [
    set leader self
    set visited? true
    set active? true
  ]
  ; exists? indicates if in some instant of the search there are no options to continue.
  ; In this case, there is no path connecting #Start and #Goal
  let exists? true
  ; The searching loop is executed while we don't reach the #Goal and we think a path exists
  while [not [visited?] of #Goal and exists?]
  [
    ; We only work on the valid pacthes that are active
    let options #valid-map with [active?]
    ; If any
    ifelse any? options
    [
      ; Take one of the active patches with minimal expected cost
      ask min-one-of options [Total-expected-cost #Goal]
      [
        ; Store its real cost (to reach it) to compute the real cost of its children
        let Cost-path-father Cost-path
        ; and deactivate it, because its children will be computed right now
        set active? false
        ; Compute its valid neighbors and look for an extension of the path
        let valid-neighbors neighbors with [member? self #valid-map]
        ask valid-neighbors
        [
          ; There are 2 types of valid neighbors:
          ;   - Those that have never been visited (therefore, the path we are building is the
          ;       best for them right now)
          ;   - Those that have been visited previously (therefore we must check if the path we
          ;       are building is better or not, by comparing its expected length with the one
          ;       stored in the patch)
          ; One trick to work with both type uniformly is to give for the first case an upper
          ;   bound big enough to be sure that the new path will always be smaller.
          let t ifelse-value visited? [ Total-expected-cost #Goal] [2 ^ 20]
          ; If this temporal cost is worse than the new one, we substitute the information in
          ;   the patch to store the new one (with the neighbors of the first case, it will be
          ;   always the case)
          if t > (Cost-path-father + distance myself + Heuristic #Goal)
          [
            ; The current patch becomes the father of its neighbor in the new path
            set leader myself
            set visited? true
            set active? true
            ; and store the real cost in the neighbor from the real cost of its father
            set Cost-path Cost-path-father + distance leader
            set Final-Cost precision Cost-path 3
    ] ] ] ]
    ; If there are no more options, there is no path between #Start and #Goal
    [
      set exists? false
    ] ]
  ; After the searching loop, if there exists a path
  ifelse exists?
  [
    ; We extract the list of patches in the path, form #Start to #Goal by jumping back from
    ;   #Goal to #Start by using the fathers of every patch
    let current #Goal
    set Final-Cost (precision [Cost-path] of #Goal 3)
    let rep (list current)
    While [current != #Start]
    [
      set current [leader] of current
      set rep fput current rep
    ]
    report rep
  ]
  [
    ; Otherwise, there is no path, and we return False
    report false
  ]
end



; implement

to Look-for-Goal
  ; Take one random Goal
  let Goal one-of Patches with [target?]
  ; Compute the path between Start and Goal
  let path  A* base? Goal Patches
  ; If any...
  if path != false [
    ; Take a random color to the drawer turtle
    ask turtle 0 [set color (lput 150 (n-values 3 [100 + random 155]))]
    ; Move the turtle on the path stamping its shape in every patch
    foreach path [
      p ->
      ask turtle 0 [
        move-to p
        stamp]]
    ; Set the Goal and the new Start point
    set base? Goal
  ]
end





to-report Heuristic [#Goal]
  report distance #Goal
end
@#$#@#$#@
GRAPHICS-WINDOW
645
10
1066
432
-1
-1
5.1
1
2
1
1
1
0
0
0
1
-40
40
-40
40
0
0
1
ticks
30.0

BUTTON
208
392
347
462
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
42
111
75
hill
hill
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
18
83
110
116
n-rivers
n-rivers
1
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
113
42
205
75
lakes
lakes
1
5
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
51
10
201
37
Environment
22
0.0
1

TEXTBOX
170
137
320
164
UAV
22
0.0
1

INPUTBOX
13
169
138
229
Number-of-TB2
1.0
1
0
Number

CHOOSER
142
176
248
221
TB2-missile-type
TB2-missile-type
"MAM-L"
0

INPUTBOX
13
237
138
297
Number-of-Akıncı
0.0
1
0
Number

CHOOSER
147
243
251
288
Akıncı-missile-type
Akıncı-missile-type
"SOM-A" "MAM-L"
0

INPUTBOX
13
311
139
371
Number-of-Aksungur
0.0
1
0
Number

CHOOSER
147
318
253
363
Aksungur-missile-type
Aksungur-missile-type
"SOM-A" "MAM-L"
0

TEXTBOX
396
11
589
65
Air Defense System
22
0.0
1

INPUTBOX
428
42
547
102
Number-of-PantsirS1
0.0
1
0
Number

INPUTBOX
428
116
547
176
Number-of-Hisar-A
0.0
1
0
Number

INPUTBOX
429
188
548
248
Number-of-Tor-M2KM
0.0
1
0
Number

SWITCH
115
83
206
116
Citiziens
Citiziens
1
1
-1000

SLIDER
253
181
372
214
no-missile-TB2
no-missile-TB2
0
4
4.0
1
1
NIL
HORIZONTAL

SLIDER
255
249
375
282
no-missile-Akıncı
no-missile-Akıncı
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
257
324
373
357
no-missile-Aksungur
no-missile-Aksungur
0
24
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
423
281
573
308
Enemy Soldier
22
0.0
1

INPUTBOX
432
315
551
375
no-enemy-soldiers
0.0
1
0
Number

BUTTON
398
394
560
463
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
247
43
357
76
number-of-car
number-of-car
1
10
4.0
1
1
NIL
HORIZONTAL

TEXTBOX
263
10
413
37
Convoy
22
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
