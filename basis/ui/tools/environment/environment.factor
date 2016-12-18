! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code kernel locals models namespaces sequences
system ui ui.commands ui.tools.environment.common ui.tools.environment.actions
ui.tools.environment.completion ui.tools.environment.content
ui.tools.environment.graph
ui.tools.environment.button-pile
ui.tools.environment.theme ui.tools.environment.navigation ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.round ui.gadgets.packs
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.tracks
ui.gestures ui.tools.browser ui.tools.common ;
IN: ui.tools.environment

environment { 700 600 } set-tool-dim

: <help-button> ( -- button )
    [ drop show-browser ] "help" <word-button> "Help     ( H )" >>tooltip ;

:: <environment> ( -- gadget )
    skov-root get-global <model> :> model
    horizontal environment new-track model >>model
    vertical <track>
        <help-button> f track-add
        model <button-pile> { 0 0 } <border> 1 track-add
    { 10 10 } <filled-border>
    f track-add
    vertical <track>
        model <content> { 10 10 } <border> <scroller> 1 track-add
        f <model> <completion> f track-add
    1 track-add
    model <navigation> { 10 10 } <filled-border> <scroller> f track-add
    with-background ;

: environment-window ( -- )
    [ <environment> "Skov" open-status-window ] with-ui ;

environment "general" f {
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
    { T{ key-up f f "x" } disconnect-connector }
    { T{ key-up f f "X" } disconnect-connector }
    { T{ key-up f f "r" } remove-bubble }
    { T{ key-up f f "R" } remove-bubble }
    { T{ key-up f f "e" } edit-bubble }
    { T{ key-up f f "E" } edit-bubble }
    { T{ key-up f f "RIGHT" } more-inputs }
    { T{ key-up f f "LEFT" } less-inputs }
    { T{ key-up f f "h" } show-help-browser }
    { T{ key-up f f "H" } show-help-browser }
    { T{ key-up f f "BACKSPACE" } toggle-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
    { T{ key-up f f "TAB" } show-completion }
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
