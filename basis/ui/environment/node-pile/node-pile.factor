! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators.smart kernel models sequences
ui.environment ui.environment.connector-gadget
ui.environment.node-gadget ui.environment.theme ui.gadgets
ui.gadgets.labels ;
IN: ui.environment.node-pile

: <node-pile> ( model -- gadget )
     node-pile new vertical >>orientation { 0 20 } >>gap 1/2 >>align swap >>model ;

M: node-pile model-changed
    dup clear-gadget swap value>>
    [ class? ]
    [ [ "Class with slots:" <label> set-light-font add-gadget ] dip ] smart-when
    [ definition? ]
    [ contents>> unconnected [ <node-gadget> add-gadget ] each ] smart-when* drop ;
