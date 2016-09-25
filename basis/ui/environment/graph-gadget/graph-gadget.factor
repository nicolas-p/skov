! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs code code.execution
combinators.smart fry kernel locals math math.order
math.statistics math.vectors models sequences sequences.deep
sets ui.environment ui.environment.connector-gadget
ui.environment.node-gadget ui.gadgets sorting combinators ;
FROM: code => inputs outputs ;
IN: ui.environment.graph-gadget

: register-above ( node node' -- node )  [ suffix ] curry change-above ;
: register-below ( node node' -- node )  [ suffix ] curry change-below ;
: register-left ( node node' -- node )  [ suffix ] curry change-left ;
: register-right ( node node' -- node )  [ suffix ] curry change-right ;

: find-vertical-relations ( node -- seq )
    dup inputs connected [ links>> first parent>> register-above ] each
    dup outputs connected [ links>> first parent>> register-below ] each ;

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
    dup nodes [ find-vertical-relations find-horizontal-relations ] map drop ;

: horizontal-distance ( node node -- distance )
    [ left-edge ] [ right-edge ] bi* - 20 - ;

: horizontal-center-distance ( node node -- distance )
    [ center ] bi@ - ;

: vertical-distance ( node node -- distance )
    [ top-edge ] bi@ - 75 - ;

: infimum* ( seq -- x )  [ 1000 ] [ infimum ] if-empty ;
: supremum* ( seq -- x )  [ -1000 ] [ supremum ] if-empty ;

:: raw-horizontal-movement ( node -- xmin xmax x )
    node node left>> [ horizontal-distance neg ] with map dup supremum* swap
    node node right>> [ swap horizontal-distance ] with map dup infimum* -rot
    node node above>> node below>> append [ horizontal-center-distance neg ] with map
    append append mean ;

:: raw-vertical-movement ( node -- ymin ymax y )
    node node above>> [ vertical-distance neg ] with map dup supremum* swap
    node node below>> [ swap vertical-distance ] with map dup infimum* -rot
    append mean ;

:: horizontal-movement ( node -- x )
    node raw-horizontal-movement :> ( xmin xmax x )
    { 
        { [ x xmax > ] [
            node right>> node node right>> [ swap horizontal-distance ] with map 
            zip sort-values first first :> other-node
            other-node raw-horizontal-movement :> ( xmin' xmax' x' )
            x xmax - x' xmin' 0 min - + 2 /i :> difference
            xmax difference +
            other-node difference '[ _ 0 2array v+ ] change-loc drop
        ] } 
        { [ x xmin < ] [
            node left>> node node left>> [ horizontal-distance neg ] with map 
            zip sort-values reverse first first :> other-node
            other-node raw-horizontal-movement :> ( xmin' xmax' x' )
            x xmin - x' xmax' 0 max - + 2 /i :> difference
            xmin difference +
            other-node difference '[ _ 0 2array v+ ] change-loc drop
        ] } 
        [ x ]
    } cond ;

:: vertical-movement ( node -- y )
    node raw-vertical-movement swap min swap max ;

:: move-node ( node -- )
    node node horizontal-movement node vertical-movement 2array
    dup [ abs 1 <= ] all? node immobile?<<
    '[ _ v+ ] change-loc drop ;

: move-nodes ( graph -- graph )
    dup nodes [ move-node ] each ;

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
