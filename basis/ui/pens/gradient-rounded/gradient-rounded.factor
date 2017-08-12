USING: accessors arrays assocs colors kernel locals math
math.functions math.ranges math.vectors opengl.gl sequences
ui.pens ui.pens.caching ui.pens.gradient ;
IN: ui.pens.gradient-rounded

TUPLE: gradient-rounded < caching-pen  colors foreground last-vertices last-colors ;

: <gradient-rounded> ( colors foreground -- gradient )
    gradient-rounded new swap >>foreground swap >>colors ;

<PRIVATE

CONSTANT: tau 6.283185307179586
CONSTANT: points 100

: squircle-point ( theta -- xy )
    [ cos ] [ sin ] bi [ [ abs sqrt ] [ sgn ] bi * 0.5 * 0.5 + ] bi@ 2array ;

:: half-squircle ( -- seq )
    1/4 tau * 3/4 tau * 1/2 tau * points / <range> [ squircle-point ] map ;

:: vertices ( dim -- seq )
    dim first2 :> ( x y )
    half-squircle [ y v*n ] map
    dup reverse [ first2 swap x swap - swap 2array ] map append
    x 2 / y 2array prefix ;

:: interp-color ( x colors -- seq )
    colors [ >rgba-components 4array ] map first2 zip [ first2 dupd - x * - ] map ;

:: vertices-colors ( dim seq colors -- seq )
    seq [ second dim second / colors interp-color ] map ;

: draw-triangle-fan ( vertices colors -- )
    GL_TRIANGLE_FAN glBegin
    [ first3 glColor3f first2 glVertex2f ] 2each
    glEnd ;

M:: gradient-rounded recompute-pen ( gadget gradient -- )
    gadget dim>> dup vertices dup gradient last-vertices<<
    gradient colors>> vertices-colors gradient last-colors<< ;

PRIVATE>

M: gradient-rounded draw-interior
    [ compute-pen ]
    [ last-vertices>> ]
    [ last-colors>> draw-triangle-fan ] tri ;

M: gradient-rounded pen-background
     2drop transparent ;

M: gradient-rounded pen-foreground
    nip foreground>> ;
