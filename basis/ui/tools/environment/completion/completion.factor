! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.factor-abstraction colors.constants
colors.hex kernel listener locals math.parser models namespaces
sequences splitting ui.tools.environment.common ui.tools.environment.bubble
ui.tools.environment.theme ui.gadgets ui.gadgets.labels
ui.gadgets.packs ui.pens.solid vocabs ;
FROM: code => vocab ;
IN: ui.tools.environment.completion

: <completion> ( model -- completion )
    completion new swap >>model ;

:: word-display ( word -- gadget )
    <shelf> 1/2 >>align
    word vocabulary>> "." split [ vocab new swap >>name <bubble> add-gadget ] each
    word call-from-factor <bubble> add-gadget ;

:: add-selection-arrow ( completion -- completion )
    completion dup children>> [ label? ] reject
    [ dup children>> last control-value target>> completion selected>> eq? 
      [ HEXCOLOR: 586e75 <solid> >>interior ] when drop 
    ] each ;

: ?add-completion-label ( completion -- completion )
    dup control-value
    [ length number>string "Choose one of these " " words:" surround <label> set-light-font add-gadget ]
    unless-empty ;

: redraw-completion ( completion -- completion )
    dup clear-gadget ?add-completion-label dup control-value 
    [ word-display add-gadget ] each add-selection-arrow ;

M: completion model-changed ( model completion -- )
    nip dup control-value [ first >>selected ] unless-empty redraw-completion drop ;
