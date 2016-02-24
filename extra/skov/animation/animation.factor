! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors arrays assocs combinators combinators.smart
kernel locals math math.order math.vectors random sequences
sequences.deep sets skov.code skov.gadgets
skov.gadgets.node-gadget skov.utilities ui.gadgets ;
IN: skov.animation

: nodes>> ( def -- seq )  children>> [ node-gadget? ] filter ;
: connected-nodes>> ( def -- seq )  nodes>> [ connected? ] filter ;
: unconnected-nodes>> ( def -- seq )  nodes>> [ connected? ] reject ;

:: add-vertical-springs ( node -- node )
    node [
      node connected-inputs>> [ links>> first parent>> { 0 1 } 2array ] map
      node connected-outputs>> [ links>> [ parent>> { 0 -1 } 2array ] map ] map concat
      append append
    ] change-springs ;

: all-nodes-above ( connector -- seq )
    links>> [ parent>> dup connected-inputs>> [ all-nodes-above ] map 2array ] map flatten ;

: all-nodes-below ( connector -- seq )
    links>> [ parent>> dup connected-outputs>> [ all-nodes-below ] map 2array ] map flatten ;

:: each-pair ( seq quot -- )
    seq [ but-last ] [ rest ] bi quot 2each ; inline

: if-more-than-one ( seq quot -- )
    [ length 1 > ] swap smart-when* ; inline

:: add-left-right-springs ( node1 node2 -- )
    node1 [ { node2 { -1 0 } } suffix ] change-springs drop
    node2 [ { node1 { 1 0 } } suffix ] change-springs drop ;

: reject-common ( set1 set2 -- set1' set2' )
    [ diff ] [ swap diff ] 2bi ;

:: process-connector-row ( seq quot -- )
    seq [ [ quot bi@ reject-common [ add-left-right-springs ] cartesian-each ] each-pair ] if-more-than-one ; inline

: add-horizontal-springs ( node -- node )
    dup connected-inputs>> [ all-nodes-above ] process-connector-row
    dup connected-outputs>> [ all-nodes-below ] process-connector-row ;

CONSTANT: k 0.05
CONSTANT: sat 0.1

:: spring-force ( dx dx0 -- f )
    dx0 dx - k *
    dx0 0 > [ sat neg max ] when
    dx0 0 < [ sat min ] when ;

:: force ( node1 node2 pos -- force )
    node1 x>> node1 half-width pos first * -
    node2 x>> node2 half-width pos first * + - pos first 50 * spring-force
    node1 y>> node2 y>> - pos second 80 * spring-force
    pos first 0 = not [ drop 5 * 0 ] when
    2array ;

: update-acceleration ( node -- node )
    dup springs>> [ dupd first2 force ] map v-sum >>acc ;

:: update-velocity ( node -- node )
    node [ node acc>> v+ 0.85 v*n ] change-vel ;

:: update-position ( node -- node )
    node [ node vel>> v+ ] change-pos ;

: move-nodes ( seq -- seq )
    [ update-acceleration ] map [ update-velocity ] map [ update-position ] map ;

: stop? ( seq -- ? )
    [ acc>> [ abs ] map supremum 0.01 <= ] all? ;

: place-nodes ( def -- def )
     dup connected-nodes>>
     [ add-vertical-springs ] map
     [ add-horizontal-springs ] map
     [ dup stop? ] [ move-nodes ] until drop ;

: left-edge ( seq -- x )
    [ empty? not ] [ [ pos>> first ] map infimum ] [ 70 ] smart-if* ;

: max-width ( seq -- w )
    [ empty? not ] [ [ pref-dim first ] map supremum ] [ 0 ] smart-if* ;

:: place-unconnected-nodes ( def -- def )
    def connected-nodes>> left-edge 70 - :> x
    def unconnected-nodes>> max-width :> w
    def unconnected-nodes>>
    dup length :> l
    l iota
    [ [ dup pref-dim first w - 2 / x swap - w - >integer ] dip 
      l 2 / - 50 * 2array >>pos drop ] 2each
    def ;
