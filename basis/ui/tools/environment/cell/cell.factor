! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.execution colors colors.hex
combinators combinators.short-circuit combinators.smart fry
kernel listener locals math math.order math.statistics
math.vectors models namespaces sequences splitting system
ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons.round ui.gadgets.editors
ui.gadgets.editors.private ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labels ui.gadgets.worlds ui.gestures
ui.pens.gradient-rounded ui.pens.solid ui.pens.tile ui.render
ui.pens.title-gradient
ui.text ui.tools.browser ui.tools.environment.theme ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.cell

CONSTANT: cell-height 24
CONSTANT: min-cell-width 30

TUPLE: cell < border  selection ;
TUPLE: cell-editor < editor ;

: <cell-editor> ( -- editor )
    cell-editor new-editor ;

: selected? ( cell -- ? )
    [ control-value ] [ selection>> value>> [ result? ] [ parent>> ] smart-when ] bi eq? ;

:: subtree-input? ( node -- ? )
    node introduce?
    node name>> empty? and
    node [ quoted-node? ] find-parent and ;

:: cell-colors ( cell -- bg-color text-color )
    cell control-value
    { { [ dup subtree-input? ] [ drop inactive-background light-text-colour ] }
      { [ dup input/output? ] [ drop dark-background light-text-colour ] }
      { [ dup text? ] [ drop white-background dark-text-colour ] }
      { [ dup call? ] [ drop green-background dark-text-colour ] }
      { [ dup getter? ] [ drop yellow-background dark-text-colour ] }
      { [ dup setter? ] [ drop yellow-background dark-text-colour ] }
      [ drop cell selected? active-background inactive-background ? light-text-colour ]
    } cond ;

:: cell-theme ( cell -- cell )
    cell dup cell-colors
    cell control-value name>> empty? [ faded-color ] when
    cell selected?
    cell control-value node? [ <gradient-dynamic-shape> ] [ <title-gradient> ] if
    >>interior ;

:: enter-name ( name cell -- cell )
    cell control-value
    { { [ name empty? ] [ ] }
      { [ cell control-value call? not ] [ name >>name ] }
      { [ cell control-value clone name >>name find-target empty? not ]
        [ name >>name dup find-target first >>target ] }
      [ ]
    } cond
    cell set-control-value
    cell control-value [ [ word? ] [ vocab? ] bi or ] find-parent [ ?define ] when*
    cell selection>> notify-connections cell ;

:: ?enter-name ( cell -- cell )
    cell children>> [ editor? ] filter first editor-string dup empty?
    [ drop cell ] [ cell enter-name ] if ;

