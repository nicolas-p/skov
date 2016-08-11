! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences code code.execution ui.environment
ui.environment.connector-gadget ui.environment.node-gadget
ui.gadgets ;
FROM: code => inputs outputs ;
IN: ui.environment.graph-gadget

TUPLE: rel-loc  neighbour xy ;
C: <rel-loc> rel-loc

SINGLETON: above
SINGLETON: below

: neighbours ( node dir -- seq )
    above? [ inputs ] [ outputs ] if connected [ links>> [ parent>> ] map ] map concat ;

:: total-widths ( node dir -- seq )
    node dir neighbours [ [ width ] [ dir total-widths sum ] bi max 20 + ] map ;

: unplaced? ( node -- ? )
    loc>> { 0 0 } = ;

: vertical-space ( dir -- y )
    above? [ -75 ] [ 75 ] if ;

: neighbour-relative-positions ( node dir -- seq )
    total-widths [ f ] [ 
        [ cum-sum ] [ 2 v/n v- ] bi dup mean v-n
    ] if-empty ;

:: add-to-rel-locs ( rel-loc seq -- seq )
    seq [ neighbour>> rel-loc neighbour>> eq? ] filter
    [ seq rel-loc suffix ]
    [ first [ rel-loc xy>> v+ 2 v/n ] change-xy drop seq ] if-empty ;

: (set-relative-positions) ( node dir -- node )
    dupd [ neighbours ] [ neighbour-relative-positions ] [ nip vertical-space ] 2tri
    '[ _ 2array <rel-loc> swap [ add-to-rel-locs ] change-rel-locs ] 2each ;

: set-relative-positions ( node -- node )
    above (set-relative-positions)
    below (set-relative-positions) ;

: vmaxabs ( v v -- v )
    [ 2dup [ abs ] bi@ > [ drop ] [ nip ] if ] 2map ;

DEFER: set-absolute-positions

:: set-absolute-position ( node rel-loc -- )
    rel-loc neighbour>> rel-locs>> [ neighbour>> node eq? ] filter first :> other-rel-loc
    rel-loc xy>> other-rel-loc xy>> vneg vmaxabs node mid-loc v+ :> new-loc
    rel-loc neighbour>> unplaced? new-loc second neg? node y new-loc second > and or
    [ new-loc rel-loc neighbour>> set-loc set-absolute-positions ] when ;

: set-absolute-positions ( node -- )
    dup rel-locs>> [ set-absolute-position ] with each ;

: place-nodes ( graph -- graph )
     dup nodes [ set-relative-positions ] map [ first { 1 1 } >>loc set-absolute-positions ] unless-empty ;

: add-nodes ( graph -- graph )
    dup control-value contents>> connected [ <node-gadget> add-gadget ] each ;

: <graph-gadget> ( model -- graph-gadget )
    graph-gadget new swap >>model ;

: top-left-corner ( graph -- xy )
    nodes [ 0 0 ] [ [ loc>> ] map unzip [ infimum ] bi@ ] if-empty 2array ;

: bottom-right-corner ( graph -- xy )
    nodes [ 0 0 ] [ [ [ loc>> ] [ pref-dim ] bi v+ ] map unzip [ supremum ] bi@ ] if-empty 2array ;

: fix-locations ( graph -- graph )
    dup [ top-left-corner ] keep nodes [ swap '[ _ v- ] change-loc drop ] with each ;

M: graph-gadget model-changed
    dup clear-gadget swap value>> [ definition? ]
    [ ?define add-nodes add-connections place-nodes fix-locations ] smart-when* drop ;

M: graph-gadget pref-dim*
    bottom-right-corner ;

M: graph-gadget layout*
    [ dup pref-dim swap dim<< ] each-child ;
