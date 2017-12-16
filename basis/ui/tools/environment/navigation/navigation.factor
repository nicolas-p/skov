! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code colors combinators.smart kernel locals
models sequences ui.gadgets ui.gadgets.borders code.execution combinators
ui.gadgets.buttons ui.gadgets.buttons.round ui.gadgets.icons
ui.gadgets.labels ui.gadgets.packs ui.gestures ui.pens.tile
ui.tools.environment.theme ui.tools.environment.tree
ui.tools.environment.cell system 
ui.tools.environment.navigation.dot-pattern ;
FROM: models => change-model ;
IN: ui.tools.environment.navigation

TUPLE: navigation < pack ;

: <category> ( name -- gadget )
    <label> [ t >>bold? ] change-font { 20 0 } <border> "category"
    "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri
    os windows? [ blue-background ] [ transparent ] if dark-text-colour
    <tile-pen> >>interior { 0 22 } >>min-dim horizontal >>orientation ;

: <name-bar> ( vocab/word selection -- gadget )
    <cell> { 0 30 } >>min-dim ;

: <navigation> ( model -- navigation )
     navigation new swap >>model vertical >>orientation 1 >>fill ;

:: new-item ( navigation class -- )
    navigation control-value [ vocab? ] find-parent
    class add-from-class navigation set-control-value ;

: find-navigation ( gadget -- navigation )
    [ navigation? ] find-parent ;

: set-children-font ( gadget -- gadget )
    dup children>> [ [ label? ] [ set-result-font drop ] [ set-children-font drop ] smart-if ] each ;

M:: navigation model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> parents [ vocab? ] filter reverse
    dup last :> voc
    [ model <name-bar> ] map add-gadgets
    "Vocabularies" <category> { 0 10 } <border> <dot-pattern> add-gadget
    voc contents>> [ vocab? ] filter vocab new "⨁" >>name suffix [ model <name-bar> ] map add-gadgets
    "Words" <category> { 0 10 } <border> <dot-pattern> add-gadget
    voc contents>> [ word? ] filter word new "⨁" >>name suffix [ 
        [ model <name-bar> add-gadget ] 
        [ [ model value>> eq? ]
          [ <tree-editor> { 10 15 } <border> add-gadget ] smart-when* ]
        [ [ model value>> parent>> eq? model value>> result? and ]
          [ result>> contents>> set-children-font { 10 45 } <border> add-gadget ] smart-when* ] tri
    ] each drop ;

: toggle-result ( nav -- )
    model>> [ {
      { [ dup executable? ] [ dup run-word result>> ] }
      { [ dup result? ] [ parent>> ] }
      [  ]
    } cond ] change-model ;

navigation H{
    { T{ key-down f { C+ } "v" }    [ vocab new-item ] }
    { T{ key-down f { C+ } "V" }    [ vocab new-item ] }
    { T{ key-down f { C+ } "n" }    [ word new-item ] }
    { T{ key-down f { C+ } "N" }    [ word new-item ] }
    { T{ key-down f { S+ } "UP" }   [ model>> [ left side-node ] change-model ] }
    { T{ key-down f { S+ } "DOWN" } [ model>> [ right side-node ] change-model ] }
    { T{ key-down f { S+ } "RET" }  [ toggle-result ] }
} set-gestures
