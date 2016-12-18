! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals sequences code ui.gadgets
ui.gadgets.borders ui.gadgets.icons ui.gadgets.packs ui.tools.common ;
FROM: code => inputs outputs ;
IN: ui.tools.environment.common

TUPLE: environment < tool ;
TUPLE: button-pile < pack ;
TUPLE: node-pile < pack ;
TUPLE: graph < gadget  { counter initial: 0 } ;
TUPLE: content < pack ;
TUPLE: navigation < pack ;
TUPLE: bubble < border  left right below above immobile? ;
TUPLE: connector < icon  links ;
TUPLE: connection < gadget  start end ;
TUPLE: proto-connection < gadget  loc1 loc2 ;
TUPLE: completion < pack  selected ;

: nodes ( gadget -- seq )  children>> [ bubble? ] filter ;
: connections ( gadget -- seq )  children>> [ connection? ] filter ;

M: bubble connectors ( gadget -- seq )
    children>> [ connector? ] filter ;

M: bubble inputs ( gadget -- seq )
    connectors [ control-value [ input? ] [ introduce? ] bi or ] filter ;

M: bubble outputs ( gadget -- seq )
    connectors [ control-value [ output? ] [ return? ] bi or ] filter ;

: find-env ( gadget -- env )  [ environment? ] find-parent ;
: find-vocab ( gadget -- vocab )  [ navigation? ] find-parent ;
: find-graph ( gadget -- graph )  [ graph? ] find-parent ;
: find-node ( gadget -- node )  [ bubble? ] find-parent ;
: find-completion ( gadget -- node )  [ completion? ] find-parent ;

: vocab-control-value ( gadget -- value )
    control-value [ vocab? ] find-parent ;
