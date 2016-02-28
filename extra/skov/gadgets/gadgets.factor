! Copyright (C) 2015 Nicolas Pénet.
USING: ui.gadgets ui.gadgets.borders ui.gadgets.icons
ui.gadgets.packs ui.tools.common ;
IN: skov.gadgets

TUPLE: environment-gadget < tool  modell ;
TUPLE: definition-gadget < border  modell ;
TUPLE: vocab-gadget < pack  modell { scroll-position initial: 0 } ;
TUPLE: node-gadget < border  modell springs { acc initial: { 0 1 } } 
                                            { vel initial: { 0 0 } } 
                                            { pos initial: { 0 0 } } ;
TUPLE: connector-gadget < icon  modell { links initial: { } } ;
TUPLE: connection-gadget < gadget  start end ;
TUPLE: proto-connection < gadget  loc1 loc2 ;

GENERIC: update ( gadget -- gadget )

: find-env ( gadget -- env )  [ environment-gadget? ] find-parent ;
: find-vocab ( gadget -- vocab )  [ vocab-gadget? ] find-parent ;
: find-def ( gadget -- def )  [ definition-gadget? ] find-parent ;
: find-node ( gadget -- node )  [ node-gadget? ] find-parent ;
