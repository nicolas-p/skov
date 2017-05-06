! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code kernel locals math.order models
sequences splitting ui.gadgets ui.gadgets.buttons.round
ui.gadgets.labels ui.gadgets.packs ui.tools.environment.cell ;
FROM: code => call ;
IN: ui.tools.environment.tree

: <space> ( -- gadget )
    <gadget> { 2 0 } >>dim ;

:: build-tree ( node tree selection -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> node subtree? [ { 0 0 } ] [ { 3 0 } ] if >>gap 1 >>align
        <space> add-gadget
        node contents>> [ tree selection build-tree ] map add-gadgets
        <space> add-gadget
    add-gadget
    tree selection node <cell> add-gadget ;

TUPLE: tree < pack  selection ;

: <tree> ( selection word -- pile )
    <model> tree new horizontal >>orientation swap >>model swap >>selection ;

M:: tree model-changed ( model tree -- )
    tree clear-gadget
    tree model value>> ?add-words
    contents>> [ model tree selection>> build-tree ] map add-gadgets drop ;

TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;

: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

: update-tree ( button -- )
    parent>> parent>> children>> second dup model>> swap model-changed ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> [
        "dark" "I" [ model value>> introduce change-node-type update-tree ] <round-button>
            "Turn cell into an input cell" >>tooltip add-gadget
        "green" "W" [ model value>> call change-node-type update-tree ] <round-button>
            "Turn cell into a word cell" >>tooltip add-gadget
 !       "green" "C" [ model value>> constructor change-node-type update-tree ] <round-button>
 !           "Turn cell into a constructor cell" >>tooltip add-gadget
 !       "green" "A" [ model value>> accessor change-node-type update-tree ] <round-button>
 !           "Turn cell into an accessor cell" >>tooltip add-gadget
 !       "green" "M" [ model value>> mutator change-node-type update-tree ] <round-button>
 !           "Turn cell into a mutator cell" >>tooltip add-gadget
        "light" "T" [ model value>> text change-node-type update-tree ] <round-button>
            "Turn cell into a text cell" >>tooltip add-gadget
        "dark" "O" [ model value>> return change-node-type update-tree ] <round-button>
            "Turn cell into an output cell" >>tooltip add-gadget 
        <gadget> { 20 0 } >>dim add-gadget
        "blue" "↓" [ model value>> insert-node update-tree ] <round-button>
            "Insert new cell below" >>tooltip add-gadget 
        "red" "✕" [ model value>> remove-node update-tree ] <round-button>
            "Delete cell" >>tooltip add-gadget
    ] when drop ;

: <path-display> ( model -- gadget )
    path-display new horizontal >>orientation swap >>model ;

M:: path-display model-changed ( model path-display -- )
    path-display dup clear-gadget
    model value>> [ 
        model value>> path [ "." " ⟩ " replace " ⟩ " append
            model value>> name>> append <label> [ t >>bold? ] change-font add-gadget ] when*
    ] when drop ;

:: <tree-editor> ( word -- gadget )
    <pile> { 0 15 } >>gap 1/2 >>align
    f <model>
    [ <tree-toolbar> add-gadget ]
    [ word <tree> add-gadget ]
    [ <path-display> add-gadget ] tri ;
