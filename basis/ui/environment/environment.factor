! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals sequences code ui.gadgets
ui.gadgets.borders ui.gadgets.icons ui.gadgets.packs ui.tools.common ;
FROM: code => inputs outputs ;
IN: ui.environment

TUPLE: environment-gadget < tool ;
TUPLE: plus-button-pile < pack ;
TUPLE: node-pile < pack ;
TUPLE: graph-gadget < gadget  { counter initial: 0 } ;
TUPLE: result-gadget < pack ;
TUPLE: vocab-gadget < pack ;
TUPLE: node-gadget < border  left right below above immobile? ;
TUPLE: connector-gadget < icon  links ;
TUPLE: connection-gadget < gadget  start end ;
TUPLE: proto-connection < gadget  loc1 loc2 ;
TUPLE: completion-gadget < pack  selected ;

: nodes ( gadget -- seq )  children>> [ node-gadget? ] filter ;
: connections ( gadget -- seq )  children>> [ connection-gadget? ] filter ;

M: node-gadget connectors ( gadget -- seq )
    children>> [ connector-gadget? ] filter ;

M: node-gadget inputs ( gadget -- seq )
    connectors [ control-value [ input? ] [ introduce? ] bi or ] filter ;

M: node-gadget outputs ( gadget -- seq )
    connectors [ control-value [ output? ] [ return? ] bi or ] filter ;

: find-env ( gadget -- env )  [ environment-gadget? ] find-parent ;
: find-vocab ( gadget -- vocab )  [ vocab-gadget? ] find-parent ;
: find-graph ( gadget -- graph )  [ graph-gadget? ] find-parent ;
: find-node ( gadget -- node )  [ node-gadget? ] find-parent ;
: find-completion ( gadget -- node )  [ completion-gadget? ] find-parent ;

CONSTANT: connector-size 10
CONSTANT: node-height 28
CONSTANT: min-node-width 45

: vocab-control-value ( gadget -- value )
    control-value [ vocab? ] find-parent ;

:: change-control-value ( gadget quot -- )
    gadget control-value quot call( x -- x ) gadget set-control-value ;

:: change-vocab-control-value ( gadget quot -- )
    gadget control-value dup [ vocab? ] find-parent quot call( x -- x ) drop gadget set-control-value ;
