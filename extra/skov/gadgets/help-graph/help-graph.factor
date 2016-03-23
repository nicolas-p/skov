USING: accessors combinators help.topics kernel locals models
sequences skov.code skov.gadgets.graph-gadget skov.theme
splitting ui.gadgets.borders vectors ;
IN: skov.gadgets.help-graph

:: <help-graph> ( factor-word -- gadget )
    word new
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
      inside clone add-connectors :> outside
      inside outside contents>> first connect
      outside swap [ ?push ] change-contents
    ] each
    <model> <graph-gadget> { 20 10 } <filled-border> with-background ;
