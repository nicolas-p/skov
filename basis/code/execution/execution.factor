! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.parser classes.tuple code
combinators combinators.smart compiler.units debugger effects io
io.streams.string kernel listener locals locals.rewrite.closures
locals.types math quotations sequences sequences.deep sets
splitting ui.gadgets.panes vocabs.parser ui.gadgets.buttons.activate ;
FROM: code => inputs outputs call ;
QUALIFIED: words
QUALIFIED: vocabs
IN: code.execution

TUPLE: subtree  contents ;
TUPLE: subtree-introduce  id ;

: <subtree> ( seq -- lambda ) 
    flatten members subtree new swap >>contents ;

: subtree-introduces ( subtree -- seq )
    contents>> [ inputs ] map concat [ link>> ] map [ subtree-introduce? ] filter ;

: subtree-output ( subtree -- seq )
    contents>> last outputs connected first ;

: add-subtree-introduces ( definition -- definition )
    dup contents>> [ inputs ] map concat unconnected
    [ subtree-introduce new "local" <local> >>id >>link ] map drop ;

: walk ( node -- seq )
    [ inputs [ {
        { [ dup unevaluated? ] [ link>> parent>> walk <subtree> ] }
        { [ dup connected? ] [ link>> parent>> walk ] }
        [ drop { } ]
    } cond ] map ] [ ] bi 2array ;

: sort-graph ( seq -- seq )
    [ outputs [ connected? not ] all? ] filter [ walk ] map flatten members ;

: input-ids ( node -- seq )  inputs [ link>> id>> ] map ;
: output-ids ( node -- seq )  outputs [ id>> ] map ;

: effect ( def -- effect )
    [ introduces ] [ returns ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

: set-output-ids ( def -- def )
    dup contents>> [ outputs ] map concat [ "local" <local> >>id ] map drop ;

:: process-simple-variadic ( seq call -- seq )
    seq call inputs length 1 - [ call target>> ] replicate append ;

:: process-special-variadic ( seq call -- seq )
    seq call inputs length
    call name>> "1" ?head drop CHAR: n prefix [ search ] with-interactive-vocabs
    2array append ;

:: process-variadic ( seq call -- seq )
    seq call {
        { [ dup simple-variadic? ] [ process-simple-variadic ] }
        { [ dup special-variadic? ] [ process-special-variadic ] }
        [ target>> suffix ]
    } cond ;

GENERIC: transform ( node -- compiler-node )

M: introduce transform
    drop { } ;

M: return transform
    input-ids first 1array ;

M: text transform
    [ name>> ] [ output-ids <multi-def> ] bi 2array ;

M: call transform
    [ input-ids ] [ process-variadic ] [ output-ids <multi-def> suffix ] tri ;

M: word transform
    add-subtree-introduces set-output-ids
    [ introduces [ output-ids first ] map ]
    [ contents>> sort-graph [ transform ] map concat >quotation ] bi <lambda> ;

M: subtree transform
    { [ subtree-introduces [ id>> ] map ]
      [ contents>> [ transform ] map concat but-last >quotation <lambda> ]
      [ subtree-output id>> <def> ]
    } cleave 2array ;

:: set-recursion ( word lambda -- lambda )
    lambda [ recursion 1array word 1array replace 
    dup [ lambda? ] filter [ word swap set-recursion ] map drop ] change-body ;

:: try-definition ( quot def -- )
    [ def f >>defined? quot with-compilation-unit t >>defined? drop ] try ; inline

: register-alt ( alt def -- )
    swap [ suffix ] curry change-alt drop ;

GENERIC: define ( def -- )

M: vocab define ( def -- )
    path [ vocabs:create-vocab drop ] [ add-interactive-vocab ] bi ;

M:: word define ( def -- )
    [ def factor-name
      def path words:create-word dup dup def f >>alt register-alt
      def transform set-recursion rewrite-closures first
      def effect words:define-declared
    ] def try-definition ;

M:: class define ( def -- )
    def factor-name :> name
    def path :> path
    def contents>> [ factor-name ] map >array :> slots
    [ name path create-class :> class
      class def f >>alt register-alt
      class tuple slots define-tuple-class
      name " (constructor)" append path words:create-word dup def register-alt class define-boa-word
      name " (destructor)" append path words:create-word dup def register-alt
      slots [ ">>" append [ search ] with-interactive-vocabs 1quotation ] map
      \ cleave 2array >quotation
      name 1array slots <effect> words:define-declared 
    ] def try-definition ;

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ]
    [ alt>> first f pane new-pane dup swapd <pane-stream> [ execute( -- ) ] with-output-stream ]
    [ save-result ] tri ;
