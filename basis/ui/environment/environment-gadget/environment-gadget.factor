! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code kernel locals models namespaces sequences
system ui ui.commands ui.environment ui.environment.actions
ui.environment.completion-gadget ui.environment.graph-gadget
ui.environment.node-pile ui.environment.plus-button-pile
ui.environment.result-gadget ui.environment.theme
ui.environment.vocab-gadget ui.gadgets ui.gadgets.borders
ui.gadgets.buttons.round ui.gadgets.packs ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tracks ui.gestures
ui.tools.browser ui.tools.common ;
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
    { T{ key-up f f "h" } show-help-browser }
    { T{ key-up f f "H" } show-help-browser }
    { T{ key-up f f "BACKSPACE" } toggle-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
    { T{ key-up f f "TAB" } completion }
} os macosx = { 
    { T{ key-down f { A+ } "s" } save-skov-image }
    { T{ key-down f { A+ } "S" } save-skov-image }
    { T{ key-down f { A+ } "l" } load-vocabs }
    { T{ key-down f { A+ } "L" } load-vocabs }
} { 
    { T{ key-down f { C+ } "s" } save-skov-image }
    { T{ key-down f { C+ } "S" } save-skov-image }
    { T{ key-down f { C+ } "l" } load-vocabs }
    { T{ key-down f { C+ } "L" } load-vocabs }
} ? append define-command-map
