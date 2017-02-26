! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences code code.execution ui.tools.environment.actions ui.tools.environment.common
ui.tools.environment.cell.connector
ui.tools.environment.cell.theme ui.tools.environment.theme splitting ui.gadgets
ui.gadgets.editors ui.gadgets.labels ui.gadgets.worlds
ui.gestures ui.pens.solid ui.pens.tile ;
FROM: code => inputs outputs call ;
IN: ui.tools.environment.cell

: width ( cell -- w ) pref-dim first ;
: half-width ( cell -- w/2 ) width 2 /i ;

: left-edge ( cell -- x )  loc>> first ;
: center ( cell -- x )  [ left-edge ] [ half-width ] bi + ;
: right-edge ( cell -- x )  [ left-edge ] [ width ] bi + ;
: top-edge ( cell -- y )  loc>> second ;

: add-connectors ( cell -- cell )
    dup control-value connectors [ <connector> ] map add-gadgets ;

:: add-name-field ( cell -- cell )
    cell dup '[ _ [ drop empty? not ] [ enter-name ] smart-when* ] <action-field>
    cell (cell-theme) :> text-colour :> bg-colour drop
    bg-colour <solid> >>boundary
    bg-colour <solid> >>interior
    { 0 0 } >>size
    [ set-font [ text-colour >>foreground bg-colour >>background ] change-font ] change-editor
    add-gadget ;

: replace-space ( char -- char )
    [ CHAR: space = ] [ drop CHAR: ⎵ ] smart-when ;

: make-spaces-visible ( str -- str )
    [ length 0 > ] [ unclip replace-space prefix ] smart-when
    [ length 1 > ] [ unclip-last replace-space suffix ] smart-when ;

: add-name-label ( cell -- cell )
    dup control-value name>> make-spaces-visible <label> set-font add-gadget ;

: add-name ( cell -- cell )
    [ control-value name>> ] [ add-name-label ] [ add-name-field ] smart-if add-connectors ;

: <cell> ( value -- node )
    <model> cell new swap >>model add-name ;

M: cell connected?
    connectors [ connected? ] any? ;

M: cell layout*
    { [ call-next-method ]
      [ [ inputs dup ] [ width ] bi spread [ 0 2array ] map [ swap loc<< ] 2each ]
      [ [ outputs dup ] [ width ] bi spread [ cell-height 2array ] map [ swap loc<< ] 2each ]
    } cleave ;

M:: cell pref-dim* ( cell -- dim )
    cell gadget-child pref-dim first cell-height +
    cell inputs length cell outputs length max cell-height connector-size - * max
    min-node-width max cell-height connector-size + 2array ;

M: cell focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: cell graft*
   cell-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

: node-type ( cell -- str )
    control-value {
        { [ dup vocab? ] [ drop "Vocabulary" ] }
        { [ dup text? ] [ drop "Text" ] }
        { [ dup class? ] [ drop "Class" ] }
        { [ dup slot? ] [ drop "Class slot" ] }
        { [ dup constructor? ] [ drop "Object constructor" ] }
        { [ dup destructor? ] [ drop "Object destructor" ] }
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
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
