! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
compiler.tree compiler.units debugger effects eval fry
io.streams.string kernel listener locals math math.parser
namespaces quotations sequences sequences.deep sets skov.code
skov.utilities ui.gadgets vocabs.parser ;
QUALIFIED: words
IN: skov.execution

: walk ( node -- seq )
    [ inputs>> [ {
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: sort-graph ( seq -- seq )
    [ outputs>> [ connected? not ] all? ] filter [ walk ] map flatten members ;

: input-ids ( node -- seq )  inputs>> [ special-connector? ] reject [ link>> id>> ] map ;
: output-ids ( node -- seq )  outputs>> [ special-connector? ] reject [ id>> ] map ;

GENERIC: transform ( node -- compiler-node )

M: introduce transform
    output-ids <#introduce> ;

M: return transform
    input-ids <#return> ;

M: text transform
    [ factor-name ] [ output-ids first ] bi <#push> ;

: transform-number ( word -- push )
    [ name>> string>number ] [ output-ids first ] bi <#push> ;

: transform-word ( word -- call )
    [ input-ids ] [ output-ids ] [ factor-name '[ _ search ] with-interactive-vocabs ] tri <#call> ;

M: word transform
    [ name>> string>number ] [ transform-number ] [ transform-word ] smart-if ;

: ?add-empty-return ( seq -- seq )
    [ [ #return? ] any? not ] [ f <#return> suffix ] smart-when ;

M: word-definition transform
    set-output-ids contents>> sort-graph [ transform ] map ?add-empty-return ;
    
: effect ( def -- effect )
    [ inputs>> ] [ outputs>> ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

:: quotation-for-effect ( def -- quot )
    def 1quotation \ drop suffix
    def inputs>> [ drop \ drop suffix ] each
    def outputs>> [ drop 1 suffix ] each ;

:: define ( def -- )
   [ def f >>defined?
     [ def factor-name
       def path>> words:create-word dup def alt<<
       def quotation-for-effect def effect words:define-declared 
     ] with-compilation-unit
     t >>defined? drop
   ] try ;

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ] [ alt>> [ execute( -- ) ] with-string-writer ] [ save-result ] tri ;
