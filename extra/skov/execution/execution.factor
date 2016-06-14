! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
compiler.units debugger effects io.streams.string kernel locals
locals.rewrite.closures locals.types quotations sequences
sequences.deep sets skov.code ;
QUALIFIED: words
IN: skov.execution

TUPLE: subtree  contents ;
TUPLE: subtree-input  id ;

: <subtree> ( seq -- lambda ) 
    flatten members subtree new swap >>contents ;

M: subtree introduces>>
    contents>> [ inputs>> ] map concat [ link>> ] map [ subtree-input? ] filter ;

M: subtree inputs>>
    drop { } ;

M: subtree outputs>>
    contents>> last outputs>> [ connected? ] filter ;

: add-subtree-inputs ( definition -- definition )
    dup contents>> [ inputs>> ] map concat [ connected? ] reject [ invisible?>> ] reject
    [ subtree-input new "local" <local> >>id >>link ] map drop ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

: walk ( node -- seq )
    [ inputs>> [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <subtree> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: sort-graph ( seq -- seq )
    [ outputs>> [ connected? not ] all? ] filter [ walk ] map flatten members ;

: input-ids ( node -- seq )  inputs>> [ invisible?>> ] reject [ link>> id>> ] map ;
: output-ids ( node -- seq )  outputs>> [ invisible?>> ] reject [ id>> ] map ;

: effect ( def -- effect )
    [ introduces>> ] [ returns>> ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

: set-output-ids ( def -- def )
    dup contents>> [ outputs>> ] map concat [ "local" <local> >>id ] map drop ;

GENERIC: transform ( node -- compiler-node )

M: introduce transform
    drop { } ;

M: return transform
    input-ids first 1array ;

M: text transform
    [ name>> ] [ output-ids <multi-def> ] bi 2array ;

M: word transform
    [ input-ids ] [ target>> suffix ] [ output-ids <multi-def> suffix ] tri ;

M: word-definition transform
    add-subtree-inputs set-output-ids
    [ introduces>> [ output-ids first ] map ]
    [ contents>> sort-graph [ transform ] map concat >quotation ] bi <lambda> ;

M: subtree transform
    { [ introduces>> [ id>> ] map ]
      [ contents>> [ transform ] map concat >quotation ]
      [ output-ids append <lambda> ]
      [ output-ids <multi-def> ]
    } cleave 2array ;

:: define ( def -- )
    [ def f >>defined?
      [ def factor-name
        def path>> words:create-word dup def alt<<
        def transform rewrite-closures first
        def effect words:define-declared
      ] with-compilation-unit
      t >>defined? drop
    ] try ;

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ] [ alt>> [ execute( -- ) ] with-string-writer ] [ save-result ] tri ;
