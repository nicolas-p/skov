! Copyright (C) 2016 Nicolas Pénet.
USING: accessors arrays classes combinators combinators.smart
eval io.directories io.encodings.utf8 io.files io.files.info
io.pathnames kernel locals math namespaces prettyprint sequences
skov.code system ui.gadgets ;
IN: skov.import-export

: work-directory ( -- path )
    image-path parent-directory "work" append-path ;

: make-directory? ( path -- path )
    [ exists? not ] [ dup make-directory ] smart-when ;

: vocab-directory-path ( elt -- str )
    parents reverse rest [ factor-name ] map path-separator join work-directory swap append-path ;

GENERIC: (export) ( element -- seq )

: export ( element -- seq )
    [ (export) ] [ class-of ] bi prefix ;

M: vocab (export)
    [ name>> ] [ definitions>> [ export ] map >array ] bi 2array ;

M: definition (export)
    set-output-ids [ name>> ] [ contents>> [ export ] map >array ] bi 2array ;

M: word (export)
    [ name>> ] [ path>> ] [ contents>> [ export ] map >array ] tri 3array ;

M: input (export)
    [ name>> ] [ link>> dup [ id>> ] when ] bi 2array ;

M: output (export)
    [ name>> ] [ id>> ] bi 2array ;

M: definition-input (export)
    [ name>> ] [ contents>> [ export ] map >array ] bi 2array ;

M: definition-output (export)
    [ name>> ] [ contents>> [ export ] map >array ] bi 2array ;

:: write-vocab-file ( vocab -- )
    vocab vocab-directory-path make-directory?
    vocab factor-name ".skov" append append-path utf8 [ vocab export . ] with-file-writer
    vocab vocabs>> [ write-vocab-file ] each ;

: export-vocabs ( -- )
    skov-root get-global write-vocab-file ;

:: find-output ( id def -- output )
    def contents>> [ outputs>> ] map concat [ id>> id = ] filter [ f ] [ first ] if-empty ;

:: ids>links ( def -- def )
    def contents>>
    [ inputs>> [ [ [ number? ] [ def find-output ] smart-when ] change-link ] map ] map
    drop def ;

GENERIC: (import) ( seq element -- element )

: import ( seq -- element )
    unclip new (import) ;

M: vocab (import)
    swap first2 [ >>name ] [ [ import add-element ] each ] bi* ;

M: definition (import)
    swap first2 [ >>name ] [ [ import add-element ] each ] bi* ids>links ;

M: word (import)
    swap first3 [ >>name ] [ >>path ] [ [ import add-element ] each ] tri* ;

M: definition-input (import)
    swap first2 [ >>name ] [ [ import add-element ] each ] bi* ;

M: input (import)
    swap first2 [ >>name ] [ >>link ] bi* ;

M: definition-output (import)
    swap first2 [ >>name ] [ [ import add-element ] each ] bi* ;

M: output (import)
    swap first2 [ >>name ] [ >>id ] bi* ;

: sub-directories ( path -- seq )
    dup directory-entries [ directory? ] filter [ dupd name>> append-path ] map nip ;

: skov-file ( path -- path )
    dup directory-files [ file-extension "skov" = ] filter first append-path ;

:: read-vocab-files ( path -- vocab )
    path skov-file utf8 file-contents "USE: skov.code " swap append eval( -- seq ) import
    path sub-directories [ read-vocab-files add-element ] each ;

: update-skov-root ( -- )
    skov-root work-directory read-vocab-files swap set-global ;
