! Copyright (C) 2015 Nicolas Pénet.
USING: ui.gadgets ui.gadgets.borders ui.gadgets.icons
ui.gadgets.packs ui.tools.common ;
IN: skov.gadgets

TUPLE: environment-gadget < tool  modell ;
TUPLE: definition-gadget < border  modell timer ;
TUPLE: vocab-gadget < pack  modell ;
TUPLE: node-gadget < border  modell { acc initial: { 0 0 } } { vel initial: { 0 0 } } ;
TUPLE: connector-gadget < icon  modell { links initial: { } } ;
TUPLE: connection-gadget < gadget  start end ;
TUPLE: proto-connection < gadget  loc1 loc2 ;

GENERIC: update ( gadget -- gadget )
