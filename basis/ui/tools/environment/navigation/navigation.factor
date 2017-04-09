! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code colors combinators.smart kernel locals
models sequences ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.buttons.round ui.gadgets.icons
ui.gadgets.labels ui.gadgets.packs ui.gestures ui.pens.tile
ui.tools.environment.theme ui.tools.environment.tree ;
IN: ui.tools.environment.navigation

TUPLE: navigation < pack ;
TUPLE: name-bar < border ;

: <category> ( name -- gadget )
    <label> [ t >>bold? ] change-font { 20 0 } <border> "category"
    "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri
    transparent dark-text-colour
    <tile-pen> >>interior { 0 22 } >>min-dim horizontal >>orientation ;

: <name-bar> ( vocab/word -- gadget )
    [ <model> ] [ name>> [ "⨁" ] when-empty <label> set-font ] bi
    name-bar new-border swap >>model horizontal >>orientation { 0 30 } >>min-dim ;

M: name-bar graft*
    dup dup parent>> [ control-value ] bi@ eq? [ "title-active" ] [ "title-inactive" ] if
    "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri
    transparent light-text-colour
    <tile-pen> >>interior drop ;

: <navigation> ( model -- navigation )
     navigation new swap >>model vertical >>orientation 1/2 >>align 1 >>fill ;

:: new-item ( navigation class -- )
    navigation control-value [ vocab? not ] [ parent>> ] smart-when
    class add-from-class navigation set-control-value ;

: find-navigation ( gadget -- navigation )
    [ navigation? ] find-parent ;

M:: navigation model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> parents [ vocab? ] filter reverse
    dup last :> voc
    [ <name-bar> ] map add-gadgets
    <gadget> { 0 20 } >>dim add-gadget
    "Vocabularies" <category> { 0 10 } <border> add-gadget
    voc contents>> [ vocab? ] filter vocab new suffix [ <name-bar> ] map add-gadgets
    <gadget> { 0 20 } >>dim add-gadget
    "Words" <category> { 0 10 } <border> add-gadget
    voc contents>> [ word? ] filter word new suffix [ 
        [ <name-bar> add-gadget ] 
        [ [ model value>> eq? ] [ <tree-editor> { 10 15 } <border> add-gadget ] smart-when* ] bi
    ] each drop ;

: select ( name-bar -- )
    dup control-value swap parent>> set-control-value ;

name-bar H{
    { T{ button-up }  [ select ] }
} set-gestures
