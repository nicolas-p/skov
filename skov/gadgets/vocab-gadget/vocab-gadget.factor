! Copyright (C) 2015 Nicolas Pénet.
USING: accessors combinators.smart kernel locals math.vectors
sequences skov.code skov.execution skov.gadgets
skov.gadgets.buttons skov.gadgets.node-gadget ui.gadgets
ui.gadgets.packs ;
IN: skov.gadgets.vocab-gadget

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 0 25 } ;

: <new-vocab-button> ( -- button )
    vocab [ parent>> [ vocab add ] change-modell update drop ] <plus-button> 
    "New vocabulary ( v )" >>tooltip ;

: <new-word-button> ( -- button )
    word [ parent>> [ word add ] change-modell update drop ] <plus-button>
    "New word in vocabulary ( n )" >>tooltip ;

: associated-word ( button -- word )
    parent>> children>> last ;

: <result-button> ( -- button )
    [ associated-word dup modell>> run-word select-result ] "result" <word-button> 
    "Display result ( backspace )" >>tooltip ;

:: <vocab-gadget> ( model -- vocab-gadget )
     vocab-gadget new vertical >>orientation model >>modell { 0 5 } >>gap 1/2 >>align ;

:: ?select-result-button ( vocab-gadget -- vocab-gadget )
    vocab-gadget dup [ environment-gadget? ] find-parent modell>> :> env-model
    dup children>> [ pack? ] filter 
    [ children>> first2 modell>> result>> env-model eq? >>selected? drop ] each ;

: ?add-result-button ( node-gadget -- gadget )
    dup modell>> executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

M: vocab-gadget update
    dup clear-gadget
    dup modell>> parents reverse [ <node-gadget> add-gadget ] each
    <space> add-gadget
    dup modell>> vocabs>> [ <node-gadget> add-gadget ] each
    <new-vocab-button> add-gadget
    <space> add-gadget
    dup modell>> words>> [ dup eval-word <node-gadget> ?add-result-button add-gadget ] each
    <new-word-button> add-gadget ?select-result-button
    dup modell>> name>> add-to-interactive-vocabs ;

M: vocab-gadget layout*
    dup call-next-method 
    children>> [ [ pack? not ] [ [ { 15 0 } v+ ] change-loc drop ] smart-when* ] each ;

M: vocab-gadget pref-dim*
    [ call-next-method ]
    [ children>> dup [ [ pack? ] [ children>> second ] smart-when ] map 
    pref-dims dup supremum swap index swap nth pack? not [ { 20 0 } v+ ] when ] bi ;
