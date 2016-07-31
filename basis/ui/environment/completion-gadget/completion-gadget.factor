! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.factor-abstraction colors.constants
colors.hex kernel listener locals models namespaces sequences
splitting ui.environment ui.environment.node-gadget ui.gadgets
ui.gadgets.packs ui.pens.solid vocabs ;
FROM: code => word vocab ;
IN: ui.environment.completion-gadget

: <completion-gadget> ( model -- completion-gadget )
    completion-gadget new swap >>model ;

:: matching-words* ( str -- seq )
    interactive-vocabs get [ vocab-words ] map concat [ name>> str head? ] filter ;

: matching-words ( str -- seq )
    [ f ] [ matching-words* ] if-empty ;

:: word-display ( wrd -- gadget )
    <shelf> 1/2 >>align
    wrd vocabulary>> "." split [ vocab new swap >>name <node-gadget> add-gadget ] each
    wrd word-from-factor <node-gadget> add-gadget ;

:: add-selection-arrow ( completion-gadget -- completion-gadget )
    completion-gadget dup children>> 
    [ dup children>> last control-value target>> completion-gadget selected>> eq? 
      [ HEXCOLOR: 586e75 <solid> >>interior ] when drop 
    ] each ;

: redraw-completion ( completion-gadget -- completion-gadget )
    dup clear-gadget dup control-value [ word-display add-gadget ] each add-selection-arrow ;

M: completion-gadget model-changed ( model completion-gadget -- )
    nip dup control-value [ first >>selected ] unless-empty redraw-completion drop ;

: reset-completion ( completion-gadget -- )
    f >>selected f swap set-control-value ;
