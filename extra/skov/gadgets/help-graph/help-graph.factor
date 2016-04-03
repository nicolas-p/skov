USING: accessors combinators help.topics kernel locals models
sequences skov.code skov.gadgets.graph-gadget skov.theme
splitting ui.gadgets.borders vectors ;
IN: skov.gadgets.help-graph

:: <help-graph> ( factor-word -- gadget )
    definition new
    factor-word article-name 
    { { [ dup " (accessor)" swap subseq? ] [ " (accessor)" "" replace accessor ] }
      { [ dup " (mutator)" swap subseq? ] [ " (mutator)" "" replace mutator ] }
      { [ dup " (constructor)" swap subseq? ] [ " (constructor)" "" replace constructor ] }
      { [ dup " (destructor)" swap subseq? ] [ " (destructor)" "" replace destructor ] }
      [ word ]
    } cond add-with-name
    dup contents>> first add-connectors contents>>
    [ special-connector? ] reject [ 
      :> inside
      inside input? [ definition-input ] [ definition-output ] if new
      inside name>> >>name add-connectors :> outside
      inside outside contents>> first order-connectors connect
      outside add-element
    ] each
    <model> <graph-gadget> { 20 10 } <filled-border> with-background ;
