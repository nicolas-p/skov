! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators combinators.smart
eval io io.directories io.encodings.utf8 io.files io.files.info
io.pathnames kernel locals math namespaces prettyprint sequences
code system ui.gadgets code.execution ;
FROM: code => inputs outputs call ;
IN: code.import-export

SYMBOL: skov-version

: work-directory ( -- path )
    image-path parent-directory "work" append-path ;

: make-directory? ( path -- path )
    [ exists? not ] [ dup make-directory ] smart-when ;

: vocab-directory-path ( elt -- str )
    parents reverse rest [ factor-name ] map path-separator join work-directory swap append-path ;

: set-output-ids ( def -- def )
    dup contents>> [ outputs ] map concat dup length iota [ >>id drop ] 2each
    dup contents>> [ inputs ] map concat unconnected [ f >>link drop ] each ;

GENERIC: (export) ( element -- seq )

: export ( element -- seq )
    [ (export) ] [ name>> prefix ] [ class-of prefix ] tri ;

M: vocab (export)
    definitions [ export ] map >array 1array ;

M: definition (export)
    set-output-ids contents>> [ export ] map >array 1array ;

M: call (export)
    [ path ] [ contents>> [ export ] map >array ] bi 2array ;

M: node (export)
    contents>> [ export ] map >array 1array ;

M: slot (export)
    initial-value>> 1array ;

M: input (export)
    [ link>> dup [ id>> ] when ] [ invisible?>> ] bi 2array ;

M: output (export)
    [ id>> ] [ invisible?>> ] bi 2array ;

:: write-vocab-file ( vocab -- )
    vocab vocab-directory-path make-directory?
    vocab factor-name ".skov" append append-path utf8
    [ "! Skov version " skov-version get-global append print vocab export . ] with-file-writer
    vocab vocabs [ write-vocab-file ] each ;

: export-vocabs ( -- )
    skov-root get-global write-vocab-file ;

:: find-output ( id def -- output )
    def contents>> [ outputs ] map concat [ id>> id = ] filter [ f ] [ first ] if-empty ;

:: ids>links ( def -- def )
    def contents>>
    [ inputs [ [ def find-output ] change-link ] map ] map
    drop def ;

:: find-target-with-path ( call -- )
    call target>> :> this-path
    call dup find-target
    [ [ number? not ] [ vocabulary>> this-path = ] [ t ] smart-if* ] filter
    first >>target drop ;

:: find-targets ( def -- def )
    def calls [ find-target-with-path ] each def ;

: define-last-element ( def -- def )
    dup contents>> [ last ?define ] unless-empty ;

GENERIC: (import) ( seq element -- element )

: import ( seq -- element )
    unclip new swap unclip swapd >>name (import) ;

M: vocab (import)
    swap first [ import add-element define-last-element ] each ;

M: definition (import)
    swap first [ import add-element ] each find-targets ids>links ;

M: call (import)
    swap first2 [ >>target ] [ [ import add-element ] each ] bi* ;

M: node (import)
    swap first [ import add-element ] each ;

M: slot (import)
    swap first >>initial-value ;

M: input (import)
    swap first2 [ >>link ] [ >>invisible? ] bi* ;

M: output (import)
    swap first2 [ >>id ] [ >>invisible? ] bi* ;

: sub-directories ( path -- seq )
    dup directory-entries [ directory? ] filter [ name>> append-path ] with map ;

: skov-file ( path -- path )
    dup directory-files [ file-extension "skov" = ] filter first append-path ;

:: read-vocab-files ( path -- vocab )
    path skov-file utf8 file-contents "USE: code " swap append eval( -- seq ) import
    path sub-directories [ read-vocab-files add-element ] each ;

: update-skov-root ( -- )
    skov-root work-directory read-vocab-files swap set-global ;
