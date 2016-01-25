! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays assocs combinators combinators.smart kernel locals math
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

: connector-position* ( pair -- xy )
    [ connector-position ] map first2 swap v- ;

: initial-springs ( node -- seq )
    connector-pairs [ [ second parent>> ] [ connector-position* ] bi 2array ] map ;

:: add-spring ( node1 node2 -- )
    node1 [ node2 -1 1000 2array 2array suffix ] change-springs drop
    node2 [ node1 1 1000 2array 2array suffix ] change-springs drop ;

SINGLETONS: above below left right ;
: which-connectors ( node above/below -- seq )  above? [ inputs>> ] [ outputs>> ] if ;
: which-side ( seq left/right -- elt )  left? [ first ] [ last ] if ;

:: search-node ( node above/below left/right -- node' )
    node above/below which-connectors [ connected? ] filter 
    [ empty? ] [ drop node ] 
    [ left/right which-side links>> first parent>> above/below left/right search-node ] smart-if ;

:: find-left-right ( left-connector right-connector above/below -- )
    left-connector links>> first parent>> above/below right search-node
    right-connector links>> first parent>> above/below left search-node
    [ eq? not ] [ add-spring ] smart-when* ;

:: (add-extra-springs) ( node above/below -- node )
    node above/below which-connectors [ connected? ] filter [ length 1 > ] 
    [ [ but-last ] [ rest ] bi [ above/below find-left-right ] 2each ] smart-when* node ;

: add-extra-springs ( node -- node )
    above (add-extra-springs) 
    below (add-extra-springs) ;

: centre ( definition -- xy )
    dim>> [ 2 / >integer ] map ;

CONSTANT: k 0.05
CONSTANT: sat 0.5

:: spring-force ( dx dx0 -- f )
    dx0 dx - k *
    dx0 0 >= [ sat neg max ] when
    dx0 0 <= [ sat min ] when ;

:: force ( node1 node2 pos -- force )
    node1 x>> node2 x>> - pos first 100 * spring-force
    node1 y>> node2 y>> - pos second 40 * spring-force
    pos second 1000 = [ drop 0 ] when
    2array ;

: net-force ( node -- force )
    dup springs>> [ dupd first2 force ] map v-sum nip ;

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
     [ dup initial-springs >>springs ] map
     [ add-extra-springs ] map
     [ dup stop? ] [ move-nodes ] until ;

: place-unconnected-nodes ( def -- def )
    dup unconnected-nodes>>
    dup length iota zip [ first2 50 * 10 swap 2array >>loc drop ] each ;
