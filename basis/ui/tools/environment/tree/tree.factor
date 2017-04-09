! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code kernel locals math.order models
sequences splitting ui.gadgets ui.gadgets.buttons.round
ui.gadgets.labels ui.gadgets.packs ui.tools.environment.cell ;
IN: ui.tools.environment.tree

: <space> ( -- gadget )
    <gadget> { 5 0 } >>dim ;

:: build-tree ( node selection -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> { 3 0 } >>gap 1 >>align
        <space> add-gadget
        node contents>> [ selection build-tree ] map add-gadgets
        <space> add-gadget
    add-gadget
    selection node <cell> add-gadget ;

:: <inside-tree> ( selection word -- pile )
    <shelf> word contents>> [ selection build-tree ] map add-gadgets ;

:: <outside-tree> ( word -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> { 3 0 } >>gap 1 >>align word introduces [ <cell> ] map add-gadgets add-gadget
    word <cell> add-gadget
    word returns [ first <cell> add-gadget ] unless-empty ;

TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;
    
: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> [ 
        "dark" "I" [ drop model value>> drop ] <round-button>
            "Turn cell into an input cell" >>tooltip add-gadget
        "green" "W" [ drop model value>> drop ] <round-button>
            "Turn cell into a word cell" >>tooltip add-gadget
        "green" "C" [ drop model value>> drop ] <round-button>
            "Turn cell into a constructor cell" >>tooltip add-gadget
        "green" "A" [ drop model value>> drop ] <round-button>
            "Turn cell into an accessor cell" >>tooltip add-gadget
        "green" "M" [ drop model value>> drop ] <round-button>
            "Turn cell into a mutator cell" >>tooltip add-gadget
        "light" "T" [ drop model value>> drop ] <round-button>
            "Turn cell into a text cell" >>tooltip add-gadget
        "dark" "O" [ drop model value>> drop ] <round-button>
            "Turn cell into an output cell" >>tooltip add-gadget 
        <gadget> { 20 0 } >>dim add-gadget
        "blue" "↓" [ drop model value>> drop ] <round-button>
            "Insert new cell below" >>tooltip add-gadget 
        "red" "✕" [ drop model value>> drop ] <round-button>
            "Delete cell" >>tooltip add-gadget
    ] when drop ;

: <path-display> ( model -- gadget )
    path-display new horizontal >>orientation swap >>model ;

M:: path-display model-changed ( model path-display -- )
    path-display dup clear-gadget
    model value>> [ 
        model value>> path "." " ⟩ " replace <label> [ t >>bold? ] change-font add-gadget
    ] when drop ;

:: <tree-editor> ( word -- gadget )
    <pile> { 0 15 } >>gap 1/2 >>align
    f <model>
    [ <tree-toolbar> add-gadget ]
    [ word <inside-tree> add-gadget ]
    [ <path-display> add-gadget ] tri ;
