! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code combinators.smart kernel locals
math math.vectors opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.environment
ui.environment.theme ui.gadgets ui.render ;
IN: ui.environment.connection-gadget

:: <connection-gadget> ( end start -- connection-gadget )
    connection-gadget new start >>start end >>end ;

: loc-in-definition ( connector -- loc ) [ loc>> ] [ parent>> loc>> ] bi v+ ;

: start-loc ( connection -- loc )
    start>> loc-in-definition connector-size 2 / connector-size 1 - 2array v+ ;

: end-loc ( connection -- loc )
    end>> loc-in-definition connector-size 2 / 1 2array v+ ;

: 3D-point-array ( seq -- array )
    [ 0 suffix ] map concat float-array new like ;

:: control-points ( loc1 loc2 -- seq )
    loc1 second loc2 second + 2 / :> middle
    loc1
    loc1 first middle 2array
    loc2 first middle 2array
    loc2
    4array 3D-point-array ;

:: control-points-arc ( loc -- seq )
    loc { -10 -10 } v+
    loc
    loc { 10 -10 } v+
    3array 3D-point-array ;

:: draw-curve ( loc1 loc2 -- )
    1 0x00FF glLineStipple
    connection-colour gl-color
    GL_LINE_SMOOTH glEnable 
    1.5 gl-scale glLineWidth
    GL_MAP1_VERTEX_3 0.0 1.0 3 4 loc1 loc2 control-points glMap1f
    GL_MAP1_VERTEX_3 glEnable
    100 0.0 1.0 glMapGrid1f
    GL_LINE 0 100 glEvalMesh1
    GL_MAP1_VERTEX_3 glDisable ;

:: draw-arc ( loc -- )
    connection-colour gl-color
    GL_LINE_SMOOTH glEnable 
    1.5 gl-scale glLineWidth
    GL_MAP1_VERTEX_3 0.0 1.0 3 3 loc control-points-arc glMap1f
    GL_MAP1_VERTEX_3 glEnable
    100 0.0 1.0 glMapGrid1f
    GL_LINE 0 100 glEvalMesh1
    GL_MAP1_VERTEX_3 glDisable ;

:: draw-curve-and-arc ( loc1 loc2 -- )
    loc1 { 0 5 } v+ loc2 draw-curve
    loc1 { 0 10 } v+ draw-arc ;

M: connection-gadget draw-gadget*
    [ start>> control-value invisible?>> ]
    [ GL_LINE_STIPPLE glEnable ] [ GL_LINE_STIPPLE glDisable ] smart-if
    [ start-loc ] [ end-loc ] [ end>> control-value unevaluated? ] tri
    [ draw-curve-and-arc ] [ draw-curve ] if
    GL_LINE_STIPPLE glDisable ;

:: <proto-connection> ( loc1 -- dummy-connection )
    proto-connection new loc1 >>loc1 loc1 >>loc2 ;

M:: proto-connection draw-gadget* ( c -- )
    GL_LINE_STIPPLE glDisable
    c parent>> screen-loc :> def-loc
    c loc1>> def-loc v-
    c loc2>> def-loc v-
    draw-curve ;
