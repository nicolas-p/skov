! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code combinators.smart kernel
locals math math.vectors opengl opengl.gl sequences
specialized-arrays.instances.alien.c-types.float ui.tools.environment.common
ui.tools.environment.cell.theme ui.tools.environment.theme ui.gadgets ui.render ;
FROM: code => inputs ;
IN: ui.tools.environment.connection

:: <connection> ( end start -- connection )
    connection new start >>start end >>end ;

: loc-in-definition ( connector -- loc ) [ loc>> ] [ parent>> loc>> ] bi v+ ;

:: connector-tip ( connector -- loc )
    connector loc-in-definition connector-size 2 / 
    connector control-value input? [ 1 ] [ connector-size 1 - ] if 2array v+ ;

: 3D-point-array ( seq -- array )
    [ 0 suffix ] map concat float-array new like ;

:: with-gl-line-settings ( quot -- )
    1 0x00FF glLineStipple
    connection-colour gl-color
    GL_LINE_SMOOTH glEnable 
    1.5 gl-scale glLineWidth
    GL_MAP1_VERTEX_3 0.0 1.0 3 quot call( -- seq ) [ length ] [ 3D-point-array ] bi glMap1f
    GL_MAP1_VERTEX_3 glEnable
    100 0.0 1.0 glMapGrid1f
    GL_LINE 0 100 glEvalMesh1
    GL_MAP1_VERTEX_3 glDisable ; inline

:: draw-curve ( loc1 loc2 -- )
    [ loc1 second loc2 second + 2 / :> middle
      loc1
      loc1 first middle 2array
      loc2 first middle 2array
      loc2
      4array
    ] with-gl-line-settings ;

:: draw-input-arc ( loc -- )
    [ loc { -10 10 } v+
      loc
      loc { 10 10 } v+
      3array
    ] with-gl-line-settings ;

:: draw-output-arc ( loc -- )
    [ loc { -10 -10 } v+
      loc
      loc { 10 -10 } v+
      3array
    ] with-gl-line-settings ;

: lambda-inputs ( output -- seq )
    parent>> inputs [ control-value invisible?>> ] reject
    [ unconnected ] [ connected [ links>> [ lambda-inputs ] map concat ] map concat ] bi append ;

:: draw-curve-and-arcs ( loc1 loc2 locs -- )
    loc1 { 0 7 } v+ loc2 draw-curve
    loc1 { 0 12 } v+ draw-output-arc
    locs [ { 0 12 } v- draw-input-arc ] each ;

:: with-line-stipple? ( connection quot -- )
    connection end>> control-value invisible?>> [ GL_LINE_STIPPLE glEnable ] when
    connection quot call( connection -- )
    GL_LINE_STIPPLE glDisable ; inline

:: draw-connection ( connection -- )
    connection start>> connector-tip
    connection end>> connector-tip
    connection end>> control-value unevaluated?
    [ connection start>> lambda-inputs [ connector-tip ] map draw-curve-and-arcs ]
    [ draw-curve ] if ;

M: connection draw-gadget* ( connection -- )
    [ draw-connection ] with-line-stipple? ;

:: <proto-connection> ( loc1 -- dummy-connection )
    proto-connection new loc1 >>loc1 loc1 >>loc2 ;

M:: proto-connection draw-gadget* ( c -- )
    GL_LINE_STIPPLE glDisable
    c parent>> screen-loc :> def-loc
    c loc1>> def-loc v-
    c loc2>> def-loc v-
    draw-curve ;
