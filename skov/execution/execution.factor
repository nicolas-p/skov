! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart eval
kernel locals math math.parser namespaces sequences
sequences.deep sets skov.code skov.utilities ui.gadgets
vocabs.parser ;
IN: skov.execution

SYMBOL: current-id
0 current-id set-global

TUPLE: lambda  contents ;
TUPLE: lambda-input  id ;

: <lambda> ( seq -- lambda ) 
    flatten members lambda new swap >>contents ;

M: lambda inputs>>  drop { } ;

: lambda-inputs>> ( lambda -- seq ) 
    contents>> [ inputs>> ] map concat [ link>> ] map [ lambda-input? ] filter ;

: lambda-output>> ( lambda -- output-connector )
    contents>> last outputs>> [ connected? ] filter first ;

: next-id ( -- id )
    current-id get-global 1 + [ current-id set-global ] keep ;

: id ( output-connector -- id )
    [ [ ] [ next-id ] if* ] change-id id>> ;

: write-stack-effect ( word -- seq )
    [ inputs>> [ name>> replacements ] map ]
    [ outputs>> [ name>> replacements ] map ] bi
    { "--" } glue { "(" } { ")" } surround ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

: walk ( node -- seq )
    [ inputs>> [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <lambda> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        { [ dup special-input? ] [ drop { } ] }
        [ lambda-input new >>link drop { } ]
    } cond ] map ] [ ] bi 2array ;

: ordered-graph ( word -- seq )
    contents>> [ outputs>> [ connected? not ] all? ] filter [ walk ] map flatten members-eq ;

: write-id ( obj -- str )
    id number>string "#" prepend ;

GENERIC: write ( obj -- seq )

M: element write
    [ inputs>> [ special-input? ] reject [ link>> write-id ] map ]
    [ [ name>> replacements 1array ] keep 
      [ variadic? ] [ inputs>> length 2 - [ dup last 2array ] times ] smart-when* ]
    [ outputs>> [ special-output? ] reject [ write-id ] map ]
    tri dup empty? [ "" ] [ ":>" ] if swap 4array ;

M: output write
    inputs>> [ link>> write-id ] map ;

M: lambda write
    [ lambda-inputs>> [ write-id ] map { "[|" } { "|" } surround ]
    [ contents>> [ write ] map ]
    [ lambda-output>> [ special-output? not ]
        [ write-id dup "] :>" swap 3array ]
        [ write-id "] :>" swap 2array ] smart-if
    ] tri 3array ;

: path ( word -- str )
    [ path>> ] [ path>> ]
    [ parents reverse rest but-last [ name>> replacements ] map "." join ] smart-if
    dup empty? [ drop "scratchpad" ] when ;

:: write-vocab ( word -- seq )
    "IN:" word path "::" 3array ;

:: write-import ( word -- seq )
    "FROM:" word path "=>" word name>> replacements ";" 5array ;

: write-imports ( word -- seq )
    words>> [ path>> ] filter [ write-import ] map "USE: locals" suffix ;

: write-word ( word -- seq )
    { [ write-imports ]
      [ write-vocab ]
      [ name>> replacements ]
      [ write-stack-effect ]
      [ ordered-graph [ write ] map ]
    } cleave 5array ";" suffix flatten harvest " " join ;

: eval-word ( word -- )
    [ name>> replacements ] [ write-word ( -- ) eval ] smart-when* ;

: run-word ( word -- )
    [ eval-word ]
    [ [ write-import " " join ] [ name>> replacements ] bi " " glue eval>string ]
    [ result<< ] tri ;
