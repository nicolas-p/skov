! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays assocs combinators
combinators.smart kernel locals math sequences skov.animation
skov.code skov.gadgets skov.gadgets.connection-gadget
skov.gadgets.connector-gadget skov.gadgets.node-gadget
skov.theme strings ui.gadgets ui.gadgets.icons
ui.gadgets.labels ;
IN: skov.gadgets.definition-gadget

:: <definition-gadget> ( model -- definition-gadget )
    definition-gadget new model >>modell ;

M: definition-gadget pref-dim*
     [ children>> length 1 = ] [ call-next-method ] [ dim>> ] smart-if ;

: contains-only-icon-or-text? ( def -- ? )
    children>> [ empty? not ] [ first node-gadget? not ] smart-when ;

M: definition-gadget layout*
   [ [ dup pref-dim swap dim<< ] each-child ]
   [ [ contains-only-icon-or-text? ] [ call-next-method ] smart-when* ] bi ;

: add-nodes ( def -- def )
    dup modell>> contents>> [ <node-gadget> dupd swap centre >>loc add-gadget ] each ;

: add-connections ( def -- def )
    dup children>>
    [ inputs>>
      [ modell>> connected? ] filter
      [ dup link 2dup connect <connection-gadget> ] map
    ] map concat [ add-gadget ] each ;

M: definition-gadget update
    dup clear-gadget
    dup modell>>
    { { [ dup word? ] [ drop add-nodes add-connections place-unconnected-nodes place-nodes ] }
      { [ dup string? ] [ <label> set-light-font add-gadget ] }
      [ drop "skov-logo" theme-image <icon> add-gadget ]
    } cond ;
