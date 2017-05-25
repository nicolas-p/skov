! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.execution colors combinators
combinators.short-circuit combinators.smart fry kernel locals
math math.order math.statistics math.vectors models namespaces
sequences splitting strings system ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons.round ui.gadgets.editors
ui.gadgets.editors.private ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labels ui.gadgets.worlds ui.gestures ui.pens.solid
ui.pens.tile ui.render ui.text ui.tools.environment.theme
ui.tools.inspector ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.cell

CONSTANT: cell-height 26
CONSTANT: min-cell-width 29

TUPLE: cell < border  selection ;
TUPLE: cell-editor < editor ;

: <cell-editor> ( -- editor )
    cell-editor new-editor ;

: selected? ( cell -- ? )
    [ control-value ] [ selection>> value>> [ result? ] [ parent>> ] smart-when ] bi eq? ;

: cell-colors ( cell -- img-name bg-color text-color )
    control-value
    { { [ dup input/output? ] [ drop "io" dark-background light-text-colour ] }
      { [ dup text? ] [ drop "text" white-background dark-text-colour ] }
      { [ dup call? ] [ drop "word" green-background dark-text-colour ] }
      { [ dup vocab? ] [ drop "title" dark-background light-text-colour ] }
      { [ dup word? ] [ drop "title" dark-background light-text-colour ] }
      { [ dup subtree? ] [ drop "subtree" dark-background light-text-colour ] }
    } cond 
    [ os windows? not [ drop transparent ] when ] dip ;

: cell-theme ( cell -- cell )
    dup [ cell-colors ] [ selected? ] bi [ [ "-selected" append ] 2dip ] when
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

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
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

:: collapsed? ( cell -- ? )
    cell control-value :> value
    value subtree?
    value introduce?
    value name>> empty?
    value [ subtree? ] find-parent
    cell selected? not
    and and and or ;

: <cell> ( value selection -- node )
    cell new { 8 0 } >>size min-cell-width cell-height 2array >>min-dim
    swap >>selection swap <model> >>model ;

M:: cell model-changed ( model cell -- )
    cell dup clear-gadget
    model value>> name>> >string make-spaces-visible <label> set-font
        [ cell cell-colors nip nip >>foreground ] change-font add-gadget
    <cell-editor> f >>visible? 
        cell cell-colors :> text-color :> cell-color drop
        set-font [ text-color >>foreground cell-color >>background ] change-font add-gadget
    model value>> node? [ 
        cell selected? model value>> parent>> and [
            "inactive" "✕"
            [ drop model value>> remove-from-parent cell selection>> set-model ] <round-button>
            model value>> vocab? "Delete vocabulary" "Delete word" ?
            >>tooltip add-gadget ] when
        model value>> executable? [
            cell selection>> value>> result? [
                "inactive" "⬅︎"
                [ drop model value>> cell selection>> set-model ] <round-button>
                "Show word" >>tooltip
            ] [
                "inactive" "➤"
                [ drop model value>> dup run-word result>> cell selection>> set-model ] <round-button>
                "Show result" >>tooltip 
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

M:: cell pref-dim* ( cell -- dim )
    cell call-next-method cell collapsed? [ 6 over set-second ] when ;

:: select-cell ( cell -- cell  )
    cell control-value name>> "⨁" = [ 
        cell parent>> control-value [ vocab? ] find-parent
        cell control-value "" >>name add-element drop
    ] when
    cell control-value cell selection>> set-model cell ;

:: change-cell ( cell quot -- )
    cell selection>> quot change-model ; inline

: convert-cell ( cell class -- )
    [ change-node-type ] curry change-cell ;

: remove-cell ( cell -- )
    [ remove-node ] change-cell ;

: insert-cell ( cell -- )
    [ insert-node ] change-cell ;

cell H{
    { T{ button-down }               [ select-cell drop ] }
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
    { T{ key-down f { C+ } "r" }     [ remove-cell ] }
    { T{ key-down f { C+ } "R" }     [ remove-cell ] }
    { T{ key-down f { C+ } "b" }     [ ?enter-name insert-cell ] }
    { T{ key-down f { C+ } "B" }     [ ?enter-name insert-cell ] }
    { T{ key-down f f "UP" }         [ ?enter-name [ child-node ] change-cell ] }
    { T{ key-down f f "DOWN" }       [ ?enter-name [ parent-node ] change-cell ] }
    { T{ key-down f f "LEFT" }       [ ?enter-name [ left-node ] change-cell ] }
    { T{ key-down f f "RIGHT" }      [ ?enter-name [ right-node ] change-cell ] }
    { T{ key-down f { M+ } "LEFT" }  [ [ insert-node-left ] change-cell ] }
    { T{ key-down f { M+ } "RIGHT" } [ [ insert-node-right ] change-cell ] }
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
