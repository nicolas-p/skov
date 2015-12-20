! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays colors combinators combinators.smart fry
kernel locals math math.order math.statistics math.vectors
sequences skov.code skov.execution skov.gadgets
skov.gadgets.connector-gadget skov.theme skov.utilities
ui.gadgets ui.gadgets.editors ui.gadgets.labels
ui.gadgets.worlds ui.gestures ui.pens.solid ui.pens.tile ;
IN: skov.gadgets.node-gadget

: connectors>> ( node-gadget -- seq )  children>> [ connector-gadget? ] filter ;
M: node-gadget inputs>> ( node-gadget -- seq )  connectors>> [ modell>> input? ] filter ;
M: node-gadget outputs>> ( node-gadget -- seq )  connectors>> [ modell>> output? ] filter ;

M: node-gadget x>>  [ loc>> first ] [ pref-dim first 2 / >integer ] bi + ;
M: node-gadget y>>  [ loc>> second ] [ pref-dim second 2 / >integer ] bi + ;

: width ( node-gadget -- w ) pref-dim first ;

: select ( node-gadget -- )
    [ [ environment-gadget? ] find-parent ] [ modell>> ] bi >>modell update drop ;

: ?select ( node-gadget -- )
    [ in-vocab? ] [ select ] smart-when* ;

: select-result ( node-gadget -- )
    [ [ environment-gadget? ] find-parent ] [ modell>> result>> ] bi >>modell update drop ;

:: node-theme ( node-gadget -- node-gadget )
    node-gadget dup [ modell>> class>string ] [ selected? [ "-selected" append ] when ] bi
    "left" "middle" "right"
    [ 2-theme-image ] tri-curry@ tri
    transparent*
    node-gadget selected? [ node-dark-text-colour ] [ node-light-text-colour ] if <tile-pen> >>interior 
    horizontal >>orientation ;

: add-connector-gadgets ( node-gadget -- node-gadget )
    [ modell>> vocab? ] [ ]
    [ dup modell>> inputs>> [ <connector-gadget> add-gadget ] each
      dup modell>> outputs>> [ <connector-gadget> add-gadget ] each ]
    smart-if ;

: ?add-connectors ( node-gadget -- node-gadget )
    dup [ parent>> definition-gadget? ] [ modell>> add-connectors drop ] smart-when* ;

: add-name-field ( node-gadget -- node-gadget )
    dup '[ _ [ drop empty? not ] [ name<< ] smart-when* ] <action-field>
    transparent* <solid> >>boundary
    transparent* <solid> >>interior { 0 0 } >>size
    [ set-font ] change-editor add-gadget ;

: add-name-label ( node-gadget -- node-gadget )
    dup modell>> name>> <label> set-font add-gadget ;

: add-name ( node-gadget -- node-gadget )
    [ modell>> name>> ] [ add-name-label add-connector-gadgets ] [ add-name-field ] smart-if ;

:: <node-gadget> ( model -- node )
    node-gadget new model >>modell add-name ;

M: node-gadget name<<
    [ modell>> name<< ] [ dup clear-gadget ?add-connectors add-name ] bi node-theme drop ;

:: spread ( connectors width -- seq )
    connectors length :> nb
    width nb 8 * - :> width
    width nb 1 + / >integer :> gap
    nb [ gap ] replicate :> gaps
    gaps nb iota [ 8 * 8 min ] map v+ cum-sum ;

M: node-gadget connected?
    connectors>> [ connected? ] any? ;

M: node-gadget layout*
    { [ call-next-method ]
      [ [ inputs>> dup ] [ width ] bi spread [ 0 2array ] map [ swap loc<< ] 2each ]
      [ [ outputs>> dup ] [ width ] bi spread [ 28 2array ] map [ swap loc<< ] 2each ]
    } cleave ;

M: node-gadget pref-dim*
    gadget-child pref-dim first 28 + 40 max 36 2array ;

M: node-gadget focusable-child*
    gadget-child dup action-field? [ ] [ drop t ] if ;

M: node-gadget graft*
   node-theme [ gadget-child field? ] [ request-focus ] smart-when* ;

: node-action ( node-gadget -- )
   [ in-vocab? ] [ 
       [ modell>> vocab? ] 
       [ [ parent>> ] [ modell>> ] bi >>modell update drop ]
       [ [ parent>> parent>> gadget-child ] [ modell>> ] bi >>modell update drop ]
       smart-if
   ] smart-when* ;

: node-status-text ( node-gadget -- str )
    "( r to remove )" swap modell>>
    [ path>> ] [ "IN: " swap path append swap "     " glue ] smart-when* ;

node-gadget H{
    { T{ button-up f f 1 }  [ ?select ] }
    { mouse-enter           [ [ node-status-text ] keep show-status ] }
    { mouse-leave           [ hide-status ] }
} set-gestures
