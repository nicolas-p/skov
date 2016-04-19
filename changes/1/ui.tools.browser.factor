USING: accessors debugger fry kernel
skov.gadgets.activate-button ui.gadgets ui.gadgets.borders
ui.gadgets.panes ui.gadgets.tracks ;
IN: ui.tools.browser

: <help-header> ( browser-gadget -- gadget )
    horizontal <track> swap model>> 
    [ [ '[ _ $title ] try ] <pane-control> 1 track-add ]
    [ <active/inactive> { 5 0 } <border> f track-add ] bi ;
