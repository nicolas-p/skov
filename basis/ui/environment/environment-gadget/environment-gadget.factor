! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.execution code.import-export
combinators combinators.smart kernel listener locals math
math.order memory models namespaces sequences ui ui.commands
ui.environment ui.environment.completion-gadget
ui.environment.connection-gadget ui.environment.connector-gadget
ui.environment.graph-gadget ui.environment.node-pile
ui.environment.plus-button-pile ui.environment.result-gadget
ui.environment.node-gadget
ui.environment.theme ui.environment.vocab-gadget ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.round ui.gadgets.editors
ui.gadgets.packs ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.tracks ui.gadgets.worlds ui.gestures ui.tools.browser
ui.tools.common vocabs.parser ;
FROM: code => inputs outputs call ;
IN: ui.environment.environment-gadget

environment-gadget { 700 600 } set-tool-dim

: <help-button> ( -- button )
    [ drop show-browser ] "help" <word-button> "Help     ( H )" >>tooltip ;

:: <environment-gadget> ( -- gadget )
    skov-root get-global <model> :> model
    horizontal environment-gadget new-track model >>model
    vertical <track>
        <help-button> f track-add
        model <plus-button-pile> { 0 0 } <border> 1 track-add
    { 10 10 } <filled-border>
    f track-add
    vertical <track>
        <shelf> 1/2 >>align { 40 0 } >>gap
            model <node-pile> add-gadget
            model <result-gadget> add-gadget
            model <graph-gadget> add-gadget 
            { 10 10 } <border> <scroller> 1 track-add
        f <model> <completion-gadget> f track-add
    1 track-add
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
: add-call ( env -- ) [ call add-to-word ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-vocab ] make-keyboard-safe ;
: add-class ( env -- ) [ class add-to-vocab ] make-keyboard-safe ;

: disconnect-connector-gadget ( env -- )
    [ hand-gadget get-global dup
      [ [ connector-gadget? ] [ connected? ] bi and ] [ control-value disconnect ] smart-when*
      find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: remove-node-gadget ( env -- )
    [ hand-gadget get-global find-node
      [ [ outputs [ links>> [ control-value disconnect ] each ] each ]
        [ control-value dup dup forget-alt remove-from-parent
          parent>> swap set-control-value ] bi
      ] [ drop ] if*
    ] make-keyboard-safe ;

: edit-node-gadget ( env -- )
    [ hand-gadget get-global find-node
      [ dup f f rot set-name-and-target request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value variadic? ]
        [ dup control-value input add-from-class inputs last
          <connector-gadget> add-gadget drop
        ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value [ variadic? ] [ inputs length 2 > ] bi and ]
        [ dup control-value [ but-last ] change-contents drop inputs last unparent ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: toggle-result ( env -- )
    [ dup control-value {
        { [ dup word? ] [ dup run-word result>> swap set-control-value ] }
        { [ dup result? ] [ parent>> swap set-control-value ] }
        [ drop drop ]
      } cond 
    ] make-keyboard-safe ;

: completion ( env -- )
    [ find-world world-focus control-value first matching-words ]
    [ get-completion set-control-value ] bi ;

:: next-nth ( seq elt n -- elt' )
    seq [ elt eq? ] find drop n +
    seq length 1 - min 0 max
    seq nth ;

:: next-nth-word ( env n -- )
    env [ dup control-value definition? [
      [ vocab-control-value [ classes ] [ words ] bi append ]
      [ control-value n next-nth ] [ dupd set-control-value ] tri
    ] when drop ] make-keyboard-safe ;

:: next-nth-completion ( env n -- )
    env get-completion dup [ control-value ] [ selected>> ] bi
    n next-nth >>selected redraw-completion drop ;

:: next-nth-word/completion ( env n -- )
    env dup get-completion control-value 
    [ n next-nth-completion ] [ n next-nth-word ] if ;

: previous-word ( env -- )  -1 next-nth-word/completion ;
: next-word ( env -- )  +1 next-nth-word/completion ;

: save-skov-image ( env -- )
    [ drop save export-vocabs ] make-keyboard-safe ;

: load-vocabs ( env -- )
    [ update-skov-root skov-root get-global swap set-control-value ] make-keyboard-safe ;

: show-help ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value factor-name search (browser-window) ] with-interactive-vocabs ]
      [ show-browser ] if* drop
    ] make-keyboard-safe ;

: environment-window ( -- )
    [ <environment-gadget> "Skov" open-status-window ] with-ui ;

environment-gadget "general" f {
    { T{ key-up f f "w" } add-call }
    { T{ key-up f f "W" } add-call }
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
    { T{ key-up f f "n" } add-word }
    { T{ key-up f f "N" } add-word }
    { T{ key-up f f "k" } add-class }
    { T{ key-up f f "K" } add-class }
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
    { T{ key-up f f "TAB" } completion }
} define-command-map
