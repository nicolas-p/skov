! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code colors combinators.smart kernel locals
models sequences ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.packs ui.gestures ui.pens.tile
ui.tools.environment.theme ui.tools.environment.tree ;
IN: ui.tools.environment.navigation

TUPLE: navigation < pack ;
TUPLE: name-bar < border ;

: <name-bar> ( vocab/word -- gadget )
    [ <model> ] [ name>> <label> set-font ] bi
    name-bar new-border swap >>model horizontal >>orientation { 0 30 } >>min-dim ;

M: name-bar graft*
    dup dup parent>> [ control-value ] bi@ eq? [ "title-active" ] [ "title-inactive" ] if
    "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri
    transparent light-text-colour
    <tile-pen> >>interior drop ;

: <navigation> ( model -- navigation )
     navigation new swap >>model vertical >>orientation 1/2 >>align 1 >>fill ;

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 0 40 } ;

M:: navigation model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> parents [ vocab? ] filter reverse
    dup last :> voc
    [ <name-bar> ] map add-gadgets
    voc contents>> [ vocab? ] filter 
    dup [ drop [ <space> add-gadget ] dip ] unless-empty
    [ <name-bar> ] map add-gadgets
    <space> add-gadget
    voc contents>> [ word? ] filter [ 
        [ <name-bar> add-gadget ] 
        [ [ model value>> eq? ] [ <inside-tree> { 10 40 } <border> add-gadget ] smart-when* ] bi
    ] each drop ;

: select ( name-bar -- )
    dup control-value swap parent>> set-control-value ;

name-bar H{
    { T{ button-up }  [ select ] }
} set-gestures
