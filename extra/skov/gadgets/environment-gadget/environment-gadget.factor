! Copyright (C) 2015 Nicolas Pénet.
USING: accessors combinators combinators.smart kernel locals
math namespaces sequences skov.code skov.execution skov.gadgets
skov.gadgets.buttons skov.gadgets.connector-gadget
skov.gadgets.definition-gadget skov.gadgets.vocab-gadget
skov.theme skov.utilities ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.editors ui.gadgets.packs
ui.gadgets.tracks ui.gestures ui.tools.common ;
IN: skov.gadgets.environment-gadget

M: environment-gadget definition>>  children>> [ definition-gadget? ] filter first ;
M: environment-gadget vocab>>  children>> [ vocab-gadget? ] filter first ;

{ 700 600 } environment-gadget set-tool-dim

:: add-to-definition ( env class -- )
    env definition>> dup modell>> word? [ [ class add ] change-modell update ] when drop ;

:: add-to-vocab ( env class -- )
    env vocab>> [ class add ] change-modell update drop ;

: <plus-button-bar> ( -- pile )
    vertical <track>
    <pile> 1 track-add
    "dark" [ parent>> parent>> input add-to-definition ] <plus-button>
    "Add input ( i )" >>tooltip f track-add
    <pile> 1/3 track-add
    "green" [ parent>> parent>> word add-to-definition ] <plus-button>
    "Add word ( w )" >>tooltip f track-add
    <pile> 1/3 track-add
    "dark" [ parent>> parent>> output add-to-definition ] <plus-button>
    "Add output ( o )" >>tooltip f track-add
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

: add-input ( env -- ) [ input add-to-definition ] make-keyboard-safe ;
: add-output ( env -- ) [ output add-to-definition ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-definition ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word-in-vocab ( env -- ) [ word add-to-vocab ] make-keyboard-safe ;

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
      [ f >>name request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ modell>> variadic? ]
        [ dup modell>> input add inputs>> last <connector-gadget> add-gadget drop ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ hand-gadget get-global [ node-gadget? ] find-parent
      [ [ modell>> [ variadic? ] [ inputs>> length 2 > ] bi and ]
        [ dup modell>> [ but-last ] change-contents drop inputs>> last unparent ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: show-result ( env -- )
    [ dup definition>> modell>> dup run-word result>> >>modell update drop ] make-keyboard-safe ;

:: next-nth-word ( env n -- )
    env [ dup modell>> word? [ 
      [ vocab>> modell>> words>> ] [ modell>> n next-nth ] [ swap >>modell update ] tri
    ] when drop ] make-keyboard-safe ;

: previous-word ( env -- )  -1 next-nth-word ;
: next-word ( env -- )  +1 next-nth-word ;

environment-gadget "general" f {
    { T{ key-up f f "w" } add-word }
    { T{ key-up f f "i" } add-input }
    { T{ key-up f f "o" } add-output }
    { T{ key-up f f "v" } add-vocab }
    { T{ key-up f f "n" } add-word-in-vocab }
    { T{ key-up f f "d" } disconnect-connector-gadget }
    { T{ key-up f f "r" } remove-node-gadget }
    { T{ key-up f f "e" } edit-node-gadget }
    { T{ key-up f f "m" } more-inputs }
    { T{ key-up f f "l" } less-inputs }
    { T{ key-up f f "BACKSPACE" } show-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
} define-command-map
