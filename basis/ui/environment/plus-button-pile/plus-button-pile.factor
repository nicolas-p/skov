! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart kernel
locals models namespaces sequences code ui.environment
ui.gadgets.buttons.round ui.environment.vocab-gadget ui.gadgets
ui.gestures ;
IN: ui.environment.plus-button-pile

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
    [ "dark" [ find-env introduce add-to-word ] <plus-button> "Add input     ( I )" >>tooltip
      "dark" [ find-env return add-to-word ] <plus-button> "Add output     ( O )" >>tooltip
      <space>
      "green" [ find-env word add-to-word ] <plus-button> "Add word     ( W )" >>tooltip
      <space>
      "green" [ find-env constructor add-to-word ] <plus-button> "Add constructor     ( C )" >>tooltip
      "green" [ find-env accessor add-to-word ] <plus-button> "Add accessor     ( A )" >>tooltip
      "green" [ find-env mutator add-to-word ] <plus-button> "Add mutator     ( M )" >>tooltip
      "green" [ find-env destructor add-to-word ] <plus-button> "Add destructor     ( D )" >>tooltip
      <space>
      "grey" [ find-env text add-to-word ] <plus-button> "Add text     ( T )" >>tooltip
    ] output>array ;

: plus-buttons-for-tuple ( -- seq )
    "blue" [ find-env slot add-to-tuple ] <plus-button> "Add slot     ( S )" >>tooltip 1array ;

: <plus-button-pile> ( model -- gadget )
    plus-button-pile new vertical >>orientation swap >>model ;

M: plus-button-pile model-changed
    dup clear-gadget swap
    value>> {
      { [ dup tuple-definition? ] [ drop plus-buttons-for-tuple ] }
      { [ dup word-definition? ] [ drop plus-buttons-for-word ] }
      [ drop { } ]
    } cond [ add-gadget ] each drop ;
