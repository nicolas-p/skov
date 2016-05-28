! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences skov.code skov.execution skov.gadgets
skov.gadgets.connector-gadget skov.gadgets.node-gadget
ui.gadgets ;
IN: skov.gadgets.graph-gadget

SINGLETON: above
SINGLETON: below

: connectors ( node dir -- seq )
    above? [ connected-inputs>> ] [ connected-outputs>> ] if ;

: neighbours ( node dir -- seq )
    connectors [ links>> first parent>> ] map ;

:: total-widths ( node dir -- seq )
    node dir neighbours [ [ width ] [ dir total-widths sum ] bi max 20 + ] map ;

: unplaced? ( node -- ? )
    loc>> { 0 0 } = ;

: vertical-space ( dir -- y )
    above? [ -80 ] [ 80 ] if ;

: neighbour-relative-positions ( node dir -- seq )
    total-widths [ f ] [ 
        [ cum-sum ] [ 2 v/n v- ] bi dup mean v-n
    ] if-empty ;

: (set-relative-positions) ( node dir -- )
    [ connectors ] [ neighbour-relative-positions ] [ nip vertical-space ] 2tri
    '[ _ 2array >>locs drop ] 2each ;

: set-relative-positions ( node -- node )
    [ above (set-relative-positions) ]
    [ below (set-relative-positions) ] [ ] tri ;

: vmaxabs ( v v -- v )
    [ 2dup [ abs ] bi@ > [ drop ] [ nip ] if ] 2map ;

DEFER: set-absolute-positions

:: set-absolute-position ( connector -- )
    connector parent>> :> from-node
    connector links>> first parent>> :> node
    connector locs>> connector links>> first locs>> vneg vmaxabs from-node mid-loc v+ :> new-loc
    node unplaced? connector control-value input? node y new-loc second > and or
    [ new-loc node set-loc set-absolute-positions ] when ;

: set-absolute-positions ( node -- )
    connected-connectors>> [ set-absolute-position ] each ;

: place-nodes ( graph -- graph )
     dup nodes>> [ set-relative-positions ] map [ first { 1 1 } >>loc set-absolute-positions ] unless-empty ;

: add-nodes ( graph -- graph )
    dup control-value connected-contents>> [ <node-gadget> add-gadget ] each ;

: <graph-gadget> ( model -- graph-gadget )
    graph-gadget new swap >>model ;

: top-left-corner ( graph -- xy )
    nodes>> [ 0 0 ] [ [ loc>> ] map unzip [ infimum ] bi@ ] if-empty 2array ;

: bottom-right-corner ( graph -- xy )
    nodes>> [ 0 0 ] [ [ [ loc>> ] [ pref-dim ] bi v+ ] map unzip [ supremum ] bi@ ] if-empty 2array ;

: fix-locations ( graph -- graph )
    dup [ top-left-corner ] keep nodes>> [ swap '[ _ v- ] change-loc drop ] with each ;

M: graph-gadget model-changed
    dup clear-gadget swap value>> [ definition? ]
    [ ?define add-nodes add-connections place-nodes fix-locations ] smart-when* drop ;

M: graph-gadget pref-dim*
    bottom-right-corner ;

M: graph-gadget layout*
    [ dup pref-dim swap dim<< ] each-child ;
