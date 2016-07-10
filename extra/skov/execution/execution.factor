! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.parser classes.tuple combinators
combinators.smart compiler.units debugger effects
io.streams.string kernel listener locals locals.rewrite.closures
locals.types math quotations sequences sequences.deep sets
skov.code splitting vocabs.parser ;
FROM: skov.code => inputs outputs ;
QUALIFIED: words
IN: skov.execution

TUPLE: subtree  contents ;
TUPLE: subtree-introduce  id ;

: <subtree> ( seq -- lambda ) 
    flatten members subtree new swap >>contents ;

: subtree-introduces ( subtree -- seq )
    contents>> [ inputs ] map concat [ link>> ] map [ subtree-introduce? ] filter ;

: subtree-output ( subtree -- seq )
    contents>> last outputs connected first ;

: add-subtree-introduces ( definition -- definition )
    dup contents>> [ inputs ] map concat unconnected visible
    [ subtree-introduce new "local" <local> >>id >>link ] map drop ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

: walk ( node -- seq )
    [ inputs [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <subtree> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: sort-graph ( seq -- seq )
    [ outputs [ connected? not ] all? ] filter [ walk ] map flatten members ;

: input-ids ( node -- seq )  inputs visible [ link>> id>> ] map ;
: output-ids ( node -- seq )  outputs visible [ id>> ] map ;

: effect ( def -- effect )
    [ introduces ] [ returns ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

: set-output-ids ( def -- def )
    dup contents>> [ outputs ] map concat [ "local" <local> >>id ] map drop ;

:: process-variadic ( seq word -- seq )
    seq word [ variadic? ] [ inputs length 1 - ] [ 1 ] smart-if*
    [ word target>> ] replicate append ;

GENERIC: transform ( node -- compiler-node )

M: introduce transform
    drop { } ;

M: return transform
    input-ids first 1array ;

M: text transform
    [ name>> ] [ output-ids <multi-def> ] bi 2array ;

M: word transform
    [ input-ids ] [ process-variadic ] [ output-ids <multi-def> suffix ] tri ;

M: word-definition transform
    add-subtree-introduces set-output-ids
    [ introduces [ output-ids first ] map ]
    [ contents>> sort-graph [ transform ] map concat >quotation ] bi <lambda> ;

M: subtree transform
    { [ subtree-introduces [ id>> ] map ]
      [ contents>> [ transform ] map concat >quotation ]
      [ subtree-output id>> suffix <lambda> ]
      [ subtree-output id>> <def> ]
    } cleave 2array ;

:: set-recursion ( word lambda -- lambda )
    lambda [ recursion 1array word 1array replace 
    dup [ lambda? ] filter [ word swap set-recursion ] map drop ] change-body ;

:: try-definition ( quot def -- )
    [ def f >>defined? quot with-compilation-unit t >>defined? drop ] try ; inline

GENERIC: define ( def -- )

M:: word-definition define ( def -- )
    [ def factor-name
      def path words:create-word dup dup def alt<<
      def transform set-recursion rewrite-closures first
      def effect words:define-declared
    ] def try-definition ;

M:: tuple-definition define ( def -- )
    def factor-name :> name
    def path :> path
    def contents>> [ factor-name ] map >array :> slots
    [ name path create-class :> class
      class tuple slots define-tuple-class
      name "<" ">" surround path words:create-word class define-boa-word
      name ">" "<" surround path words:create-word
      slots [ ">>" append [ search ] with-interactive-vocabs 1quotation ] map
      \ cleave 2array >quotation
      name 1array slots <effect> words:define-declared 
    ] def try-definition ;

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ] [ alt>> [ execute( -- ) ] with-string-writer ] [ save-result ] tri ;
