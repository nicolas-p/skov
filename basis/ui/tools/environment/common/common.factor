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
TUPLE: cell < border  left right below above immobile? ;
TUPLE: completion < pack  selected ;

: nodes ( gadget -- seq )  children>> [ cell? ] filter ;

: find-env ( gadget -- env )  [ environment? ] find-parent ;
: find-vocab ( gadget -- vocab )  [ navigation? ] find-parent ;
: find-graph ( gadget -- graph )  [ graph? ] find-parent ;
: find-node ( gadget -- node )  [ cell? ] find-parent ;
: find-completion ( gadget -- node )  [ completion? ] find-parent ;

: vocab-control-value ( gadget -- value )
    control-value [ vocab? ] find-parent ;
