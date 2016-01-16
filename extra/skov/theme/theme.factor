! Copyright (C) 2015 Nicolas Pénet.
USING: accessors colors colors.constants colors.hex io.pathnames
kernel sequences system ui.images ui.pens.solid ;
IN: skov.theme

CONSTANT: content-background-colour HEXCOLOR: 002b36
CONSTANT: connection-colour HEXCOLOR: 93A1A1

CONSTANT: content-text-colour HEXCOLOR: E5E5E5
CONSTANT: node-dark-text-colour COLOR: black
CONSTANT: node-light-text-colour HEXCOLOR: C4DCDE
CONSTANT: node-faded-text-colour HEXCOLOR: 93A1A1

: set-font ( label -- label )
    [ 17 >>size "Linux Biolinum O" >>name t >>bold? transparent >>background ] change-font ;

: set-light-font ( label -- label )
    set-font [ content-text-colour >>foreground ] change-font ;

: with-background ( gadget -- gadget )
    content-background-colour <solid> >>interior ;

: theme-image ( name -- image-name )
    "vocab:skov/theme/" prepend-path ".png" append <image-name> ;

: 2-theme-image ( prefix suffix -- image-name )
    "--" glue theme-image ;

! This will need to be removed if the Windows transparency bug is fixed one day
: transparent* ( -- colour )
    os windows? [ COLOR: white ] [ transparent ] if ;
