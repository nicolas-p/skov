! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart kernel locals math
math.order math.vectors models namespaces sequences code
code.execution ui.tools.environment.common
ui.gadgets.buttons.round ui.tools.environment.cell ui.tools.environment.theme
ui.gadgets ui.gadgets.buttons ui.gadgets.icons ui.gadgets.packs
ui.gestures ui.tools.environment.actions ui.tools.environment.tree ;
IN: ui.tools.environment.navigation

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 0 25 } ;

: <separator> ( -- img )
    "separator" theme-image <icon> ;

: <new-vocab-button> ( -- button )
    "orange" [ parent>> vocab add-to-vocab ] <plus-button> 
    "New vocabulary     ( V )" >>tooltip ;

: <new-word-button> ( -- button )
    "green" [ parent>> word add-to-vocab ] <plus-button>
    "New word     ( N )" >>tooltip ;

: <new-tuple-button> ( -- button )
    "blue" [ parent>> word add-to-vocab ] <plus-button>
    "New class     ( K )" >>tooltip ;

: associated-word ( button -- word )
    parent>> children>> last ;

: <result-button> ( -- button )
    [ associated-word dup control-value run-word select-result ] "result" <word-button> 
    "Run word and display result     ( backspace )" >>tooltip ;

: <error-button> ( -- button )
    [ drop ] "error" <word-button> 
    "There is an error in this word" >>tooltip ;

: <navigation> ( model -- navigation )
     navigation new swap >>model vertical >>orientation { 0 30 } >>gap 1/2 >>align ;

:: ?select-result-button ( navigation -- navigation )
    navigation dup find-env control-value :> env-model
    dup children>> [ pack? ] filter [ gadget-child button? ] filter
    [ children>> first2 control-value result>> env-model eq? >>selected? drop ] each ;

: ?add-result-button ( cell -- gadget )
    dup control-value executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( cell -- gadget )
    dup cell? [ dup control-value error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ] when ;

M:: navigation model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> contents>> [ <inside-tree> ] map add-gadgets drop ;
