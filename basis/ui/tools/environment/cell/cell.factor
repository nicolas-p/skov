! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.execution colors combinators
combinators.smart fry kernel locals math math.order
math.statistics math.vectors models sequences splitting system
ui.gadgets ui.gadgets.borders ui.gadgets.editors strings
ui.gadgets.labels ui.gadgets.worlds ui.gestures ui.pens.solid
ui.pens.tile ui.tools.environment.theme namespaces ;
FROM: code => call ;
FROM: models => change-model ;
IN: ui.tools.environment.cell

CONSTANT: cell-height 26
CONSTANT: min-cell-width 29

TUPLE: cell < border  selection ;

: selected? ( cell -- ? )
    [ control-value ] [ selection>> value>> ] bi eq? ;

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

: replace-space ( char -- char )
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

:: edit-cell ( cell -- cell )
    cell clear-gadget
    cell [ cell enter-name drop ] <action-field>
    cell cell-colors :> text-color :> cell-color drop
    cell-color <solid> >>boundary
    cell-color <solid> >>interior
    { 0 0 } >>size
    [ set-font [ text-color >>foreground cell-color >>background ] change-font ] change-editor
    add-gadget dup request-focus ;

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
    cell clear-gadget
    cell model value>> name>> >string make-spaces-visible <label> set-font
    [ cell cell-colors nip nip >>foreground ] change-font add-gadget cell-theme drop ;

M: cell focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

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

: cell-clicked ( cell -- )
    [ selected? ] [ edit-cell ] [ select-cell ] smart-if drop ;

: ?enter-name ( cell -- cell )
    [ gadget-child action-field? ]
    [ dup gadget-child gadget-child control-value first swap enter-name ] smart-when ;

:: change-cell ( cell quot -- )
    cell selection>> quot change-model ; inline

:: change-cell* ( cell quot -- )
    cell gadget-child action-field?
    [ cell quot change-cell ] unless ; inline

: convert-cell ( cell class -- )
    [ change-node-type ] curry change-cell* ;

: remove-cell ( cell -- )
    [ remove-node ] change-cell* ;

: insert-cell ( cell -- )
    [ insert-node ] change-cell* ;

: move-up ( cell -- )
    [ [ contents>> empty? ] [ contents>> first ] smart-unless ] change-cell ;

: move-down ( cell -- )
    [ [ parent>> word? ] [ parent>> ] smart-unless ] change-cell ;

cell H{
    { T{ button-down }         [ cell-clicked ] }
    { T{ key-down f f "RET" }  [ cell-clicked ] }
    { T{ key-down f f "w" }    [ call convert-cell ] }
    { T{ key-down f f "W" }    [ call convert-cell ] }
    { T{ key-down f f "i" }    [ introduce convert-cell ] }
    { T{ key-down f f "I" }    [ introduce convert-cell ] }
    { T{ key-down f f "o" }    [ return convert-cell ] }
    { T{ key-down f f "O" }    [ return convert-cell ] }
    { T{ key-down f f "t" }    [ text convert-cell ] }
    { T{ key-down f f "T" }    [ text convert-cell ] }
    { T{ key-down f f "r" }    [ remove-cell ] }
    { T{ key-down f f "R" }    [ remove-cell ] }
    { T{ key-down f f "b" }    [ insert-cell ] }
    { T{ key-down f f "B" }    [ insert-cell ] }
    { T{ key-down f f "UP" }   [ move-up ] }
    { T{ key-down f f "DOWN" } [ move-down ] }
} set-gestures
