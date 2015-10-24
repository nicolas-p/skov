! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart kernel
locals sequences skov.animation skov.code skov.gadgets
skov.gadgets.connection-gadget skov.gadgets.connector-gadget
skov.gadgets.node-gadget skov.theme strings ui.gadgets
ui.gadgets.icons ui.gadgets.labels ;
IN: skov.gadgets.definition-gadget

:: <definition-gadget> ( model -- definition-gadget )
    definition-gadget new model >>modell ;

M: definition-gadget pref-dim*
     [ children>> length 1 = ] [ call-next-method ] [ dim>> ] smart-if ;

M: definition-gadget layout*
   [ [ dup pref-dim swap dim<< ] each-child ]
   [ [ children>> length 1 = ] [ call-next-method ] smart-when* ] bi ;

: add-connections ( definition-gadget -- )
    dup children>>
    [ inputs>>
      [ modell>> connected? ] filter
      [ dup link 2dup connect <connection-gadget> ] map
    ] map concat [ add-gadget ] each drop ;

M: definition-gadget update
    dup clear-gadget
    dup modell>>
    { { [ dup word? ] [ contents>> [ <node-gadget> dupd swap centre 2array >>loc add-gadget ] each
                        dup add-connections dup place-nodes ] }
      { [ dup string? ] [ <label> set-light-font add-gadget ] }
      [ drop "skov-logo" theme-image <icon> add-gadget ]
    } cond dup relayout-1 ;
