! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors arrays combinators.smart kernel locals math
math.order math.vectors models namespaces sequences skov.code
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
    "orange" [ parent>> [ vocab add-element ] change-vocab-control-value ] <plus-button> 
    "New vocabulary ( v )" >>tooltip ;

: <new-word-button> ( -- button )
    "green" [ parent>> [ word add-element ] change-vocab-control-value ] <plus-button>
    "New word ( n )" >>tooltip ;

: <new-tuple-button> ( -- button )
    "blue" [ parent>> [ tuple-class add-element ] change-vocab-control-value ] <plus-button>
    "New tuple class ( u )" >>tooltip ;

: associated-word ( button -- word )
    parent>> children>> last ;

: <result-button> ( -- button )
    [ associated-word dup control-value run-word select-result ] "result" <word-button> 
    "Display result ( backspace )" >>tooltip ;

: <error-button> ( -- button )
    [ drop ] "error" <word-button> 
    "There is an error in this word" >>tooltip ;

: <vocab-gadget> ( model -- vocab-gadget )
     vocab-gadget new swap >>model vertical >>orientation { 0 5 } >>gap 1/2 >>align ;

:: ?select-result-button ( vocab-gadget -- vocab-gadget )
    vocab-gadget dup find-env control-value :> env-model
    dup children>> [ pack? ] filter 
    [ children>> first2 control-value result>> env-model eq? >>selected? drop ] each ;

: ?add-result-button ( node-gadget -- gadget )
    dup control-value executable? 
    [ <shelf> 1/2 >>align <result-button> add-gadget swap add-gadget ] when ;

: ?add-error-button ( node-gadget -- gadget )
    dup node-gadget? [ dup control-value error? 
    [ <shelf> 1/2 >>align <error-button> add-gadget swap add-gadget ] when ] when ;

M:: vocab-gadget model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> [ vocab? ] find-parent :> value
    value parents reverse [ <node-gadget> add-gadget ] each
    <space> add-gadget
    <separator> add-gadget
    <space> add-gadget
    value vocabs>> [ <node-gadget> add-gadget ] each
    <new-vocab-button> add-gadget
    value tuples>> [ <node-gadget> add-gadget ] each
    <new-tuple-button> add-gadget
    value words>> [ <node-gadget> ?add-result-button ?add-error-button add-gadget ] each
    <new-word-button> add-gadget
    ?select-result-button drop
    value name>> add-to-interactive-vocabs ;

: contents-height ( vocab-gadget -- x )
    children>> [ last loc>> second ] [ first loc>> second ] bi - ;

M:: vocab-gadget layout* ( gadget -- )
    gadget call-next-method
    gadget [ contents-height ] [ dim>> second ] bi - 50 + 0 max 
    gadget [ min 0 max ] change-scroll-position drop
    gadget children>> [ pack? ] any?
    [ gadget children>> [ [ pack? not ] [ [ { 15 0 } v+ ] change-loc drop ] smart-when* ] each ] when
    gadget children>> [ [ 0 gadget scroll-position>> 2array v- ] change-loc drop ] each ;

: do-mouse-scroll ( vocab-gadget -- )
    [ scroll-direction get-global second 3 * + ] change-scroll-position relayout-1 ;

vocab-gadget H{
    { mouse-scroll [ do-mouse-scroll ] }
} set-gestures
