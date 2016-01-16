! Copyright (C) 2015 Nicolas Pénet.
USING: arrays classes combinators.smart kernel math math.vectors
prettyprint sequences ;
IN: skov.utilities

: 5array ( x x x x x -- seq )
    [ 4array ] dip suffix ;

: class>string ( node-or-class -- str )
    dup class? not [ class-of ] when unparse ;

: square ( x -- x² ) dup * ;

: v-sum ( seq -- n )
    { 0 0 } [ v+ ] reduce ;

: members-eq ( seq -- seq )
    { } [ [ swap member-eq? not ] [ suffix ] [ drop ] smart-if ] reduce ;
