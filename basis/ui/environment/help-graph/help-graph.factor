! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.factor-abstraction kernel
locals models sequences ui.environment.graph-gadget
ui.environment.theme ui.gadgets.borders ;
IN: ui.environment.help-graph

:: <help-graph> ( factor-word -- gadget )
    definition new
    factor-word word-from-factor add-element
    dup contents>> first contents>> visible
    [ :> inside
      inside input? [ introduce ] [ return ] if new
      inside name>> >>name add-connectors :> outside
      inside outside contents>> first order-connectors connect
      outside add-element
    ] each
    <model> <graph-gadget> { 20 10 } <filled-border> with-background ;
