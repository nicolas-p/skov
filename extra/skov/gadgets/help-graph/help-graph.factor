USING: accessors help.topics kernel locals models regexp
sequences skov.code skov.gadgets.graph-gadget skov.theme
splitting ui.gadgets.borders vectors ;
IN: skov.gadgets.help-graph

:: <help-graph> ( factor-word -- gadget )
    word new
    factor-word article-name word add-with-name
    dup contents>> first add-connectors contents>>
    [ special-connector? ] reject [ 
      :> inside
      inside clone add-connectors :> outside
      inside outside contents>> first connect
      outside swap [ ?push ] change-contents
    ] each
    <model> <graph-gadget> { 10 10 } <filled-border> with-background ;
