! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators combinators.smart
eval io io.directories io.encodings.utf8 io.files io.files.info
io.pathnames kernel locals math namespaces prettyprint sequences
code system ui.gadgets code.execution ;
FROM: code => call ;
IN: code.import-export

SYMBOL: skov-version

: work-directory ( -- path )
    image-path parent-directory "work" append-path ;

: make-directory? ( path -- path )
    [ exists? not ] [ dup make-directory ] smart-when ;

: vocab-directory-path ( elt -- str )
    parents reverse rest [ factor-name ] map path-separator join work-directory swap append-path ;

GENERIC: (export) ( element -- seq )

: export ( element -- seq )
    [ (export) ] [ name>> prefix ] [ class-of prefix ] tri ;

M: element (export)
    contents>> [ export ] map >array 1array ;

M: vocab (export)
    words [ export ] map >array 1array ;

M: call (export)
    [ path ] [ contents>> [ export ] map >array ] bi 2array ;

:: write-vocab-file ( vocab -- )
    vocab vocab-directory-path make-directory?
    vocab factor-name ".skov" append append-path utf8
    [ "! Skov version " skov-version get-global append print vocab export [ . ] without-limits ] with-file-writer
    vocab vocabs [ write-vocab-file ] each ;

: export-vocabs ( -- )
    skov-root get-global write-vocab-file ;

:: find-target-with-path ( call -- )
    call target>> :> this-path
    call dup find-target
    [ [ number? not ] [ vocabulary>> this-path = ] [ t ] smart-if* ] filter
    first >>target drop ;

: find-targets ( def -- )
    calls [ find-target-with-path ] each ;

: define-all-words ( vocab -- )
    [ ?define ]
    [ vocabs [ define-all-words ] each ]
    [ words [ [ find-targets ] [ ?define ] bi ] each ] tri ;

GENERIC: (import) ( seq element -- element )

: import ( seq -- element )
    unclip new swap unclip swapd >>name (import) ;

M: element (import)
    swap first [ import add-element ] each ;

M: call (import)
    swap first2 [ >>target ] [ [ import add-element ] each ] bi* ;

: sub-directories ( path -- seq )
    dup directory-entries [ directory? ] filter [ name>> append-path ] with map ;

: skov-file ( path -- path )
    dup directory-files [ file-extension "skov" = ] filter first append-path ;

:: read-vocab-files ( path -- vocab )
    path skov-file utf8 file-contents "USE: code " swap append eval( -- seq ) import
    path sub-directories [ read-vocab-files add-element ] each ;

: update-skov-root ( -- )
    skov-root work-directory read-vocab-files dup define-all-words swap set-global ;
