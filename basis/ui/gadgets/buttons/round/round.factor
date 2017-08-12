! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors kernel locals sequences ui.gadgets
ui.gadgets.buttons ui.pens ui.pens.gradient-rounded
ui.pens.image ui.theme ui.tools.environment.theme ;
IN: ui.gadgets.buttons.round

TUPLE: round-button < button ;

M: round-button pref-dim*
    dup interior>> pen-pref-dim dup { 0 0 } = [ drop { 20 20 } ] when ;

:: <round-button> ( colors label quot -- button )
    label quot round-button new-button
    colors dup dark-background = [ light-text-colour ] [ dark-text-colour ] if
    <gradient-rounded> >>interior
    dup gadget-child
    [ t >>bold? 13 >>size
      transparent >>background ] change-font drop ;

:: <word-button-pen> ( str -- pen )
    str "button" 2-theme-image-pen dup
    "pressed" "button" 2-theme-image-pen dup
    str "-selected" append "button" 2-theme-image-pen swap <button-pen> ;

: <word-button> ( quot str -- button )
    [ "" swap round-button new-button ] dip <word-button-pen> >>interior ;
