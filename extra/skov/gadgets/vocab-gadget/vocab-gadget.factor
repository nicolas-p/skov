! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays combinators.smart kernel locals math
math.order math.vectors namespaces sequences skov.code
skov.execution skov.gadgets skov.gadgets.buttons
skov.gadgets.node-gadget skov.theme ui.gadgets ui.gadgets.icons
ui.gadgets.packs ui.gestures ;
IN: skov.gadgets.vocab-gadget

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 0 25 } ;

: <separator> ( -- img )
    "separator" theme-image <icon> ;

: <new-vocab-button> ( -- button )
    "orange" [ parent>> [ vocab add-element ] change-modell update drop ] <plus-button> 
    "New vocabulary ( v )" >>tooltip ;

: <new-word-button> ( -- button )
    "green" [ parent>> [ word add-element ] change-modell update drop ] <plus-button>
    "New word ( n )" >>tooltip ;

: <new-tuple-button> ( -- button )
    "blue" [ parent>> [ tuplee add-element ] change-modell update drop ] <plus-button>
    "New tuple class ( u )" >>tooltip ;

: associated-word ( button -- word )
    parent>> children>> last ;

: <result-button> ( -- button )
    [ associated-word dup modell>> run-word select-result ] "result" <word-button> 
    "Display result ( backspace )" >>tooltip ;

: <error-button> ( -- button )
    [ drop ] "error" <word-button> 
    "There is an error in this word" >>tooltip ;

:: <vocab-gadget> ( model -- vocab-gadget )
     vocab-gadget new vertical >>orientation model >>modell { 0 5 } >>gap 1/2 >>align ;

:: ?select-result-button ( vocab-gadget -- vocab-gadget )
    vocab-gadget dup [ environment-gadget? ] find-parent modell>> :> env-model
    dup children>> [ pack? ] filter 
    [ children>> first2 modell>> result>> env-model eq? >>selected? drop ] each ;

: ?add-result-button ( node-gadget -- gadget )
    dup modell>> executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( node-gadget -- gadget )
    dup node-gadget? [ dup modell>> error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ] when ;

M: vocab-gadget update
    dup clear-gadget
    dup modell>> parents reverse [ <node-gadget> add-gadget ] each
    <space> add-gadget
    <separator> add-gadget
    <space> add-gadget
    dup modell>> vocabs>> [ <node-gadget> add-gadget ] each
    <new-vocab-button> add-gadget
    <space> add-gadget
    dup modell>> tuples>> [ <node-gadget> add-gadget ] each
    <new-tuple-button> add-gadget
    <space> add-gadget
    dup modell>> words>> [ <node-gadget> ?add-result-button ?add-error-button add-gadget ] each
    <new-word-button> add-gadget ?select-result-button
    dup modell>> name>> add-to-interactive-vocabs ;

: contents-height ( vocab-gadget -- x )
    children>> [ last loc>> second ] [ first loc>> second ] bi - ;

M:: vocab-gadget layout* ( gadget -- )
    gadget call-next-method
    gadget [ contents-height ] [ dim>> second ] bi - 50 + 0 max 
    gadget [ min 0 max ] change-scroll-position drop
    gadget children>> [ [ pack? not ] [ [ { 15 0 } v+ ] change-loc drop ] smart-when* ] each
    gadget children>> [ [ 0 gadget scroll-position>> 2array v- ] change-loc drop ] each ;

M: vocab-gadget pref-dim*
    [ call-next-method ]
    [ children>> dup [ [ pack? ] [ children>> second ] smart-when ] map 
    pref-dims dup supremum swap index swap nth pack? not [ { 20 0 } v+ ] when ] bi ;

: do-mouse-scroll ( vocab-gadget -- )
    [ scroll-direction get-global second 3 * + ] change-scroll-position relayout-1 ;

vocab-gadget H{
    { mouse-scroll [ do-mouse-scroll ] }
} set-gestures