: replace-space ( char -- char )
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when
    [ CHAR: \t = ] [ drop CHAR: ⇥ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

: <cell> ( value selection -- node )
    cell new { 12 0 } >>size min-cell-width cell-height 2array >>min-dim
    swap >>selection swap <model> >>model horizontal >>orientation ;

:: no-label? ( cell -- ? )
    cell control-value subtree-input?
    cell selected? not and ;

M:: cell model-changed ( model cell -- )
    cell dup clear-gadget
    cell no-label? [ "" ] [ model value>> name-or-default make-spaces-visible ] if
    <label> set-font add-gadget
    <cell-editor> f >>visible?
        cell cell-colors :> text-color drop
        set-font [ text-color >>foreground transparent >>background ] change-font add-gadget
    model value>> node? [
        cell selected? model value>> parent>> and [
            inactive-background "✕"
            [ drop model value>> remove-element cell selection>> set-model ] <round-button>
            model value>> vocab? "Delete vocabulary" "Delete word" ? "    ( Ctrl R )" append
            >>tooltip add-gadget ] when
        model value>> executable? [
            cell selection>> value>> parent>> cell control-value eq? [
                blue-background "➤"
                [ drop model value>> cell selection>> set-model ] <round-button>
                "Show word    ( Shift Enter )" >>tooltip
            ] [
                inactive-background "➤"
                [ drop model value>> dup run-word result>> cell selection>> set-model ] <round-button>
                "Show result    ( Shift Enter )" >>tooltip 
            ] if add-gadget ] when
    ] unless cell-theme drop ;

M:: cell layout* ( cell -- )
    cell children>> first { [ editor? ] [ editor-string empty? ] } 1&&
    cell children>> second { [ editor? ] [ editor-string empty? not ] } 1&& or
    [ 0 1 cell children>> exchange ] when
    cell children>> first t >>visible? drop
    cell children>> second f >>visible? drop
    cell call-next-method
    cell children>> rest rest [ 
        dup tooltip>> "Show" swap subseq? cell dim>> first 35 - 15 ? 5 2array >>loc 
        dup pref-dim >>dim drop
     ] each ;

M: cell focusable-child*
    children>> [ editor? ] filter first ;

M: cell graft*
    [ selected? ] [ request-focus ] smart-when* ;

:: select-cell ( cell -- )
    cell control-value name>> "⨁" = [ 
        cell parent>> control-value [ vocab? ] find-parent
        cell control-value "" >>name add-element drop
    ] when
    cell control-value cell selection>> set-model ;

:: change-cell ( cell quot -- )
    cell control-value node? [ cell selection>> quot change-model ] when ; inline

: convert-cell ( cell class -- )
    [ ?change-node-type ] curry change-cell ;

: remove-cell ( cell -- )
    [ replace-node-by-child ] change-cell ;

: insert-cell ( cell -- )
    [ insert-node ] change-cell ;

: quote-cell ( cell -- )
    [ (un)quote ] change-cell ;

: show-help-on-word ( cell -- )
    [ control-value target/alt
        [ (browser-window) ] [ show-browser ] if*
    ] with-interactive-vocabs ;

:: ask-for-completion ( cell -- )
    cell children>> [ editor? ] filter first editor-string
    [ cell model>> [ swap >>name t >>completion ] with change-model
      cell selection>> notify-connections ] unless-empty ;

cell H{
    { T{ button-down }               [ select-cell ] }
    { lose-focus                     [ ?enter-name drop ] }
    { T{ key-down f f "RET" }        [ ?enter-name drop ] }
    { T{ key-down f { C+ } "w" }     [ ?enter-name call convert-cell ] }
    { T{ key-down f { C+ } "W" }     [ ?enter-name call convert-cell ] }
    { T{ key-down f { C+ } "i" }     [ ?enter-name introduce convert-cell ] }
    { T{ key-down f { C+ } "I" }     [ ?enter-name introduce convert-cell ] }
    { T{ key-down f { C+ } "o" }     [ ?enter-name return convert-cell ] }
    { T{ key-down f { C+ } "O" }     [ ?enter-name return convert-cell ] }
    { T{ key-down f { C+ } "t" }     [ ?enter-name text convert-cell ] }
    { T{ key-down f { C+ } "T" }     [ ?enter-name text convert-cell ] }
    { T{ key-down f { C+ } "s" }     [ ?enter-name setter convert-cell ] }
    { T{ key-down f { C+ } "S" }     [ ?enter-name setter convert-cell ] }
    { T{ key-down f { C+ } "g" }     [ ?enter-name getter convert-cell ] }
    { T{ key-down f { C+ } "G" }     [ ?enter-name getter convert-cell ] }
    { T{ key-down f { C+ } "r" }     [ remove-cell ] }
    { T{ key-down f { C+ } "R" }     [ remove-cell ] }
    { T{ key-down f { C+ } "q" }     [ quote-cell ] }
    { T{ key-down f { C+ } "Q" }     [ quote-cell ] }
    { T{ key-down f f "UP" }         [ ?enter-name [ child-node ] change-cell ] }
    { T{ key-down f f "DOWN" }       [ ?enter-name [ parent-node ] change-cell ] }
    { T{ key-down f f "LEFT" }       [ ?enter-name [ left-node ] change-cell ] }
    { T{ key-down f f "RIGHT" }      [ ?enter-name [ right-node ] change-cell ] }
    { T{ key-down f { M+ } "LEFT" }  [ ?enter-name [ insert-node-left ] change-cell ] }
    { T{ key-down f { M+ } "RIGHT" } [ ?enter-name [ insert-node-right ] change-cell ] }
    { T{ key-down f { M+ } "DOWN" }  [ ?enter-name insert-cell ] }
    { T{ key-down f { C+ } "h" }     [ show-help-on-word ] }
    { T{ key-down f { C+ } "H" }     [ show-help-on-word ] }
    { T{ key-down f f "TAB" }        [ ask-for-completion ] }
} set-gestures

: previous-character* ( editor -- )
    [ editor-caret second 0 = ]
    [ parent>> ?enter-name [ left-node ] change-cell ]
    [ previous-character ] smart-if ;

: next-character* ( editor -- )
    [ [ editor-caret second ] [ editor-string length ] bi = ]
    [ parent>> ?enter-name [ right-node ] change-cell ]
    [ next-character ] smart-if ;

cell-editor "caret-motion" f {
    { T{ key-down f f "LEFT" } previous-character* }
    { T{ key-down f f "RIGHT" } next-character* }
} define-command-map
