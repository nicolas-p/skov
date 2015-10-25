! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays combinators kernel locals math
math.order math.vectors random sequences skov.code skov.gadgets
skov.utilities ;
IN: skov.animation

: (related-nodes) ( connectors -- seq )
    [ connected? ] filter [ links>> ] map concat [ parent>> ] map ;
    
: upstream-nodes ( node -- seq )  inputs>> (related-nodes) ;
: downstream-nodes ( node -- seq )  outputs>> (related-nodes) ;

: upstream? ( node node -- ? )  swap upstream-nodes member? ;
: downstream? ( node node -- ? )  swap downstream-nodes member? ;

: connected-nodes ( node -- seq )
    [ upstream-nodes ] [ downstream-nodes ] bi append ;

: all-other-nodes ( node-gadget -- seq )
    dup parent>> children>> [ node-gadget? ] filter [ dupd = not ] filter nip ;

:: square-distance ( node1 node2 -- rsq )
    node1 x>> node2 x>> - square
    node1 y>> node2 y>> - square +
    1 max ;

:: repulsion ( node1 node2 -- force )
    node1 node2 square-distance :> rsq
    node1 x>> node2 x>> - 150 * rsq /
    node1 y>> node2 y>> - 150 * rsq /
    node1 node2 upstream? [ 4 * abs ] when
    node1 node2 downstream? [ 4 * abs neg ] when
    2array ;

:: attraction ( node1 node2 -- force )
    node2 x>> node1 x>> - 0.02 *
    node2 y>> node1 y>> - 0.02 *
    2array ;

: centre ( definition -- x y )
    dim>> [ 2 / >integer ] map first2 ;

:: attraction-to-centre ( node -- force )
    node parent>> centre :> ( xc yc )
    xc node x>> - 0.02 * 
    yc node y>> - 0.02 *
    2array ;

: net-force ( node -- force )
    { [ dup all-other-nodes [ dupd repulsion ] map v-sum nip ]
      [ dup connected-nodes [ dupd attraction ] map v-sum nip ]
      [ attraction-to-centre ] } cleave v+ v+ ;

: update-acceleration ( node -- node )
    dup net-force >>acc ;

:: update-velocity ( node -- node )
    node [ node acc>> v+ 0.85 v*n ] change-vel ;

:: update-position ( node -- node )
    node [ node vel>> v+ ] change-loc ;

: move-nodes ( seq -- seq )
    [ update-acceleration update-velocity update-position ] map ;

: stop? ( seq -- ? )
    [ acc>> [ abs ] map supremum 0.01 <= ] all? ;

: random-vector ( -- a )
    -10 10 uniform-random-float -10 10 uniform-random-float 2array ;

: place-nodes ( definition-gadget -- )
     children>> 
     [ node-gadget? ] filter
     [ random-vector >>acc random-vector >>vel ] map
     [ dup stop? ] [ move-nodes ] until drop ;
