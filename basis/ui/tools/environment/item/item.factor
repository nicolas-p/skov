! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.execution kernel locals models
sequences ui.gadgets ui.gadgets.buttons ui.gadgets.buttons.round
ui.gadgets.packs ui.tools.environment.tree ui.gadgets.labels
ui.tools.environment.theme ui.gadgets.borders ui.pens.tile colors ui.gestures ;
IN: ui.tools.environment.item

TUPLE: item < pack  active? ;
TUPLE: item-title < border ;

: associated-word ( button -- word )
    parent>> children>> last ;

: select-result ( cell -- )
    [ control-value result>> ] keep set-control-value ;

: <result-button> ( -- button )
    [ associated-word dup control-value run-word select-result ] "result" <word-button> 
    "Run word and display result     ( backspace )" >>tooltip ;

: <error-button> ( -- button )
    [ drop ] "error" <word-button> 
    "There is an error in this word" >>tooltip ;

: <item> ( model -- navigation )
     item new swap >>model vertical >>orientation 1/2 >>align 1 >>fill ;

: ?add-result-button ( cell -- gadget )
    dup control-value executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( cell -- gadget )
    dup control-value error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ;

: title-theme ( title -- title )
    dup parent>> active?>> [ "title-active" ] [ "title-inactive" ] if
    "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri
    transparent light-text-colour
    <tile-pen> >>interior
    horizontal >>orientation
    { 0 30 } >>min-dim ;

M: item-title graft*
   title-theme drop ;

M:: item model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> name>> <label> set-font item-title new-border add-gadget
    gadget active?>>
    [ model value>> <inside-tree> { 10 40 } <border> add-gadget ] when drop ;

: update ( gadget -- )
    dup control-value swap set-control-value ;

: expand ( item-title -- )
    parent>> dup parent>> children>> [ f >>active? update ] each
    t >>active? update ;

item-title H{
    { T{ button-down }  [ expand ] }
} set-gestures
