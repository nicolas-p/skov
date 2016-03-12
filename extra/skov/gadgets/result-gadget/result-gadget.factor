! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors combinators kernel models skov.code
skov.gadgets skov.theme strings ui.gadgets ui.gadgets.icons
ui.gadgets.labels ;
IN: skov.gadgets.result-gadget

: <result-gadget> ( model -- gadget )
     result-gadget new swap >>model ;

M: result-gadget model-changed
    dup clear-gadget swap
    value>> {
      { [ dup result? ] [ contents>> <label> set-light-font add-gadget ] }
      { [ dup vocab? ] [ drop "skov-logo" theme-image <icon> add-gadget ] }
      [ drop ]
    } cond drop ;
