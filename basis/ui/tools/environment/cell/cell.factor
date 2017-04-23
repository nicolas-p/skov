! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.execution colors combinators
combinators.smart fry kernel locals math math.order
math.statistics math.vectors models sequences splitting system
ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.labels ui.gadgets.worlds ui.gestures ui.pens.solid
ui.pens.tile ui.tools.environment.theme namespaces ;
FROM: code => inputs call ;
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
    } cond 
    [ os windows? not [ drop transparent ] when ] dip ;

: cell-theme ( cell -- cell )
    dup [ cell-colors ] [ selected? ] bi [ [ "-selected" append ] 2dip ] when
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

:: enter-name ( name cell -- )
    cell control-value
    { { [ name empty? ] [ ] }
      { [ cell control-value call? not ] [ name >>name ] }
      { [ cell control-value clone name >>name find-target empty? not ]
        [ name >>name dup find-target first >>target ] }
      [ ]
    } cond
    cell set-control-value
    cell control-value [ word? ] find-parent [ ?define ] when* ;

: replace-space ( char -- char )
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

:: edit-cell ( cell -- )
    cell clear-gadget
    cell [ cell enter-name ] <action-field>
    cell cell-colors :> text-color :> cell-color drop
    cell-color <solid> >>boundary
    cell-color <solid> >>interior
    { 0 0 } >>size
    [ set-font [ text-color >>foreground cell-color >>background ] change-font ] change-editor
    add-gadget drop ;

: <cell> ( selection value -- node )
    <model> cell new { 8 0 } >>size min-cell-width cell-height 2array >>min-dim
    swap >>model swap >>selection ;

M:: cell model-changed ( model cell -- )
    cell clear-gadget
    cell model value>> name>> >string make-spaces-visible <label> set-font 
    [ cell cell-colors nip nip >>foreground ] change-font add-gadget drop ;

M: cell focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: cell graft*
   cell-theme drop ;

: node-type ( cell -- str )
    control-value {
        { [ dup vocab? ] [ drop "Vocabulary" ] }
        { [ dup text? ] [ drop "Text" ] }
        { [ dup constructor? ] [ drop "Object constructor" ] }
        { [ dup accessor? ] [ drop "Slot accessor" ] }
        { [ dup mutator? ] [ drop "Slot mutator" ] }
        { [ dup call? ] [ drop "Word" ] }
        { [ dup word? ] [ drop "Word" ] }
        { [ dup introduce? ] [ drop "Input" ] }
        { [ dup return? ] [ drop "Output" ] }
    } cond ;

: node-status-text ( cell -- str )
    [ node-type ] [ control-value ] bi
    path "." " > " replace [ " defined in " swap append append ] when*
    "     ( R  remove )     ( E  edit )     ( H  help )" append ;

: find-cell ( gadget -- node )
    [ cell? ] find-parent ;

:: select-cell ( cell -- )
    cell control-value name>> "⨁" = [ 
        cell parent>> control-value [ vocab? ] find-parent
        cell control-value "" >>name add-element drop
    ] when
    cell control-value cell selection>> set-model ;

: cell-clicked ( cell -- )
    dup dup selected? [ edit-cell ] [ select-cell ] if request-focus ;

:: ?deselect-cell ( cell -- )
    cell selected? not [ f cell enter-name ] when ;

cell H{
    { mouse-enter       [ [ node-status-text ] keep show-status ] }
    { mouse-leave       [ hide-status ] }
    { T{ button-down }  [ cell-clicked ] }
    { lose-focus        [ ?deselect-cell ] }
} set-gestures
