! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart kernel
locals models namespaces sequences skov.code skov.gadgets
skov.gadgets.buttons skov.gadgets.vocab-gadget ui.gadgets
ui.gestures ;
IN: skov.gadgets.plus-button-pile

:: add-to-tuple ( env class -- )
    env [ control-value tuple-definition? ]
    [ [ class add-from-class ] change-control-value ] smart-when* ;

:: add-to-word ( env class -- )
    hand-gadget get-global :> hand
    env [ control-value word-definition? ] [
      [ class add-from-class
        hand connector-gadget?
        [ dup contents>> last 
          hand control-value input? [ output ] [ input ] if add-from-class 
          contents>> last hand control-value ?connect ] when
      ] change-control-value 
    ] smart-when* ;

: plus-buttons-for-word ( -- seq )
    [ "dark" [ find-env definition-input add-to-word ] <plus-button> "Add input ( i )" >>tooltip
      "dark" [ find-env definition-output add-to-word ] <plus-button> "Add output ( o )" >>tooltip
      <space>
      "green" [ find-env word add-to-word ] <plus-button> "Add word ( w )" >>tooltip
      <space>
      "green" [ find-env constructor add-to-word ] <plus-button> "Add constructor ( c )" >>tooltip
      "green" [ find-env accessor add-to-word ] <plus-button> "Add accessor ( a )" >>tooltip
      "green" [ find-env mutator add-to-word ] <plus-button> "Add mutator ( m )" >>tooltip
      "green" [ find-env destructor add-to-word ] <plus-button> "Add destructor ( d )" >>tooltip
      <space>
      "grey" [ find-env text add-to-word ] <plus-button> "Add text ( t )" >>tooltip
    ] output>array ;

: plus-buttons-for-tuple ( -- seq )
    "dark" [ find-env slot add-to-tuple ] <plus-button> "Add slot ( s )" >>tooltip 1array ;

: <plus-button-pile> ( model -- gadget )
    plus-button-pile new vertical >>orientation swap >>model ;

M: plus-button-pile model-changed
    dup clear-gadget swap
    value>> {
      { [ dup tuple-definition? ] [ drop plus-buttons-for-tuple ] }
      { [ dup word-definition? ] [ drop plus-buttons-for-word ] }
      [ drop { } ]
    } cond [ add-gadget ] each drop ;
