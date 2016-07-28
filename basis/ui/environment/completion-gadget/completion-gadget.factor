! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code colors.constants kernel listener locals
models namespaces sequences splitting ui.environment
ui.environment.node-gadget ui.gadgets ui.gadgets.packs
ui.pens.solid vocabs ;
FROM: code => word vocab ;
IN: ui.environment.completion-gadget

TUPLE: completion-gadget < pack ;

: <completion-gadget> ( model -- completion-gadget )
    completion-gadget new swap >>model COLOR: FactorDarkSlateBlue <solid> >>interior ;

:: matching-words* ( str -- seq )
    interactive-vocabs get [ vocab-words ] map concat [ name>> str head? ] filter ;

: matching-words ( str -- seq )
    [ f ] [ matching-words* ] if-empty ;

:: word-display ( wrd -- gadget )
    <shelf> 
    wrd vocabulary>> "." split [ vocab new <node-gadget> swap >>name add-gadget ] each
    word new vocab new >>parent <node-gadget> wrd name>> >>name add-gadget  ;

M:: completion-gadget model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> matching-words
    [ word-display add-gadget ] each drop ;
