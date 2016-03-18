USING: accessors debugger fry help.apropos kernel locals
models.arrow sequences skov.code skov.gadgets.graph-gadget
skov.theme strings ui.gadgets ui.gadgets.borders
ui.gadgets.packs ui.gadgets.panes vectors ;
IN: ui.tools.browser

:: graph-model ( topic -- word )
    word new 
    topic apropos-search? not [
      topic name>> string? not [
        topic name>> name>> word add-with-name
        dup contents>> first add-connectors contents>> [ special-connector? ] reject [ 
          :> inside
          inside clone add-connectors :> outside
          inside outside contents>> first connect
          outside swap [ ?push ] change-contents
        ] each 
      ] when 
    ] when ;

: <graph> ( track -- gadget )
    model>> [ graph-model ] <arrow> <graph-gadget> { 10 10 } <filled-border> with-background ;

:: <help-pane> ( browser-gadget -- gadget )
    <pile> { 0 20 } >>gap
    browser-gadget <graph> add-gadget
    browser-gadget model>> [ '[ _ print-topic ] try ] <pane-control> add-gadget ;
