! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart kernel
listener locals math memory models namespaces sequences
skov.code skov.execution skov.gadgets skov.import-export skov.gadgets.buttons
skov.gadgets.connection-gadget skov.gadgets.connector-gadget
skov.gadgets.graph-gadget skov.gadgets.node-pile
skov.gadgets.plus-button-pile skov.gadgets.result-gadget
skov.gadgets.vocab-gadget skov.theme skov.utilities ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.packs ui.gadgets.tracks ui.gestures ui.tools.browser
ui.tools.common vocabs.parser ui.gadgets.scrollers ;
IN: skov.gadgets.environment-gadget

{ 700 600 } environment-gadget set-tool-dim

: <help-button> ( -- button )
    [ drop show-browser ] "help" <word-button> "Help ( h )" >>tooltip ;

:: <environment-gadget> ( -- gadget )
    skov-root get-global <model> :> model
    horizontal environment-gadget new-track model >>model
    vertical <track>
      <help-button> f track-add
      model <plus-button-pile> { 0 0 } <border> 1 track-add
    { 10 10 } <filled-border>
    f track-add
    <shelf> 1/2 >>align { 40 0 } >>gap
      model <node-pile> add-gadget
      model <result-gadget> add-gadget
      model <graph-gadget> add-gadget
    { 10 10 } <border> <scroller> 1 track-add
    model <vocab-gadget> { 10 10 } <filled-border> <scroller> f track-add
    with-background ;

: make-keyboard-safe ( env quot -- )
    [ world-focus editor? not ] swap smart-when* ; inline

: add-input ( env -- ) [ introduce add-to-word ] make-keyboard-safe ;
: add-output ( env -- ) [ return add-to-word ] make-keyboard-safe ;
: add-text ( env -- ) [ text add-to-word ] make-keyboard-safe ;
: add-slot ( env -- ) [ slot add-to-tuple ] make-keyboard-safe ;
: add-constructor ( env -- ) [ constructor add-to-word ] make-keyboard-safe ;
: add-destructor ( env -- ) [ destructor add-to-word ] make-keyboard-safe ;
: add-accessor ( env -- ) [ accessor add-to-word ] make-keyboard-safe ;
: add-mutator ( env -- ) [ mutator add-to-word ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-word ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word-in-vocab ( env -- ) [ word-definition add-to-vocab ] make-keyboard-safe ;
: add-tuple-in-vocab ( env -- ) [ tuple-definition add-to-vocab ] make-keyboard-safe ;

: disconnect-connector-gadget ( env -- )
    [ hand-gadget get-global dup
      [ [ connector-gadget? ] [ connected? ] bi and ] [ control-value disconnect ] smart-when*
      find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: remove-node-gadget ( env -- )
    [ hand-gadget get-global find-node dup
      [ [ outputs>> [ links>> [ control-value disconnect ] each ] each ]
        [ control-value remove-from-parent ] bi
      ] when* find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: edit-node-gadget ( env -- )
    [ hand-gadget get-global find-node
      [ f >>name request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value variadic? ]
        [ dup control-value input add-from-class inputs>> last
          <connector-gadget> add-gadget drop
        ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value [ variadic? ] [ inputs>> length 2 > ] bi and ]
        [ dup control-value [ but-last ] change-contents drop inputs>> last unparent ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: toggle-result ( env -- )
    [ dup control-value {
        { [ dup word-definition? ] [ dup run-word result>> swap set-control-value ] }
        { [ dup result? ] [ parent>> swap set-control-value ] }
        [ drop drop ]
      } cond 
    ] make-keyboard-safe ;

:: next-nth-word ( env n -- )
    env [ dup control-value definition? [
      [ vocab-control-value [ tuples>> ] [ words>> ] bi append ]
      [ control-value n next-nth ] [ dupd set-control-value ] tri
    ] when drop ] make-keyboard-safe ;

: previous-word ( env -- )  -1 next-nth-word ;
: next-word ( env -- )  +1 next-nth-word ;

: save-skov-image ( env -- )
    [ drop save export-vocabs ] make-keyboard-safe ;

: load-vocabs ( env -- )
    [ update-skov-root skov-root get-global swap set-control-value ] make-keyboard-safe ;

: show-help ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value factor-name search (browser-window) ] with-interactive-vocabs ]
      [ show-browser ] if* drop
    ] make-keyboard-safe ;

environment-gadget "general" f {
    { T{ key-up f f "w" } add-word }
    { T{ key-up f f "W" } add-word }
    { T{ key-up f f "i" } add-input }
    { T{ key-up f f "I" } add-input }
    { T{ key-up f f "o" } add-output }
    { T{ key-up f f "O" } add-output }
    { T{ key-up f f "t" } add-text }
    { T{ key-up f f "T" } add-text }
    { T{ key-up f f "s" } add-slot }
    { T{ key-up f f "S" } add-slot }
    { T{ key-up f f "c" } add-constructor }
    { T{ key-up f f "C" } add-constructor }
    { T{ key-up f f "d" } add-destructor }
    { T{ key-up f f "D" } add-destructor }
    { T{ key-up f f "a" } add-accessor }
    { T{ key-up f f "A" } add-accessor }
    { T{ key-up f f "m" } add-mutator }
    { T{ key-up f f "M" } add-mutator }
    { T{ key-up f f "v" } add-vocab }
    { T{ key-up f f "V" } add-vocab }
    { T{ key-up f f "n" } add-word-in-vocab }
    { T{ key-up f f "N" } add-word-in-vocab }
    { T{ key-up f f "u" } add-tuple-in-vocab }
    { T{ key-up f f "U" } add-tuple-in-vocab }
    { T{ key-up f f "x" } disconnect-connector-gadget }
    { T{ key-up f f "X" } disconnect-connector-gadget }
    { T{ key-up f f "r" } remove-node-gadget }
    { T{ key-up f f "R" } remove-node-gadget }
    { T{ key-up f f "e" } edit-node-gadget }
    { T{ key-up f f "E" } edit-node-gadget }
    { T{ key-up f f "RIGHT" } more-inputs }
    { T{ key-up f f "LEFT" } less-inputs }
    { T{ key-down f { C+ } "s" } save-skov-image }
    { T{ key-down f { C+ } "S" } save-skov-image }
    { T{ key-down f { C+ } "l" } load-vocabs }
    { T{ key-down f { C+ } "L" } load-vocabs }
    { T{ key-up f f "h" } show-help }
    { T{ key-up f f "H" } show-help }
    { T{ key-up f f "BACKSPACE" } toggle-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
} define-command-map
