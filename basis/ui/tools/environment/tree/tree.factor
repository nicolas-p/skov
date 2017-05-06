! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code kernel locals math.order models
sequences splitting ui.gadgets ui.gadgets.buttons.round
ui.gadgets.labels ui.gadgets.packs ui.tools.environment.cell ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.tree

TUPLE: tree < pack ;
TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control ;

: <space> ( -- gadget )
    <gadget> { 2 0 } >>dim ;

:: build-tree ( node selection -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> node subtree? [ { 0 0 } ] [ { 3 0 } ] if >>gap 1 >>align
        <space> add-gadget
        node contents>> [ selection build-tree ] map add-gadgets
        <space> add-gadget
    add-gadget
    node selection <cell> add-gadget ;

: <tree> ( word -- pile )
    tree new horizontal >>orientation swap >>model ;

M:: tree model-changed ( model tree -- )
    tree clear-gadget
    tree model value>> [ word? ] find-parent ?add-words
    contents>> [ model build-tree ] map add-gadgets drop ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;

: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> node? [
        model value>> top-node?
            [ "dark" "I" [ drop model [ introduce change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into an input cell" >>tooltip add-gadget
        model value>> top-node?
            [ "light" "T" [ drop model [ text change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into a text cell" >>tooltip add-gadget
        "green" "W" [ drop model [ call change-node-type ] change-model ] <round-button>
            "Turn cell into a word cell" >>tooltip add-gadget
 !       "green" "C" [ drop model [ constructor change-node-type ] change-model ] <round-button>
 !           "Turn cell into a constructor cell" >>tooltip add-gadget
 !       "green" "A" [ drop model [ accessor change-node-type ] change-model ] <round-button>
 !           "Turn cell into an accessor cell" >>tooltip add-gadget
 !       "green" "M" [ drop model [ mutator change-node-type ] change-model ] <round-button>
 !           "Turn cell into a mutator cell" >>tooltip add-gadget
        model value>> bottom-node?
            [ "dark" "O" [ drop model [ return change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into an output cell" >>tooltip add-gadget
        <gadget> { 20 0 } >>dim add-gadget
        model value>> parent>> variadic?
            [ "blue" "→" [ drop ] ]
            [ "inactive" " " [ drop ] ] if <round-button> 
            "Insert new cell on the right" >>tooltip add-gadget
        "blue" "↓" [ drop model [ insert-node ] change-model ] <round-button>
            "Insert new cell below" >>tooltip add-gadget 
        "red" "✕" [ drop model [ remove-node ] change-model ] <round-button>
            "Delete cell" >>tooltip add-gadget
    ] when drop ;

: <path-display> ( model -- gadget )
    path-display new horizontal >>orientation swap >>model ;

M:: path-display model-changed ( model path-display -- )
    path-display dup clear-gadget
    model value>> node? [ 
        model value>> path [ "." " ⟩ " replace " ⟩ " append
            model value>> name>> append <label> [ t >>bold? ] change-font add-gadget ] when*
    ] when drop ;

: <tree-editor> ( word -- gadget )
    <pile> { 0 15 } >>gap 1/2 >>align swap <model>
    [ <tree-toolbar> ] [ <tree> ] [ <path-display> ] tri 3array add-gadgets ;
