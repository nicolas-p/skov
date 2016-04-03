! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart debugger
eval fry kernel locals math math.parser namespaces sequences
sequences.deep sets skov.code skov.utilities ui.gadgets
vocabs.parser ;
IN: skov.execution

TUPLE: lambda  contents ;
TUPLE: lambda-input  id ;

: <lambda> ( seq -- lambda ) 
    flatten members lambda new swap >>contents ;

M: lambda inputs>>  drop { } ;

: lambda-inputs>> ( lambda -- seq ) 
    contents>> [ inputs>> ] map concat [ link>> ] map [ lambda-input? ] filter ;

: lambda-output>> ( lambda -- output-connector )
    contents>> last outputs>> [ connected? ] filter first ;

: write-stack-effect ( word -- seq )
    [ inputs>> [ factor-name ] map ]
    [ outputs>> [ factor-name ] map ] bi
    { "--" } glue { "(" } { ")" } surround ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

: walk ( node -- seq )
    [ inputs>> [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <lambda> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: ordered-graph ( word -- seq )
    contents>> [ outputs>> [ connected? not ] all? ] filter [ walk ] map flatten members ;

: write-id ( obj -- str )
    id>> number>string "#" prepend ;

GENERIC: write ( obj -- seq )

M: node write
    [ inputs>> [ special-input? ] reject [ link>> write-id ] map ]
    [ [ factor-name 1array ] keep 
      [ variadic? ] [ inputs>> length 2 - [ dup last 2array ] times ] smart-when* ]
    [ outputs>> [ special-output? ] reject [ write-id ":>" swap 2array ] map reverse ]
    tri 3array ;

M: output write
    inputs>> [ link>> write-id ] map ;

M: text write
    [ factor-name ] [ drop ":>" ] [ outputs>> first write-id ] tri 3array ;

M: lambda write
    [ lambda-inputs>> [ write-id ] map { "[|" } { "|" } surround ]
    [ contents>> [ write ] map ]
    [ lambda-output>> [ special-output? not ]
        [ write-id dup "] :>" swap 3array ]
        [ write-id "] :>" swap 2array ] smart-if
    ] tri 3array ;

M: vocab path>>
    parents reverse rest [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: word-definition path>>
    parents reverse rest but-last [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

:: write-vocab ( def -- seq )
    "IN:" def path>> 2array ;

: assemble ( seq -- str )
    output>array flatten harvest " " join ; inline

:: write-import ( word -- seq )
    [ "FROM:" word path>> "=>" word factor-name ";" ] assemble ;

: write-imports ( word -- seq )
    words>> [ path>> ] filter [ write-import ] map "USE: locals" suffix ;

M:: word-definition write ( word -- seq )
    [ word write-imports
      word write-vocab
      "::"
      word factor-name
      word write-stack-effect
      word ordered-graph [ write ] map
      ";"
    ] assemble ;

M:: tuple-definition write ( tup -- seq )
    tup factor-name :> name
    tup contents>> [ name>> ] map :> slots
    [ "USE: locals"
      "USE: accessors"
      tup write-vocab
      "TUPLE:" name slots ";"
      "C:" name "<" ">" surround name
      "::" name ">" "<" surround "(" name "--" slots ")" slots [ ">>" append name swap 2array ] map ";"
    ] assemble ;

: add-lambda-inputs ( definition -- definition )
    dup contents>> [ inputs>> ] map concat [ connected? ] reject [ special-input? ] reject
    [ lambda-input new >>link ] map drop ;

: define ( elt -- )
    add-lambda-inputs set-output-ids
    [ name>> ] [ '[ _ dup f >>defined? write ( -- ) eval t >>defined? drop ] try ] smart-when* ;

: run-word ( word -- )
    [ define ] [ [ write-import ] [ factor-name ] bi " " glue eval>string ] [ save-result ] tri ;
