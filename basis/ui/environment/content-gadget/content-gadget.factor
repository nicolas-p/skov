! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators combinators.smart kernel
locals models sequences strings ui.environment
ui.environment.graph-gadget ui.environment.node-gadget
ui.environment.theme ui.gadgets ui.gadgets.icons
ui.gadgets.labels ui.gadgets.packs ;
IN: ui.environment.content-gadget

: <content-gadget> ( model -- gadget )
     content-gadget new swap >>model ;

: set-children-font ( gadget -- )
    children>> [ [ label? ] [ set-light-font drop ] [ set-children-font ] smart-if ] each ;

: <node-pile> ( seq -- gadget )
    <pile> { 0 20 } >>gap 1/2 >>align swap [ <node-gadget> ] map add-gadgets ;

:: display-word ( word -- gadget )
    <shelf> { 20 0 } >>gap 1/2 >>align
        word contents>> unconnected <node-pile> add-gadget
        word group-connected-nodes [ <graph-gadget> ] map add-gadgets ;

:: display-class ( class -- gadget )
    <pile> { 0 20 } >>gap 1/2 >>align
        "Class with slots:" <label> set-light-font add-gadget 
        class contents>> unconnected <node-pile> add-gadget ;

M: content-gadget model-changed
    dup clear-gadget swap
    value>> {
      { [ dup result? ] [ contents>> dup set-children-font add-gadget ] }
      { [ dup vocab? ] [ drop "skov-logo" theme-image <icon> add-gadget ] }
      { [ dup class? ] [ display-class add-gadget ] }
      { [ dup word? ] [ display-word add-gadget ] }
      [ drop ]
    } cond drop ;
