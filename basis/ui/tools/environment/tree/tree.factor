! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code kernel locals math math.order
math.vectors models sequences splitting ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.round ui.gadgets.labels
ui.gadgets.packs ui.gadgets.packs.private ui.gestures
ui.pens.solid ui.tools.environment.cell
ui.tools.environment.theme ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.tree

TUPLE: tree < pack ;
TUPLE: tree-control < pack ;
TUPLE: tree-toolbar < tree-control ;
TUPLE: path-display < tree-control ;
TUPLE: special-pile < pack ;

: <special-pile> ( -- pack )
    special-pile new vertical >>orientation ;

: center-point ( gadget -- x )
    [ [ parent>> loc>> ] [ loc>> ] bi v+ ] [ dim>> ] bi [ first ] bi@ 2 /i + ;

M:: special-pile layout* ( pack -- )
    pack call-next-method
    pack children>> first2 :> ( shelf cell )
    shelf layout
    shelf children>> empty? [ 
        shelf children>> [ first ] [ last ] bi [ children>> last center-point ] bi@ :> ( a b )
        cell pref-dim first2 [ b a - 20 + max ] dip 2array cell dim<<
        a b + 2 /i cell dim>> first 2 /i - dup neg?
        [ neg shelf loc>> second 2array shelf loc<< ]
        [ cell loc>> second 2array cell loc<< ] if
    ] unless ;

:: build-tree ( node selection -- pile )
    <special-pile> { 0 1 } >>gap
        <shelf> { 9 0 } >>gap 1 >>align
            node contents>> [ selection build-tree ] map add-gadgets add-gadget
        node selection <cell> add-gadget ;

: <tree> ( word -- pile )
    tree new horizontal >>orientation swap >>model { 15 0 } >>gap 1 >>align ;

M:: tree model-changed ( model tree -- )
    tree clear-gadget
    tree model value>> [ word? ] find-parent ?add-words
    contents>> [ model build-tree ] map add-gadgets drop ;

M: tree-control pref-dim*
    call-next-method first2 20 max 2array ;

: <tree-toolbar> ( model -- gadget )
    tree-toolbar new horizontal >>orientation { 5 0 } >>gap swap >>model ;

:: add-button ( toolbar cond-quot color letter action-quot tooltip -- toolbar )
    toolbar dup control-value cond-quot call( x -- ? )
    [ color letter [ drop toolbar model>> action-quot change-model ] ]
    [ inactive-background "" [ drop ] ] if <round-button>
    tooltip >>tooltip add-gadget ;

M:: tree-toolbar model-changed ( model tree-toolbar -- )
    tree-toolbar dup clear-gadget
    model value>> [ word? ] find-parent ?add-words drop
    model value>> node? [
        [ top-node? ] dark-background "I" [ introduce change-node-type ]
            "Convert cell into an input cell    ( Ctrl I )" add-button
        [ top-node? ] yellow-background "G" [ getter change-node-type ]
            "Convert cell into a get cell    ( Ctrl G )" add-button
        [ top-node? ] white-background "T" [ text change-node-type ]
            "Convert cell into a text cell    ( Ctrl T )" add-button
        <gadget> add-gadget
        [ subtree? not ] green-background "W" [ call change-node-type ]
            "Convert cell into a word cell    ( Ctrl W )" add-button
        <gadget> add-gadget
        [ bottom-node? ] yellow-background "S" [ setter change-node-type ]
             "Convert cell into a set cell    ( Ctrl S )" add-button
        [ [ bottom-node? ] [ no-return? ] [ return? ] tri or and ]
            dark-background "O" [ return change-node-type ]
            "Convert cell into an output cell    ( Ctrl O )" add-button
        <gadget> { 20 0 } >>dim add-gadget
        [ parent>> [ variadic? ] [ word? ] bi or ]
            blue-background "←" [ insert-node-left ]
            "Insert new cell on the left    ( Alt ← )" add-button
        [ parent>> [ variadic? ] [ word? ] bi or ]
            blue-background "→" [ insert-node-right ]
            "Insert new cell on the right    ( Alt → )" add-button
        [ drop t ] blue-background "↓" [ insert-node ]
            "Insert new cell below    ( Alt ↓ )" add-button
        [ drop t ] red-background "✕" [ remove-node ]
            "Delete cell    ( Ctrl R )" add-button
    ] when drop ;

: <path-display> ( model -- gadget )
    path-display new horizontal >>orientation swap >>model ;

M:: path-display model-changed ( model path-display -- )
    path-display dup clear-gadget
    model value>> call? [ 
        model value>> path [ "." " ⟩ " replace " ⟩ " append
        model value>> name>> append <label> [ t >>bold? ] change-font add-gadget ] when*
    ] when drop ;

: <tree-editor> ( word -- gadget )
    <pile> { 0 20 } >>gap 1/2 >>align swap <model>
    [ <tree-toolbar> ] [ <tree> ] [ <path-display> ] tri 3array add-gadgets ;

: select-nothing ( tree -- )
    model>> [ [ node? not ] find-parent ] change-model ;

tree H{
    { T{ button-down } [ select-nothing ] }
} set-gestures
