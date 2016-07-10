! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart kernel models sequences
code ui.environment ui.environment.connector-gadget
ui.environment.node-gadget ui.gadgets ;
IN: ui.environment.node-pile

: <node-pile> ( model -- gadget )
     node-pile new vertical >>orientation { 0 20 } >>gap 1/2 >>align swap >>model ;

M: node-pile model-changed
    dup clear-gadget swap value>>
    [ definition? ]
    [ contents>> unconnected [ <node-gadget> add-gadget ] each ] smart-when* drop ;
