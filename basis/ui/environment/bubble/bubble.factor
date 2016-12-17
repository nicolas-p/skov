! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences code code.execution ui.environment
ui.environment.connection ui.environment.connector
ui.environment.theme  splitting ui.gadgets
ui.gadgets.editors ui.gadgets.labels ui.gadgets.worlds
ui.gestures ui.pens.solid ui.pens.tile ;
FROM: code => inputs outputs call ;
IN: ui.environment.bubble

: width ( bubble -- w ) pref-dim first ;
: half-width ( bubble -- w/2 ) width 2 /i ;

: left-edge ( bubble -- x )  loc>> first ;
: center ( bubble -- x )  [ left-edge ] [ half-width ] bi + ;
: right-edge ( bubble -- x )  [ left-edge ] [ width ] bi + ;
: top-edge ( bubble -- y )  loc>> second ;

: ?select ( bubble -- )
    [ [ find-vocab ] [ find-env ] smart-unless control-value ]
    [ find-env set-control-value ] bi ;

: select-result ( bubble -- )
    [ control-value result>> ] [ find-env ] bi set-control-value ;

: bubble-theme ( bubble -- bubble )
    dup (bubble-theme)
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

: add-connectors ( bubble -- bubble )
    dup control-value connectors [ <connector> add-gadget ] each ;

: set-name-and-target ( target name bubble -- )
    [ control-value swap >>name swap [ >>target ] when* add-connectors drop ]
    [ ?select ] bi ;

: set-node-field-string ( str bubble -- )
    children>> first editor>> set-editor-string ;

: reset-completion ( completion -- )
    f >>selected f swap set-control-value ;

: get-completion ( env --  completion )
    children>> second children>> second ;

:: enter-name ( name bubble -- )
    gadget control-value call?
    [ gadget find-env get-completion :> completion
      completion selected>>
      [ dup name>> gadget set-name-and-target completion reset-completion ]
      [ gadget control-value name >>name find-target { 
          { [ dup length 1 > ] [ completion set-control-value name gadget set-node-field-string ] }
          { [ dup length 1 = ] [ first name gadget set-name-and-target ] }
          { [ dup empty? ] [ drop gadget dup control-value unlink remove-from-parent unparent ] }
        } cond
      ] if*
    ] [ f name gadget set-name-and-target ] if ;

:: add-name-field ( bubble -- bubble )
    bubble dup '[ _ [ drop empty? not ] [ enter-name ] smart-when* ] <action-field>
    bubble (bubble-theme) :> text-colour :> bg-colour drop
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

: add-name-label ( bubble -- bubble )
    dup control-value name>> make-spaces-visible <label> set-font add-gadget ;

: add-name ( bubble -- bubble )
    [ control-value name>> ] [ add-name-label ] [ add-name-field ] smart-if add-connectors ;

: <bubble> ( value -- node )
    <model> bubble new swap >>model add-name ;

:: spread ( connectors width -- seq )
    connectors length :> nb
    width nb connector-size * - :> width
    width nb 1 + /i :> gap
    nb [ gap ] replicate :> gaps
    gaps nb iota [ connector-size * connector-size min ] map v+ cum-sum ;

M: bubble connected?
    connectors [ connected? ] any? ;

M: bubble layout*
    { [ call-next-method ]
      [ [ inputs dup ] [ width ] bi spread [ 0 2array ] map [ swap loc<< ] 2each ]
      [ [ outputs dup ] [ width ] bi spread [ bubble-height 2array ] map [ swap loc<< ] 2each ]
    } cleave ;

M:: bubble pref-dim* ( bubble -- dim )
    node gadget-child pref-dim first bubble-height +
    node inputs length node outputs length max bubble-height connector-size - * max
    min-node-width max bubble-height connector-size + 2array ;

M: bubble focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: bubble graft*
   bubble-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

: node-type ( bubble -- str )
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

: node-status-text ( bubble -- str )
    [ node-type ] [ control-value ] bi
    path "." " > " replace [ " defined in " swap append append ] when*
    "     ( R  remove )     ( E  edit )     ( H  help )" append ;

bubble H{
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
