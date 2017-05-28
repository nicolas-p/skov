! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code kernel locals math math.order
math.vectors models sequences splitting ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.round ui.gadgets.labels
ui.gadgets.packs ui.gadgets.packs.private ui.gestures
ui.tools.environment.cell ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.tree

TUPLE: tree < pack ;
TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control ;
TUPLE: elastic-shelf < pack ;

: <elastic-shelf> ( -- pack )
    elastic-shelf new horizontal >>orientation ;

: elastic-layout ( pack -- sizes )
    [ children>> pref-dims dup [ first ] map sum ]
    [ dim>> first ]
    [ gap-dim first ] tri
    - / 1 2array [ v/ ] curry map ;

M: elastic-shelf layout*
    dup elastic-layout pack-layout ;

:: build-tree ( node selection -- shelf )
    <pile> 1 >>fill
        <elastic-shelf> { 3 0 } >>gap 1 >>align
            node contents>> [ selection build-tree ] map add-gadgets
            node subtree? { 2 0 } { 5 0 } ? <filled-border> add-gadget
        node selection <cell> add-gadget ;

: <tree> ( word -- pile )
    tree new horizontal >>orientation swap >>model { 15 0 } >>gap 1 >>align ;

M:: tree model-changed ( model tree -- )
    tree clear-gadget
    tree model value>> [ word? ] find-parent
    contents>> [ model build-tree ] map add-gadgets drop ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;

: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> [ word? ] find-parent ?add-words drop
    model value>> node? [
        model value>> top-node?
            [ "dark" "I" [ drop model [ introduce change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into an input cell" >>tooltip add-gadget
        model value>> top-node?
            [ "yellow" "G" [ drop model [ getter change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into a get cell" >>tooltip add-gadget
        model value>> top-node?
            [ "light" "T" [ drop model [ text change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into a text cell" >>tooltip add-gadget
        <gadget> add-gadget
        "green" "W" [ drop model [ call change-node-type ] change-model ] <round-button>
            "Turn cell into a word cell" >>tooltip add-gadget
 !       "green" "C" [ drop model [ constructor change-node-type ] change-model ] <round-button>
 !           "Turn cell into a constructor cell" >>tooltip add-gadget
 !       "green" "A" [ drop model [ accessor change-node-type ] change-model ] <round-button>
 !           "Turn cell into an accessor cell" >>tooltip add-gadget
 !       "green" "M" [ drop model [ mutator change-node-type ] change-model ] <round-button>
 !           "Turn cell into a mutator cell" >>tooltip add-gadget
        <gadget> add-gadget
        model value>> bottom-node?
            [ "yellow" "S" [ drop model [ setter change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into a set cell" >>tooltip add-gadget
        model value>> [ bottom-node? ] [ no-return? ] [ return? ] tri or and
            [ "dark" "O" [ drop model [ return change-node-type ] change-model ] ]
            [ "inactive" "" [ drop ] ] if <round-button>
            "Turn cell into an output cell" >>tooltip add-gadget
        <gadget> { 20 0 } >>dim add-gadget
        model value>> parent>> [ variadic? ] [ word? ] bi or
            [ "blue" "←" [ drop model [ insert-node-left ] change-model ] ]
            [ "inactive" " " [ drop ] ] if <round-button> 
            "Insert new cell on the left" >>tooltip add-gadget
        model value>> parent>> [ variadic? ] [ word? ] bi or
            [ "blue" "→" [ drop model [ insert-node-right ] change-model ] ]
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

: select-nothing ( tree -- )
    model>> [ [ node? not ] find-parent ] change-model ;

tree H{
    { T{ button-down } [ select-nothing ] }
} set-gestures
