! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.execution kernel locals models
sequences ui.gadgets ui.gadgets.buttons ui.gadgets.buttons.round
ui.gadgets.packs ui.tools.environment.tree ui.gadgets.labels ;
IN: ui.tools.environment.item

TUPLE: item < pack ;

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
     item new swap >>model vertical >>orientation 1/2 >>align { 0 20 } >>gap ;

: ?add-result-button ( cell -- gadget )
    dup control-value executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( cell -- gadget )
    dup control-value error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ;

M: item model-changed ( model gadget -- )
    dup clear-gadget swap value>> 
    [ name>> <label> add-gadget ]
    [ <inside-tree> add-gadget ] bi drop ;
