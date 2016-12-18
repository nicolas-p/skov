! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.factor-abstraction kernel
locals models sequences ui.tools.environment.graph
ui.tools.environment.theme ui.gadgets.borders ;
IN: ui.tools.environment.graph.help-graph

:: <help-graph> ( factor-word -- gadget )
    word new
    factor-word call-from-factor add-element
    dup contents>> first contents>> visible
    [ :> inside
      inside input? [ introduce ] [ return ] if new
      inside name>> >>name add-connectors :> outside
      inside outside contents>> first order-connectors connect
      outside add-element
    ] each
    contents>> <graph> { 20 10 } <filled-border> with-background ;
