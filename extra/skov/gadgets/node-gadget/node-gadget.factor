! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart fry kernel
locals math math.order math.statistics math.vectors models
sequences skov.code skov.execution skov.gadgets
skov.gadgets.connection-gadget skov.gadgets.connector-gadget
skov.theme skov.utilities ui.gadgets ui.gadgets.editors
ui.gadgets.labels ui.gadgets.worlds ui.gestures ui.pens.solid
ui.pens.tile ;
IN: skov.gadgets.node-gadget

M: node-gadget x>>  [ loc>> first ] [ pref-dim first 2 / >integer ] bi + ;
M: node-gadget y>>  [ loc>> second ] [ pref-dim second 2 / >integer ] bi + ;

: width ( node-gadget -- w ) pref-dim first ;
: half-width ( node-gadget -- w ) width 2 / ;

: ?select ( node-gadget -- )
    [ [ find-vocab not ] [ find-env ] smart-when control-value ]
    [ find-env ] bi set-control-value ;

: select-result ( node-gadget -- )
    [ control-value result>> ] [ find-env ] bi set-control-value ;

: node-theme ( node-gadget -- node-gadget )
    dup (node-theme)
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

: add-connector-gadgets ( node-gadget -- node-gadget )
    dup control-value connectors>> [ <connector-gadget> add-gadget ] each ;

: ?add-connectors ( node-gadget -- node-gadget )
    dup [ find-vocab not ] [ control-value add-connectors drop ] smart-when* ;

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

M: node-gadget name<<
    [ control-value name<< ] [ dup clear-gadget ?add-connectors add-name
      dup find-graph [ add-connections drop ] when* ] bi node-theme ?select ;

:: spread ( connectors width -- seq )
    connectors length :> nb
    width nb connector-size * - :> width
    width nb 1 + / >integer :> gap
    nb [ gap ] replicate :> gaps
    gaps nb iota [ connector-size * connector-size min ] map v+ cum-sum ;

M: node-gadget connected?
    connectors>> [ connected? ] any? ;

M: node-gadget layout*
    { [ call-next-method ]
      [ [ inputs>> dup ] [ width ] bi spread [ 0 2array ] map [ swap loc<< ] 2each ]
      [ [ outputs>> dup ] [ width ] bi spread [ node-height 2array ] map [ swap loc<< ] 2each ]
    } cleave ;

M:: node-gadget pref-dim* ( node -- dim )
    node gadget-child pref-dim first node-height +
    node inputs>> length node outputs>> length max node-height connector-size - * max
    min-node-width max node-height connector-size + 2array ;

M: node-gadget focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: node-gadget graft*
   node-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

: node-status-text ( node-gadget -- str )
    "( r : remove | e : edit | h : help )" swap control-value
    [ path>> ] [ "IN: " swap path append swap "     " glue ] smart-when* ;

node-gadget H{
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
