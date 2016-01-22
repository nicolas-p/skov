! Copyright (C) 2015 Nicolas Pénet.
USING: accessors kernel locals sequences skov.theme
skov.utilities ui.gadgets ui.gadgets.buttons ui.pens
ui.pens.image ;
IN: skov.gadgets.buttons

TUPLE: round-button < button ;

M: round-button pref-dim*
    dup interior>> pen-pref-dim ;

: <round-button> ( quot -- button )
    "" swap round-button new-button ;

: <plus-button-pen> ( str -- pen )
    "plus-button" 2-theme-image <image-pen> dup
    "pressed" "button" 2-theme-image <image-pen> dup dup <button-pen> ;

: <plus-button> ( str quot -- button )
    <round-button> swap <plus-button-pen> >>interior ;

:: <word-button-pen> ( str -- pen )
    str "button" 2-theme-image <image-pen> dup
    "pressed" "button" 2-theme-image <image-pen> dup
    str "-selected" append "button" 2-theme-image <image-pen> swap <button-pen> ;

: <word-button> ( quot str -- button )
    [ <round-button> ] dip <word-button-pen> >>interior ;
