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
    [ [ members ] change-left [ members ] change-right ] map drop ;

: horizontal-distance ( right-node left-node -- distance )
    [ left-edge ] [ right-edge ] bi* - 20 - ;

: horizontal-center-distance ( node node -- distance )
    [ center ] bi@ - ;

: vertical-distance ( below-node above-node -- distance )
    [ top-edge ] bi@ - 75 - ;

: infimum* ( seq -- x )  [ 1000 ] [ infimum ] if-empty ;
: supremum* ( seq -- x )  [ -1000 ] [ supremum ] if-empty ;

: left-movements ( node -- seq )  dup left>> [ horizontal-distance neg ] with map ;
: right-movements ( node -- seq )  dup right>> [ swap horizontal-distance ] with map ;
: above-movements ( node -- seq )  dup above>> [ vertical-distance neg ] with map ;
: below-movements ( node -- seq )  dup below>> [ swap vertical-distance ] with map ;

: centering-movements ( node -- seq )
    dup [ above>> ] [ below>> ] bi append [ horizontal-center-distance neg ] with map ;

: raw-horizontal-movements ( node -- seq )
    [ left-movements ] [ right-movements ] bi 2array ;

: raw-vertical-movements ( node -- seq )
    [ above-movements ] [ below-movements ] bi 2array ;

: limits ( seq -- xmin xmax )
    [ first supremum* ] [ second infimum* ] bi ;

: horizontal-movement ( node -- x )
    raw-horizontal-movements [ limits ] [ concat mean ] bi min max ;

: vertical-movement ( node -- x )
    raw-vertical-movements [ limits ] [ concat mean ] bi min max ;

DEFER: centering-movement

:: ask-right-neighbor ( node distance movements -- movement' )
    movements mean distance - 0 > [ node movements distance v-n centering-movement distance v+n ] [ f ] if ;

:: ask-left-neighbor ( node distance movements -- movement' )
    movements mean distance + 0 < [ node movements distance v+n centering-movement distance v-n ] [ f ] if ;

:: centering-movement ( node seq -- seq )
    node centering-movements dup seq append dup :> movements mean dup :> movement sgn :> new-direction
    seq [ seq mean sgn ] [ new-direction ] if :> original-direction {
        { [ original-direction 1 = new-direction 1 = and ]
          [ node right>> [ dup node horizontal-distance movements ask-right-neighbor ] map concat ] }
        { [ original-direction -1 = new-direction -1 = and ]
          [ node left>> [ dup node swap horizontal-distance movements ask-left-neighbor ] map concat ] }
        [ f ]
    } cond append ;

:: move-node ( node -- )
    node loc>>
    node node horizontal-movement node vertical-movement 2array [ v+ ] curry change-loc
    node f centering-movement mean 0 2array [ v+ ] curry change-loc 
    loc>> v- [ abs 1 <= ] all? node immobile?<< ;

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
