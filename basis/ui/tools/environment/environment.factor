! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.execution code.import-export
combinators kernel listener locals memory models namespaces
sequences ui ui.commands ui.gadgets ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tracks ui.gestures
ui.tools.browser ui.tools.common ui.tools.environment.cell
ui.tools.environment.navigation ui.tools.environment.theme ;
FROM: models => change-model ;
IN: ui.tools.environment

TUPLE: environment < tool ;

environment { 700 600 } set-tool-dim

:: <environment> ( -- gadget )
    skov-root get-global <model> :> model
    vertical environment new-track model >>model
    model <navigation> <scroller> 1 track-add
    with-background ;

: environment-window ( -- )
    [ <environment> "Skov" open-status-window ] with-ui ;

: save-skov-image ( env -- )
    drop save export-vocabs ;

: load-vocabs ( env -- )
    update-skov-root skov-root get-global swap set-control-value ;

environment H{
    { T{ key-down f { C+ } "h" } [ drop show-browser ] }
    { T{ key-down f { C+ } "H" } [ drop show-browser ] }
    { T{ key-down f { C+ } "e" } [ save-skov-image ] }
    { T{ key-down f { C+ } "E" } [ save-skov-image ] }
    { T{ key-up f { C+ } "l" } [ load-vocabs ] }
    { T{ key-up f { C+ } "L" } [ load-vocabs ] }
} set-gestures