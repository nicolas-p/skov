! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals models sequences ui.gadgets
ui.gadgets.packs ui.tools.environment.item ;
IN: ui.tools.environment.listing

TUPLE: listing < pack ;

: <listing> ( model -- navigation )
     listing new swap >>model vertical >>orientation { 0 40 } >>gap 1/2 >>align ;

M: listing model-changed ( model gadget -- )
    dup clear-gadget swap value>> contents>> [ <model> <item> ] map add-gadgets drop ;
