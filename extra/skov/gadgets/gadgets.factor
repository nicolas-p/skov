! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals sequences skov.code ui.gadgets
ui.gadgets.borders ui.gadgets.icons ui.gadgets.packs ui.tools.common ;
IN: skov.gadgets

TUPLE: environment-gadget < tool ;
TUPLE: plus-button-pile < pack ;
TUPLE: node-pile < pack ;
TUPLE: graph-gadget < gadget ;
TUPLE: result-gadget < pack ;
TUPLE: vocab-gadget < pack { scroll-position initial: 0 } ;
TUPLE: node-gadget < border springs { acc initial: { 0 1 } } 
                                    { vel initial: { 0 0 } } ;
TUPLE: connector-gadget < icon { links initial: { } } ;
TUPLE: connection-gadget < gadget  start end ;
TUPLE: proto-connection < gadget  loc1 loc2 ;

: nodes>> ( def -- seq )  children>> [ node-gadget? ] filter ;
: connections>> ( def -- seq )  children>> [ connection-gadget? ] filter ;
M: node-gadget connectors>> ( node-gadget -- seq )  children>> [ connector-gadget? ] filter ;
M: node-gadget inputs>> ( node-gadget -- seq )  connectors>> [ control-value input? ] filter ;
M: node-gadget outputs>> ( node-gadget -- seq )  connectors>> [ control-value output? ] filter ;

: find-env ( gadget -- env )  [ environment-gadget? ] find-parent ;
: find-vocab ( gadget -- vocab )  [ vocab-gadget? ] find-parent ;
: find-graph ( gadget -- graph )  [ graph-gadget? ] find-parent ;
: find-node ( gadget -- node )  [ node-gadget? ] find-parent ;

CONSTANT: connector-size 8
CONSTANT: node-height 28
CONSTANT: min-node-width 40

: vocab-control-value ( gadget -- value )
    control-value [ vocab? ] find-parent ;

:: change-control-value ( gadget quot -- )
    gadget control-value quot call( x -- x ) gadget set-control-value ;

:: change-vocab-control-value ( gadget quot -- )
    gadget control-value dup [ vocab? ] find-parent quot call( x -- x ) drop gadget set-control-value ;
