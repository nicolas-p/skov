! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences code code.execution ui.tools.environment.actions ui.tools.environment.common
ui.tools.environment.theme splitting ui.gadgets
ui.gadgets.editors ui.gadgets.labels ui.gadgets.worlds
ui.gestures ui.pens.solid ;
FROM: code => inputs call ;
IN: ui.tools.environment.cell

CONSTANT: min-cell-size 28

: cell-colors ( cell -- bg-color text-color )
    control-value
    { { [ dup input/output? ] [ drop dark-background light-text-colour ] }
      { [ dup vocab? ] [ drop orange-background dark-text-colour ] }
      { [ dup text? ] [ drop white-background dark-text-colour ] }
      { [ dup call? ] [ drop green-background dark-text-colour ] }
      { [ dup word? ] [ drop green-background dark-text-colour ] }
    } cond ;

: cell-theme ( cell -- cell )
    dup cell-colors drop <solid> >>interior ;

: width ( cell -- w ) pref-dim first ;
: half-width ( cell -- w/2 ) width 2 /i ;

: left-edge ( cell -- x )  loc>> first ;
: center ( cell -- x )  [ left-edge ] [ half-width ] bi + ;
: right-edge ( cell -- x )  [ left-edge ] [ width ] bi + ;
: top-edge ( cell -- y )  loc>> second ;

:: add-name-field ( cell -- cell )
    cell dup '[ _ [ drop empty? not ] [ enter-name ] smart-when* ] <action-field>
    cell cell-colors :> text-color :> cell-color
    cell-color <solid> >>boundary
    cell-color <solid> >>interior
    { 0 0 } >>size
    [ set-font [ text-color >>foreground cell-color >>background ] change-font ] change-editor
    add-gadget ;

: replace-space ( char -- char )
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

:: add-name-label ( cell -- cell )
    cell dup control-value name>> make-spaces-visible <label> set-font 
    [ cell cell-colors nip >>foreground ] change-font add-gadget ;

: add-name ( cell -- cell )
    [ control-value name>> ] [ add-name-label ] [ add-name-field ] smart-if ;

: <cell> ( value -- node )
    <model> cell new { 10 5 } >>size min-cell-size dup 2array >>min-dim 
    swap >>model add-name ;

M: cell focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: cell graft*
   cell-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

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

cell H{
    { T{ button-up f f 1 }  [ edit-cell ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
