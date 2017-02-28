! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.parser classes.tuple code
combinators combinators.smart compiler.units debugger effects io
io.streams.string kernel listener locals locals.rewrite.closures
locals.types math quotations sequences sequences.deep sets
splitting ui.gadgets.panes vocabs.parser ui.gadgets.buttons.activate ;
FROM: code => call ;
QUALIFIED: words
QUALIFIED: vocabs
IN: code.execution

: effect ( def -- effect )
    [ introduces ] [ returns ] bi [ [ factor-name ] map >array ] bi@ <effect> ;

: set-input-ids ( word -- word )
    dup introduces [ dup name>> <local> >>id ] map drop ;

GENERIC: transform ( node -- compiler-node )

M: introduce transform
    id>> ;

M: text transform
    name>> ;

M: call transform
    target>> ;

M: word transform
    set-input-ids
    [ introduces [ transform ] map ]
    [ sort-tree [ return? ] reject [ transform ] map >quotation ] bi <lambda> ;

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

: ?define ( elt -- )
    [ name>> ] [ define ] smart-when* ;

: run-word ( word -- )
    [ ?define ]
    [ alt>> first f pane new-pane dup swapd <pane-stream> [ execute( -- ) ] with-output-stream ]
    [ save-result ] tri ;
