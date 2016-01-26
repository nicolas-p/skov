! Copyright (C) 2015 Nicolas Pénet.
USING: arrays classes combinators.smart kernel locals math
math.order math.vectors prettyprint sequences ;
IN: skov.utilities

: 5array ( x x x x x -- seq )
    [ 4array ] dip suffix ;

: v-sum ( seq -- n )
    { 0 0 } [ v+ ] reduce ;

: members-eq ( seq -- seq )
    { } [ [ swap member-eq? not ] [ suffix ] [ drop ] smart-if ] reduce ;

:: next-nth ( seq elt n -- elt' )
    seq [ elt eq? ] find drop n +
    seq length 1 - min 0 max
    seq nth ;
