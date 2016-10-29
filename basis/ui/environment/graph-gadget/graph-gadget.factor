! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs code code.execution combinators
combinators.smart fry kernel locals math math.functions
math.order math.statistics math.vectors models sequences
sequences.deep sets sorting ui.environment
ui.environment.connector-gadget ui.environment.node-gadget
ui.gadgets ;
FROM: code => inputs outputs ;
IN: ui.environment.graph-gadget

: register-above ( node node' -- node )  [ suffix ] curry change-above ;
: register-below ( node node' -- node )  [ suffix ] curry change-below ;
: register-left ( node node' -- node )  [ suffix ] curry change-left ;
: register-right ( node node' -- node )  [ suffix ] curry change-right ;

: find-vertical-relations ( node -- seq )
    dup inputs connected [ links>> [ parent>> register-above ] each ] each
    dup outputs connected [ links>> [ parent>> register-below ] each ] each ;

:: all-nodes-above/below ( connector -- seq )
    connector links>> [
        parent>> dup connector control-value input? [ inputs ] [ outputs ] if
        connected [ all-nodes-above/below ] map 2array
    ] map flatten ;

:: each-pair ( seq quot -- seq )
    seq [ but-last ] [ rest ] bi quot 2each ; inline

: when-more-than-one ( seq quot -- )
    [ length 1 > ] swap smart-when* ; inline

: reject-common ( set1 set2 -- set1' set2' )
    [ diff ] [ swap diff ] 2bi ;

: assign-left-right ( left-node right-node -- )
    [ register-right drop ] [ swap register-left drop ] 2bi ;

: process-connector-row ( seq -- )
    [ all-nodes-above/below ] map
    [ [ reject-common [ assign-left-right ] cartesian-each ] each-pair ] when-more-than-one ;

:: find-horizontal-relations ( node -- node )
    node inputs connected process-connector-row
    node outputs connected process-connector-row
    node ;

: find-relations ( graph -- graph )
    dup nodes [ find-vertical-relations find-horizontal-relations ] map 
    [ [ members ] change-left [ members ] change-right
      dup [ left>> ] [ right>> ] bi reject-common [ >>left ] [ >>right ] bi* ] map drop ;

: horizontal-distance ( right-node left-node -- distance )
    [ left-edge ] [ right-edge ] bi* - 20 - ;

: horizontal-center-distance ( node node -- distance )
    [ center ] bi@ - ;

: vertical-distance ( below-node above-node -- distance )
    [ top-edge ] bi@ - 75 - ;

: same-row? ( node node -- ? )
    [ top-edge ] bi@ - abs 30 < ;

: left-movements ( node -- seq )  dup left>> [ horizontal-distance neg ] with map ;
: right-movements ( node -- seq )  dup right>> [ swap horizontal-distance ] with map ;
: above-movements ( node -- seq )  dup above>> [ vertical-distance neg ] with map ;
: below-movements ( node -- seq )  dup below>> [ swap vertical-distance ] with map ;

: centering-movements ( node -- seq )
    dup [ above>> ] [ below>> ] bi append [ horizontal-center-distance neg ] with map ;

: raw-horizontal-movements ( node -- seq )
    [ left-movements ] [ right-movements ] [ centering-movements ] tri append append ;

: raw-vertical-movements ( node -- seq )
    [ above-movements ] [ below-movements ] bi append ;

: supremum* ( seq -- x )  [ -1000 ] [ supremum ] if-empty ;

DEFER: vertical-movement

:: ask-below-neighbor ( node distance movements -- movement' )
    movements mean distance - 0 > [ node movements distance v-n vertical-movement distance v+n ] [ f ] if ;

:: vertical-movement ( node seq -- seq )
    node raw-vertical-movements  :> these-movements
    these-movements seq append :> movements
    node below>> [ dup node vertical-distance movements ask-below-neighbor ] map concat :> from-below
    from-below movements append :> all-movements
    all-movements mean node above-movements supremum* max
    0 swap 2array node swap [ v+ ] curry change-loc drop
    these-movements from-below append ;

DEFER: horizontal-movement

:: ask-right-neighbor ( node distance movements -- movement' )
    movements mean distance - 0 > [ node movements distance v-n horizontal-movement distance v+n ] [ f ] if ;

: closest ( seq -- seq )
    [ loc>> first ] sort-with [ f ] [ first 1array ] if-empty ;

:: horizontal-movement ( node seq -- seq )
    node raw-horizontal-movements :> these-movements
    these-movements seq append :> movements
    node right>> closest [ dup node horizontal-distance movements ask-right-neighbor ] map concat :> from-right
    from-right movements append :> all-movements
    all-movements mean  node left-movements supremum* max
    0 2array node swap [ v+ ] curry change-loc drop
    these-movements from-right append ;

:: move-node ( node -- )
    node f horizontal-movement drop
    node f vertical-movement drop ;

: move-nodes ( graph -- graph )
    dup nodes [ move-node ] each [ 1 + ] change-counter ;

: no-movement? ( graph -- graph )
    [ nodes [ immobile?>> ] all? ] [ counter>> 20 > ] bi or ;

: place-nodes ( graph -- graph )
    0 >>counter find-relations [ dup no-movement? ] [ move-nodes ] until ;

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
