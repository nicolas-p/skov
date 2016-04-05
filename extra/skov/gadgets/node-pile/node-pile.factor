! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart kernel models sequences
skov.code skov.gadgets skov.gadgets.connector-gadget
skov.gadgets.node-gadget ui.gadgets ;
IN: skov.gadgets.node-pile

: <node-pile> ( model -- gadget )
     node-pile new vertical >>orientation { 0 20 } >>gap 1/2 >>align swap >>model ;

M: node-pile model-changed
    dup clear-gadget swap value>>
    [ definition? ]
    [ unconnected-contents>> [ <node-gadget> add-gadget ] each ] smart-when* drop ;
