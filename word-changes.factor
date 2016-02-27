! Copyright (C) 2016 Nicolas Pénet.
USING: colors.hex combinators.smart listener namespaces
sequences skov ui ui.gadgets.borders ui.gadgets.panes ;

IN: kernel
: special-while ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip while ; inline

: special-until ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip until ; inline

IN: syntax
: true ( -- true )  t ;
: false ( -- false )  f ;

IN: math
: add ( x y -- sum )  + ;
: sub ( x y -- subtraction )  - ;
: mul ( x y -- product )  * ;
: div ( x y -- division )  / ;
: half ( x -- x/2 )  2 / ;

IN: math.functions
: exp ( x -- e^x )  e^ ;
: pow ( x a -- x^a )  ^ ;
: pow-2 ( x y -- 2^x )  2^ ;
: pow-10 ( x y -- 10^x )  10^ ;

IN: math.constants
: tau ( -- tau )  2 pi * ; inline

IN: prettyprint
: display ( object -- )  . ;

IN: ui.gadget.panes
: display-gadget ( gadget -- )  gadget. ;

IN: ui.tools
MAIN: skov-window

IN: ui.tools.listener
: show-listener ( -- ) [ border? ] find-window [ raise-window ] [ skov-window ] if* ;
: listener-window ( -- ) skov-window ;

USE: lists.lazy
USE: splitting
USE: math.trig

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.directories"
  "io.directories.hierarchy"
  "lists.lazy"
  "splitting"
  "math.functions"
  "math.trig"
  "math.vectors"
  "sequences.deep"
  "binary-search"
} append ] change-global

IN: ui.gadgets.theme
CONSTANT: help-header-background HEXCOLOR: EDF4D9
