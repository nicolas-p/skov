! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants colors.hex io.pathnames
kernel sequences system ui.images ui.pens.image ui.pens.solid ;
IN: ui.tools.environment.theme

CONSTANT: content-background-colour HEXCOLOR: 002b36

CONSTANT: faded-background HEXCOLOR: 0E4153
CONSTANT: dark-background HEXCOLOR: 355E67
CONSTANT: orange-background HEXCOLOR: E95813
CONSTANT: green-background HEXCOLOR: 7CBB00
CONSTANT: white-background HEXCOLOR: D0D0D0
CONSTANT: blue-background HEXCOLOR: 1096FD

CONSTANT: content-text-colour HEXCOLOR: E5E5E5
CONSTANT: dark-text-colour COLOR: black
CONSTANT: light-text-colour HEXCOLOR: C4DCDE
CONSTANT: faded-text-colour HEXCOLOR: 93A1A1

: set-font ( label -- label )
    [ 17 >>size t >>bold? ] change-font ;

: set-light-font ( label -- label )
    set-font [ content-text-colour >>foreground ] change-font ;

: with-background ( gadget -- gadget )
    content-background-colour <solid> >>interior ;

: theme-image ( name -- image-name )
    "vocab:ui/tools/environment/theme/" prepend-path ".png" append <image-name> ;

: 2-theme-image ( prefix suffix -- image-name )
    "--" glue theme-image ;

: 2-theme-image-pen ( str str -- pen )
    2-theme-image <image-pen> t >>fill? ;
