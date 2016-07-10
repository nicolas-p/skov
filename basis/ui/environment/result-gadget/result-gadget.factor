! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel models code
ui.environment ui.environment.theme strings ui.gadgets ui.gadgets.icons
ui.gadgets.labels ;
IN: ui.environment.result-gadget

: <result-gadget> ( model -- gadget )
     result-gadget new swap >>model ;

M: result-gadget model-changed
    dup clear-gadget swap
    value>> {
      { [ dup result? ] [ contents>> <label> set-light-font add-gadget ] }
      { [ dup vocab? ] [ drop "skov-logo" theme-image <icon> add-gadget ] }
      [ drop ]
    } cond drop ;
