! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences code code.execution ui.environment
ui.environment.connection-gadget ui.environment.connector-gadget
ui.environment.theme  splitting ui.gadgets
ui.gadgets.editors ui.gadgets.labels ui.gadgets.worlds
ui.gestures ui.pens.solid ui.pens.tile ;
FROM: code => inputs outputs ;
IN: ui.environment.node-gadget

: width ( node-gadget -- w ) pref-dim first ;
: half-width ( node-gadget -- w/2 ) width 2 /i ;

: left-edge ( node -- x )  loc>> first ;
: center ( node -- x )  [ left-edge ] [ half-width ] bi + ;
: right-edge ( node -- x )  [ left-edge ] [ width ] bi + ;
: top-edge ( node -- y )  loc>> second ;

: ?select ( node-gadget -- )
    [ [ find-vocab ] [ find-env ] smart-unless control-value ]
    [ find-env set-control-value ] bi ;

: select-result ( node-gadget -- )
    [ control-value result>> ] [ find-env ] bi set-control-value ;

: node-theme ( node-gadget -- node-gadget )
    dup (node-theme)
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

: add-connector-gadgets ( node-gadget -- node-gadget )
    dup control-value connectors [ <connector-gadget> add-gadget ] each ;

: set-name-and-target ( target name gadget -- )
    [ control-value swap >>name swap [ >>target ] when* add-connectors drop ]
    [ ?select ] bi ;

: set-node-field-string ( str gadget -- )
    children>> first editor>> set-editor-string ;

: reset-completion ( completion-gadget -- )
    f >>selected f swap set-control-value ;

: get-completion ( env --  completion )
    children>> second children>> second ;

:: enter-name ( name gadget -- )
    gadget control-value word?
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

:: add-name-field ( node-gadget -- node-gadget )
    node-gadget dup '[ _ [ drop empty? not ] [ enter-name ] smart-when* ] <action-field>
    node-gadget (node-theme) :> text-colour :> bg-colour drop
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

: add-name-label ( node-gadget -- node-gadget )
    dup control-value name>> make-spaces-visible <label> set-font add-gadget ;

: add-name ( node-gadget -- node-gadget )
    [ control-value name>> ] [ add-name-label ] [ add-name-field ] smart-if add-connector-gadgets ;

: <node-gadget> ( value -- node )
    <model> node-gadget new swap >>model add-name ;

:: spread ( connectors width -- seq )
    connectors length :> nb
    width nb connector-size * - :> width
    width nb 1 + /i :> gap
    nb [ gap ] replicate :> gaps
    gaps nb iota [ connector-size * connector-size min ] map v+ cum-sum ;

M: node-gadget connected?
    connectors [ connected? ] any? ;

M: node-gadget layout*
    { [ call-next-method ]
      [ [ inputs dup ] [ width ] bi spread [ 0 2array ] map [ swap loc<< ] 2each ]
      [ [ outputs dup ] [ width ] bi spread [ node-height 2array ] map [ swap loc<< ] 2each ]
    } cleave ;

M:: node-gadget pref-dim* ( node -- dim )
    node gadget-child pref-dim first node-height +
    node inputs length node outputs length max node-height connector-size - * max
    min-node-width max node-height connector-size + 2array ;

M: node-gadget focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: node-gadget graft*
   node-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

: node-status-text ( node-gadget -- str )
    "( R  remove )     ( E  edit )     ( H  help )" swap control-value
    path "." " > " replace [ "Defined in " swap append swap "     " glue ] when* ;

node-gadget H{
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
