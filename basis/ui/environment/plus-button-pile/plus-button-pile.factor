! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart kernel
locals models namespaces sequences code ui.environment
ui.gadgets.buttons.round ui.environment.vocab-gadget ui.gadgets
ui.gestures ui.environment.actions ;
FROM: code => call ;
IN: ui.environment.plus-button-pile

: plus-buttons-for-word ( -- seq )
    [ "dark" [ find-env introduce add-to-word ] <plus-button> "Add input     ( I )" >>tooltip
      "dark" [ find-env return add-to-word ] <plus-button> "Add output     ( O )" >>tooltip
      <space>
      "green" [ find-env call add-to-word ] <plus-button> "Add call     ( W )" >>tooltip
      <space>
      "green" [ find-env constructor add-to-word ] <plus-button> "Add constructor     ( C )" >>tooltip
      "green" [ find-env accessor add-to-word ] <plus-button> "Add accessor     ( A )" >>tooltip
      "green" [ find-env mutator add-to-word ] <plus-button> "Add mutator     ( M )" >>tooltip
      "green" [ find-env destructor add-to-word ] <plus-button> "Add destructor     ( D )" >>tooltip
      <space>
      "grey" [ find-env text add-to-word ] <plus-button> "Add text     ( T )" >>tooltip
    ] output>array ;

: plus-buttons-for-tuple ( -- seq )
    "blue" [ find-env slot add-to-class ] <plus-button> "Add slot     ( S )" >>tooltip 1array ;

: import-export-buttons ( -- seq )
    [ [ find-env save-skov-image ] "save" <word-button>
      "Save the image and export all the code to the \"work\" folder    ( Control + S )" >>tooltip
      [ find-env load-vocabs ] "load" <word-button>
      "Load all the code from the \"work\" folder     ( Control + L )" >>tooltip
    ] output>array ;

: <plus-button-pile> ( model -- gadget )
    plus-button-pile new vertical >>orientation swap >>model ;

M: plus-button-pile model-changed
    dup clear-gadget swap
    value>> {
      { [ dup class? ] [ drop plus-buttons-for-tuple ] }
      { [ dup word? ] [ drop plus-buttons-for-word ] }
      [ drop import-export-buttons ]
    } cond [ add-gadget ] each drop ;
