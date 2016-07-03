! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart kernel locals math
math.order math.vectors models namespaces sequences skov.code
skov.execution skov.gadgets skov.gadgets.activate-button
skov.gadgets.buttons skov.gadgets.node-gadget skov.theme
ui.gadgets ui.gadgets.buttons ui.gadgets.icons ui.gadgets.packs
ui.gestures ;
QUALIFIED: vocabs
IN: skov.gadgets.vocab-gadget

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 0 25 } ;

: <separator> ( -- img )
    "separator" theme-image <icon> ;

:: add-to-vocab ( env class -- )
    env [ class add-from-class ] change-vocab-control-value ;

: <new-vocab-button> ( -- button )
    "orange" [ parent>> vocab add-to-vocab ] <plus-button> 
    "New vocabulary ( v )" >>tooltip ;

: <new-word-button> ( -- button )
    "green" [ parent>> word-definition add-to-vocab ] <plus-button>
    "New word ( n )" >>tooltip ;

: <new-tuple-button> ( -- button )
    "blue" [ parent>> tuple-definition add-to-vocab ] <plus-button>
    "New tuple class ( u )" >>tooltip ;

: associated-word ( button -- word )
    parent>> children>> last ;

: <result-button> ( -- button )
    [ associated-word dup control-value run-word select-result ] "result" <word-button> 
    "Run word and display result ( backspace )" >>tooltip ;

: <error-button> ( -- button )
    [ drop ] "error" <word-button> 
    "There is an error in this word" >>tooltip ;

: <vocab-gadget> ( model -- vocab-gadget )
     vocab-gadget new swap >>model vertical >>orientation { 0 5 } >>gap 1/2 >>align ;

:: ?select-result-button ( vocab-gadget -- vocab-gadget )
    vocab-gadget dup find-env control-value :> env-model
    dup children>> [ pack? ] filter [ gadget-child button? ] filter
    [ children>> first2 control-value result>> env-model eq? >>selected? drop ] each ;

: ?add-result-button ( node-gadget -- gadget )
    dup control-value executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( node-gadget -- gadget )
    dup node-gadget? [ dup control-value error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ] when ;

: ?add-space ( node-gadget -- gadget )
    dup node-gadget?
    [ <shelf> 1/2 >>align { 30 0 } >>gap <shelf> add-gadget swap add-gadget ] when ;

M:: vocab-gadget model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> [ vocab? ] find-parent :> value
    value path vocabs:create-vocab drop
    value parents reverse [ <node-gadget> ?add-space add-gadget ] each
    <space> add-gadget
    <separator> add-gadget
    <space> add-gadget
    value vocabs [ <node-gadget> ?add-space add-gadget ] each
    <new-vocab-button> add-gadget
    value tuple-definitions [ <node-gadget> ?add-space add-gadget ] each
    <new-tuple-button> add-gadget
    value word-definitions [ <node-gadget> ?add-result-button ?add-error-button ?add-space add-gadget ] each
    <new-word-button> add-gadget
    ?select-result-button drop
    value path add-interactive-vocab ;

M:: vocab-gadget layout* ( gadget -- )
    gadget call-next-method
    gadget children>> [ pack? ] any?
    [ gadget children>> [ [ pack? not ] [ [ { 15 0 } v+ ] change-loc drop ] smart-when* ] each ] when ;
