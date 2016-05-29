! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
compiler.tree compiler.units debugger effects eval fry
io.streams.string kernel listener locals math math.parser
namespaces quotations sequences sequences.deep sets skov.code
skov.utilities ui.gadgets vocabs vocabs.parser ;
QUALIFIED: words
IN: skov.execution

TUPLE: lambda  contents ;
TUPLE: lambda-input  id ;

: <lambda> ( seq -- lambda ) 
    flatten members lambda new swap >>contents ;

M: lambda inputs>>
    contents>> [ inputs>> ] map concat [ link>> ] map [ lambda-input? ] filter ;

M: lambda outputs>>
    contents>> last outputs>> [ connected? ] filter ;

M: lambda-input factor-name  drop "" ;

: add-lambda-inputs ( definition -- definition )
    dup contents>> [ inputs>> ] map concat [ connected? ] reject [ special-input? ] reject
    [ lambda-input new >>link ] map drop ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

: walk ( node -- seq )
    [ inputs>> [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <lambda> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: sort-graph ( seq -- seq )
    [ outputs>> [ connected? not ] all? ] filter [ walk ] map flatten members ;

: input-ids ( node -- seq )  inputs>> [ special-connector? ] reject [ link>> id>> ] map ;
: output-ids ( node -- seq )  outputs>> [ special-connector? ] reject [ id>> ] map ;

: effect ( def -- effect )
    [ inputs>> ] [ outputs>> ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

GENERIC: transform ( node -- compiler-node )
GENERIC: transform-contents ( node -- compiler-node )

:: quotation-for-effect ( def -- quot )
    def transform-contents 1quotation \ drop suffix
    def inputs>> [ drop \ drop suffix ] each
    def outputs>> [ drop 1 suffix ] each ;

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

M: word-definition transform-contents
    add-lambda-inputs set-output-ids contents>> sort-graph [ transform ] map ?add-empty-return ;

: define-lambda-word ( lambda -- word )
    [ [ quotation-for-effect ] [ effect ] bi words:define-temp ] with-compilation-unit ;

M: lambda transform
    [ define-lambda-word 1quotation ] [ output-ids first ] bi <#push> ;

M: lambda transform-contents
    [ contents>> [ transform ] map ] 
    [ inputs>> [ id>> ] map <#introduce> prefix ] 
    [ outputs>> [ id>> ] map <#return> suffix ] tri ;

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
