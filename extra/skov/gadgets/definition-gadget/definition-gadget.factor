! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays assocs combinators
combinators.smart kernel locals math math.vectors sequences skov.animation
skov.code skov.execution skov.gadgets skov.gadgets.connection-gadget
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

: centre ( def -- xy )
    dim>> [ 2 / >integer ] map ;

: centre-graph ( def -- )
    [ centre ] [ nodes>> [ dupd [ pos>> v+ ] [ loc<< ] bi ] each drop ] bi ;

M: definition-gadget layout*
   [ [ dup pref-dim swap dim<< ] each-child ]
   [ centre-graph ]
   [ [ contains-only-icon-or-text? ] [ call-next-method ] smart-when* ] tri ;

: add-nodes ( def -- def )
    dup modell>> contents>> [ <node-gadget> add-gadget ] each ;

: add-connections ( def -- def )
    dup children>>
    [ inputs>>
      [ modell>> connected? ] filter
      [ dup link 2dup connect <connection-gadget> ] map
    ] map concat [ add-gadget ] each ;

: add-slots ( def -- def )
    dup modell>> contents>> [ <node-gadget> add-gadget ] each ;

M: definition-gadget update
    dup clear-gadget
    dup modell>>
    { { [ dup word? ] [ eval-word add-nodes add-connections place-nodes place-unconnected-nodes ] }
      { [ dup tuplee? ] [ eval-tuple add-slots place-unconnected-nodes ] }
      { [ dup string? ] [ <label> set-light-font add-gadget ] }
      [ drop "skov-logo" theme-image <icon> add-gadget ]
    } cond ;
