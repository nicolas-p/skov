! Copyright (C) 2016 Nicolas Pénet.
USING: colors.hex combinators.smart listener namespaces
sequences skov ui ui.gadgets.borders ui.gadgets.panes ;
IN: ui.tools.listener

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

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.directories"
  "lists.lazy"
  "splitting"
} append ] change-global

IN: ui.gadgets.theme
CONSTANT: help-header-background HEXCOLOR: EDF4D9
