! Copyright (C) 2015 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart effects
fry hashtables.private kernel listener locals math.parser
sequences splitting vectors vocabs.parser ;
FROM: namespaces => change-global ;
IN: skov.code

TUPLE: element  name parent contents path ;
TUPLE: vocab < element ;
TUPLE: word < element  result ;
TUPLE: connector < element ;
TUPLE: input < connector  link ;
TUPLE: output < connector  id ;

GENERIC: outputs>> ( obj -- seq )
M: element vocabs>> ( elt -- seq ) contents>> [ vocab? ] filter ;
M: element words>> ( elt -- seq ) contents>> [ word? ] filter ;
M: element inputs>> ( elt -- seq ) contents>> [ input? ] filter ;
M: element outputs>> ( elt -- seq ) contents>> [ output? ] filter ;

:: add ( parent child-class -- parent )
     child-class new parent >>parent parent [ ?push ] change-contents ;

:: add-with-name ( parent child-name child-class -- parent )
     child-class new child-name >>name parent >>parent parent [ ?push ] change-contents ;

: remove-from-parent ( child -- )
     dup parent>> contents>> remove-eq! drop ;

: replacements ( str -- str )
    " >>" ">>" replace
    " <<" "<<" replace
    ">> " ">>" replace
    dup [ CHAR: { swap member? not ] [ CHAR: " swap member? not ] bi and [ " " "-" replace ] when ;

: replace-quot ( seq -- seq )
    [ dup array? [ drop "quot" ] [ ] if ] map ;

: convert-stack-effect ( stack-effect -- seq seq )
    [ in>> replace-quot ] [ out>> replace-quot ]
    [ out-var>> dup dup "." = not and [ suffix ] [ drop ] if ] tri ;

: add-to-interactive-vocabs ( vocab-name -- )
    '[ _ suffix ] interactive-vocabs swap change-global ;

:: in-out ( word -- seq seq )
    word name>> replacements :> name
    [ { { [ name CHAR: { swap member? ] [ { } { "sequence" } ] }
        { [ name CHAR: " swap member? ] [ { } { "string" } ] }
        { [ name string>number ] [ { } { "number" } ] }
        { [ name search not ] [ { } { } ] }
        [ name search dup vocabulary>> word path<< stack-effect convert-stack-effect ]
      } cond ] with-interactive-vocabs ;

GENERIC: add-connectors ( node -- node )
M: input add-connectors  f >>contents dup name>> output add-with-name ;
M: output add-connectors  f >>contents dup name>> input add-with-name ;

M: word add-connectors
    f >>contents dup in-out
    [ [ input add-with-name ] each ]
    [ [ output add-with-name ] each ] bi* ;

: order-connectors ( connector connector -- connector connector )
    dup output? [ swap ] when ;

: output-and-input? ( connector connector -- ? )
    [ output? ] [ input? ] bi* and ;

: same-word? ( connector connector -- ? )
    [ parent>> ] bi@ eq? ;

GENERIC: connected? ( connector -- ? )

M: connector connected?
    link>> connector? ;

: disconnect ( input -- )
    f swap link<< ;

: ?connect ( connector connector -- )
    [ [ connector? ] bi@ and ]
    [ order-connectors 
      [ [ output-and-input? ] [ nip connected? not ] [ same-word? not ] 2tri and and ]
      [ link<< ] smart-when* 
    ] smart-when* ;

: executable? ( word -- ? )
    [ inputs>> empty? ] [ outputs>> empty? ] [ words>> empty? not ] tri and and ;
