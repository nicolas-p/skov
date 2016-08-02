! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators combinators.smart kernel
models sequences strings ui.environment ui.environment.theme
ui.gadgets ui.gadgets.icons ui.gadgets.labels ;
IN: ui.environment.result-gadget

: <result-gadget> ( model -- gadget )
     result-gadget new swap >>model ;

: set-children-font ( gadget -- )
    children>> [ [ label? ] [ set-light-font drop ] [ set-children-font ] smart-if ] each ;

M: result-gadget model-changed
    dup clear-gadget swap
    value>> {
      { [ dup result? ] [ contents>> dup set-children-font add-gadget ] }
      { [ dup vocab? ] [ drop "skov-logo" theme-image <icon> add-gadget ] }
      [ drop ]
    } cond drop ;
