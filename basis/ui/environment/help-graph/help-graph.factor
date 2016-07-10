! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators help.topics kernel locals models
sequences code ui.environment.graph-gadget ui.environment.theme
splitting ui.gadgets.borders vectors ;
IN: ui.environment.help-graph

:: <help-graph> ( factor-word -- gadget )
    definition new
    factor-word article-name 
    { { [ dup " (accessor)" swap subseq? ] [ " (accessor)" "" replace accessor ] }
      { [ dup " (mutator)" swap subseq? ] [ " (mutator)" "" replace mutator ] }
      { [ dup " (constructor)" swap subseq? ] [ " (constructor)" "" replace constructor ] }
      { [ dup " (destructor)" swap subseq? ] [ " (destructor)" "" replace destructor ] }
      [ word ]
    } cond add-with-name
    dup contents>> first add-connectors contents>> visible
    [ :> inside
      inside input? [ introduce ] [ return ] if new
      inside name>> >>name add-connectors :> outside
      inside outside contents>> first order-connectors connect
      outside add-element
    ] each
    <model> <graph-gadget> { 20 10 } <filled-border> with-background ;
