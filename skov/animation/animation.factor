! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays assocs combinators kernel locals math
math.order math.vectors random sequences skov.code skov.gadgets
skov.gadgets.node-gadget skov.utilities ;
IN: skov.animation

: nodes>> ( def -- seq )  children>> [ node-gadget? ] filter ;
: connected-nodes>> ( def -- seq )  nodes>> [ connected? ] filter ;
: unconnected-nodes>> ( def -- seq )  nodes>> [ connected? ] reject ;

: connector-pairs ( node -- seq )
    connectors>> [ connected? ] filter [ dup links>> [ dupd 2array ] map nip ] map concat ;

: connector-position ( connector-gadget -- xy )
    dup modell>> input? [ -1 swap dup parent>> inputs>> ] [ 1 swap dup parent>> outputs>> ] if
    [ index 0.5 + ] keep length 2 / - swap 2array ;

: connector-position* ( seq -- xy )
    [ connector-position ] map first2 swap v- ;

: centre ( definition -- xy )
    dim>> [ 2 / >integer ] map ;

CONSTANT: k 0.05
CONSTANT: sat 0.5

:: spring-force ( dx dx0 -- f )
    dx0 0 >= [ dx0 dx - k * sat neg max ] [ dx0 dx - k * sat min ] if ;

:: force ( node1 node2 pos -- force )
    node1 x>> node2 x>> - pos first 100 * spring-force
    node1 y>> node2 y>> - pos second 50 * spring-force
    2array ;

: net-force ( node -- force )
    dup connector-pairs [ dupd [ second parent>> ] [ connector-position* ] bi force ] map v-sum nip ;

: update-acceleration ( node -- node )
    dup net-force >>acc ;

:: update-velocity ( node -- node )
    node [ node acc>> v+ 0.85 v*n ] change-vel ;

:: update-position ( node -- node )
    node [ node vel>> v+ ] change-loc ;

: move-nodes ( seq -- seq )
    [ update-acceleration update-velocity update-position ] map ;

: stop? ( seq -- ? )
    [ acc>> [ abs ] map supremum 0.01 <= ] all? ;

: place-nodes ( def -- def )
     connected-nodes>>
     [ { 0 1 } >>acc { 0 0 } >>vel ] map
     [ dup stop? ] [ move-nodes ] until ;

: place-unconnected-nodes ( def -- def )
    dup unconnected-nodes>>
    dup length iota zip [ first2 50 * 10 swap 2array >>loc drop ] each ;
