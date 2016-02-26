! Copyright (C) 2015 Nicolas Pénet.
USING: accessors combinators combinators.smart kernel listener
locals math memory namespaces sequences skov.code skov.execution
skov.gadgets skov.gadgets.buttons skov.gadgets.connector-gadget
skov.gadgets.definition-gadget skov.gadgets.vocab-gadget
skov.theme skov.utilities ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.editors ui.gadgets.packs
ui.gadgets.tracks ui.gestures ui.tools.browser ui.tools.common
vocabs.parser ;
IN: skov.gadgets.environment-gadget

M: environment-gadget definition>>  children>> [ definition-gadget? ] filter first ;
M: environment-gadget vocab>>  children>> [ vocab-gadget? ] filter first ;

{ 700 600 } environment-gadget set-tool-dim

: word-or-tuple? ( obj -- ? )  [ word? ] [ tuplee? ] bi or ;

:: add-to-tuple ( env class -- )
    env dup definition>> modell>> tuple? 
    [ [ class add-element ] change-modell update ] when drop ;

:: add-to-word ( env class -- )
    env dup definition>> modell>> word? 
    [ [ class add-element ] change-modell update ] when drop ;

:: add-to-vocab ( env class -- )
    env vocab>> [ class add-element ] change-modell update drop ;

: <plus-button-bar> ( -- pile )
    vertical <track>
    <pile> 1 track-add
    "dark" [ parent>> parent>> input add-to-word ]
    <plus-button> "Add input ( i )" >>tooltip f track-add
    "dark" [ parent>> parent>> output add-to-word ]
    <plus-button> "Add output ( o )" >>tooltip f track-add
    "green" [ parent>> parent>> word add-to-word ]
    <plus-button> "Add word ( w )" >>tooltip f track-add
    "green" [ parent>> parent>> constructor add-to-word ]
    <plus-button> "Add constructor ( c )" >>tooltip f track-add
    "green" [ parent>> parent>> accessor add-to-word ]
    <plus-button> "Add accessor ( a )" >>tooltip f track-add
    "green" [ parent>> parent>> mutator add-to-word ]
    <plus-button> "Add mutator ( m )" >>tooltip f track-add
    "green" [ parent>> parent>> destructor add-to-word ]
    <plus-button> "Add destructor ( d )" >>tooltip f track-add
    "grey" [ parent>> parent>> text add-to-word ]
    <plus-button> "Add text ( t )" >>tooltip f track-add
    <pile> 1 track-add ;

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

: <environment-gadget> ( -- gadget )
     horizontal environment-gadget new-track
     skov-root get-global >>modell
     <plus-button-bar> f track-add
     f <definition-gadget> 1 track-add
     skov-root get-global <vocab-gadget> f track-add
     update
     { 10 10 } <filled-border> with-background ;

M: environment-gadget update
    { [ definition>> ] [ modell>> >>modell update drop ]
      [ vocab>> ] [ modell>> [ vocab? ] [ >>modell ] smart-when* update drop ] 
      [ ] } cleave ;

: make-keyboard-safe ( env quot -- )
    [ world-focus editor? not ] swap smart-when* ; inline

: add-input ( env -- ) [ input add-to-word ] make-keyboard-safe ;
: add-output ( env -- ) [ output add-to-word ] make-keyboard-safe ;
: add-text ( env -- ) [ text add-to-word ] make-keyboard-safe ;
: add-slot ( env -- ) [ slot add-to-tuple ] make-keyboard-safe ;
: add-constructor ( env -- ) [ constructor add-to-word ] make-keyboard-safe ;
: add-destructor ( env -- ) [ destructor add-to-word ] make-keyboard-safe ;
: add-accessor ( env -- ) [ accessor add-to-word ] make-keyboard-safe ;
: add-mutator ( env -- ) [ mutator add-to-word ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-word ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word-in-vocab ( env -- ) [ word add-to-vocab ] make-keyboard-safe ;
: add-tuple-in-vocab ( env -- ) [ tuplee add-to-vocab ] make-keyboard-safe ;

: disconnect-connector-gadget ( env -- )
    [ hand-gadget get-global [ connector-gadget? ]
      [ modell>> disconnect ] smart-when* update drop
    ] make-keyboard-safe ;

: remove-node-gadget ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ outputs>> [ links>> [ modell>> disconnect ] each ] each ]
        [ modell>> remove-from-parent ] bi
      ] when* update drop
    ] make-keyboard-safe ;

: edit-node-gadget ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ dup in-vocab? [ f >>name ] when request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ modell>> variadic? ]
        [ dup modell>> input add-element inputs>> last <connector-gadget> add-gadget drop ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ modell>> [ variadic? ] [ inputs>> length 2 > ] bi and ]
        [ dup modell>> [ but-last ] change-contents drop inputs>> last unparent ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: show-result ( env -- )
    [ dup definition>> modell>> [ word? ] [ dup run-word result>> >>modell update ] smart-when* drop ]
    make-keyboard-safe ;

:: next-nth-word ( env n -- )
    env [ dup modell>> word-or-tuple? [
      [ vocab>> modell>> [ tuples>> ] [ words>> ] bi append ]
      [ modell>> n next-nth ] [ swap >>modell update ] tri
    ] when drop ] make-keyboard-safe ;

: previous-word ( env -- )  -1 next-nth-word ;
: next-word ( env -- )  +1 next-nth-word ;

: save-skov-image ( env -- )
    [ drop save ] make-keyboard-safe ;

: show-help ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ modell>> factor-name search (browser-window) ] with-interactive-vocabs ]
      [ show-browser ] if* drop
    ] make-keyboard-safe ;

environment-gadget "general" f {
    { T{ key-up f f "w" } add-word }
    { T{ key-up f f "i" } add-input }
    { T{ key-up f f "o" } add-output }
    { T{ key-up f f "t" } add-text }
    { T{ key-up f f "s" } add-slot }
    { T{ key-up f f "c" } add-constructor }
    { T{ key-up f f "d" } add-destructor }
    { T{ key-up f f "a" } add-accessor }
    { T{ key-up f f "m" } add-mutator }
    { T{ key-up f f "v" } add-vocab }
    { T{ key-up f f "n" } add-word-in-vocab }
    { T{ key-up f f "u" } add-tuple-in-vocab }
    { T{ key-up f f "x" } disconnect-connector-gadget }
    { T{ key-up f f "r" } remove-node-gadget }
    { T{ key-up f f "e" } edit-node-gadget }
    { T{ key-up f f "RIGHT" } more-inputs }
    { T{ key-up f f "LEFT" } less-inputs }
    { T{ key-up f { A+ } "s" } save-skov-image }
    { T{ key-up f f "h" } show-help }
    { T{ key-up f f "BACKSPACE" } show-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
} define-command-map
