! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs code code.execution
combinators.smart fry kernel locals math math.order
math.statistics math.vectors models sequences sequences.deep
sets ui.environment ui.environment.connector-gadget
ui.environment.node-gadget ui.gadgets ;
FROM: code => inputs outputs ;
IN: ui.environment.graph-gadget

TUPLE: relation node1 node2 ;
TUPLE: vertical-relation < relation ;
TUPLE: horizontal-relation < relation ;
TUPLE: centering-relation < horizontal-relation ;
C: <vertical-relation> vertical-relation
C: <horizontal-relation> horizontal-relation
C: <centering-relation> centering-relation

:: vertical-relations ( node -- seq )
    node inputs connected [ links>> first parent>> node <vertical-relation> ] map ;

:: all-nodes-above/below ( connector -- seq )
    connector links>> [
        parent>> dup connector control-value input? [ inputs ] [ outputs ] if
        connected [ all-nodes-above/below ] map 2array
    ] map flatten ;

:: map-pair ( seq quot -- seq )
    seq [ but-last ] [ rest ] bi quot 2map ; inline

: if-more-than-one ( seq quot -- )
    [ length 1 > ] swap [ f ] smart-if* ; inline

: reject-common ( set1 set2 -- set1' set2' )
    [ diff ] [ swap diff ] 2bi ;

: process-connector-row ( seq -- seq )
    [ all-nodes-above/below ] map
    [ [ reject-common [ <horizontal-relation> ] cartesian-map ] map-pair concat ] if-more-than-one ;

:: horizontal-relations ( node -- seq )
    node inputs connected process-connector-row sift
    node outputs connected process-connector-row sift append flatten ; ! why flatten?

SINGLETON: above
SINGLETON: below

: neighbors ( node dir -- seq )
    above? [ inputs ] [ outputs ] if connected [ links>> [ parent>> ] map ] map concat ;

:: centering-relations ( node -- seq )
    node node above neighbors <centering-relation>
    node node below neighbors <centering-relation> 2array ;

: relations ( node -- seq )
    [ horizontal-relations ] [ vertical-relations ] [ centering-relations ] tri append append ;

: find-relations ( graph -- graph )
    dup nodes [ relations ] map concat >>relations ;

: horizontal-distance ( node node -- distance )
    [ left-edge ] [ right-edge ] bi* - 20 - ;

: horizontal-center-distance ( nodes node -- distance )
    [ [ center ] map mean ] [ center ] bi* - ;

: vertical-distance ( node node -- distance )
    [ top-edge ] bi@ - 75 - ;

GENERIC: find-movement ( relation -- )

M:: vertical-relation find-movement ( rel -- )
    rel node2>> rel node1>> vertical-distance :> value
    value 0 <=
    [ rel node2>> [ value neg suffix ] change-strong-vertical-force drop
      rel node1>> [ 0 suffix ] change-strong-vertical-force drop ]
    [ rel node1>> [ value suffix ] change-weak-vertical-force drop ] if ;

M:: horizontal-relation find-movement ( rel -- )
    rel node2>> rel node1>> horizontal-distance
    rel node2>> top-edge rel node1>> top-edge - abs 15 > [ 0 * ] when :> value
    value 0 <=
    [ rel node2>> [ value neg suffix ] change-strong-horizontal-force drop
      rel node1>> [ 0 suffix ] change-strong-horizontal-force drop ]
    [ rel node1>> [ value suffix ] change-weak-horizontal-force drop ] if ;

M:: centering-relation find-movement ( rel -- )
    rel node2>> rel node1>> horizontal-center-distance :> value
    rel node2>> [ [ value neg suffix ] change-strong-horizontal-force drop ] each ;

:: move-node ( node -- node )
    node strong-horizontal-force>> [ empty? not ] [ mean ] [ node weak-horizontal-force>> mean ] smart-if*
    node strong-vertical-force>> [ empty? not ] [ mean ] [ node weak-vertical-force>> mean ] smart-if* 2array
    dup [ abs 1 <= ] all? node immobile?<<
    node swap '[ _ v+ ] change-loc
    f >>strong-horizontal-force f >>weak-horizontal-force
    f >>strong-vertical-force f >>weak-vertical-force ;

: move-nodes ( graph -- graph )
    dup dup relations>> [ find-movement ] each nodes [ move-node ] map drop ;

: no-movement? ( graph -- graph )
    nodes [ immobile?>> ] all? ;

: place-nodes ( graph -- graph )
    find-relations [ dup no-movement? ] [ move-nodes ] until ;

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
