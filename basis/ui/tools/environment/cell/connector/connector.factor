! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators
combinators.short-circuit combinators.smart kernel locals models
namespaces sequences code ui.tools.environment.actions ui.tools.environment.common
ui.tools.environment.connection ui.tools.environment.cell.theme system
ui.gadgets ui.gadgets.worlds ui.gestures ui.pens.image ;
FROM: code => inputs outputs call ;
IN: ui.tools.environment.cell.connector

: <connector> ( value -- connector )
    <model> connector new swap >>model connector-size dup 2array >>dim ;

:: link ( connector -- connector )
    connector find-graph children>>
    [ outputs [ control-value connector control-value link>> eq? ] filter ] map
    concat first ;

: add-connections ( graph -- graph )
    dup connections [ unparent ] each
    dup nodes
    [ inputs
      [ control-value connected? ] filter
      [ dup link 2dup connect <connection> ] map
    ] map concat [ add-gadget ] each ;

M: connector connect
    dupd [ swap suffix ] change-links swap [ swap suffix ] change-links drop ;

: proto-connection>> ( definition-gadget -- pc )
    children>> [ proto-connection? ] filter first ;

: display-proto-connection ( connector -- )
    hand-click-loc get-global <proto-connection> add-gadget drop ;

: update-proto-connection ( connector -- )
    proto-connection>> hand-loc get-global >>loc2 relayout ;

M: connector graft*
    connector-theme drop ;

M: connector connected?
    links>> [ connector? ] any? ;

: connector-status-text ( connector -- str )
    [ control-value name>> ] [ connected? ] bi [ "     ( X  disconnect )" append ] when ;

connector H{
    { T{ button-down f f 1 }  [ [ find-vocab not ] [ display-proto-connection ] smart-when* ] }
    { T{ drag }               [ [ find-vocab not ] [ update-proto-connection ] smart-when* ] }
    { T{ button-up f f 1 }    [ [ find-vocab not ] [ create-connection ] smart-when* ] }
    { mouse-enter [ [ make-bigger connector-status-text ] keep show-status ] }
    { mouse-leave [ make-smaller hide-status ] }
} set-gestures
