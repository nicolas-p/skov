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

: mid-x ( node -- x )  [ loc>> first ] [ half-width ] bi + ;
: set-mid-x ( x node -- node )  [ half-width - ] [ [ second 2array ] change-loc ] bi ;

: y ( node -- y )  loc>> second ;
: set-y ( y node -- node )  [ first swap 2array ] change-loc ;

: mid-loc ( node -- xy )  [ mid-x ] [ y ] bi 2array ;
:: set-loc ( xy node -- node )  xy first node set-mid-x xy second node set-y drop ;

: rel-loc ( node1 node2 -- xy )  swap [ mid-loc ] bi@ v- ;
:: set-rel-loc ( node1 node2 new-rel-loc -- )  node1 mid-loc new-rel-loc v+ node2 set-loc drop ;

: ?select ( node-gadget -- )
    [ [ children>> [ label? ] any? ] [ find-vocab ] bi and ]
    [ [ control-value ] [ find-env set-control-value ] bi ] smart-when* ;

: select-result ( node-gadget -- )
    [ control-value result>> ] [ find-env ] bi set-control-value ;

: node-theme ( node-gadget -- node-gadget )
    dup (node-theme)
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

: add-connector-gadgets ( node-gadget -- node-gadget )
    dup control-value connectors [ <connector-gadget> add-gadget ] each ;

:: add-name-field ( node-gadget -- node-gadget )
    node-gadget dup '[ _ [ drop empty? not ] [ name<< ] smart-when* ] <action-field>
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

: make-label-permanent ( node -- )
    dup clear-gadget add-name dup find-graph [ add-connections drop ] when*
    node-theme ?select ;

M:: node-gadget name<< ( name gadget -- )
    gadget control-value word?
    [ gadget find-env get-completion selected>>
      [ gadget control-value swap dup name>> [ >>target ] [ >>name ] bi*
        add-connectors drop gadget make-label-permanent
        gadget find-env get-completion reset-completion ]
      [ gadget control-value name >>name find-target [ length 1 > ]
        [ gadget find-env get-completion set-control-value
          name gadget children>> first editor>> set-editor-string ]
        [ gadget control-value name >>name swap first >>target
          add-connectors drop gadget make-label-permanent
        ] smart-if
      ] if*
    ] [ gadget control-value name >>name add-connectors drop gadget make-label-permanent ] if ;

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
    "( r : remove | e : edit | h : help )" swap control-value
    path "." " > " replace [ "Defined in " swap append swap "     " glue ] when* ;

node-gadget H{
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
