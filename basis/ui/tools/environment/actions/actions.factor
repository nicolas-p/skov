! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code code.execution code.import-export
combinators combinators.short-circuit combinators.smart kernel
listener locals math math.order memory namespaces sequences
ui.gadgets ui.gadgets.editors ui.gadgets.worlds ui.gestures
ui.tools.browser ui.tools.environment.common ;
FROM: code => inputs outputs call ;
FROM: vocabs => vocab-words ;
IN: ui.tools.environment.actions

:: change-control-value ( gadget quot -- )
    gadget control-value quot call( x -- x ) gadget set-control-value ;

:: change-vocab-control-value ( gadget quot -- )
    gadget control-value dup [ vocab? ] find-parent quot call( x -- x ) drop gadget set-control-value ;

: ?select ( bubble -- )
    [ [ find-vocab ] [ find-env ] smart-unless control-value dup ?define ]
    [ find-env set-control-value ] bi ;

: select-result ( bubble -- )
    [ control-value result>> ] [ find-env ] bi set-control-value ;

: set-name-and-target ( target name bubble -- )
    [ control-value swap >>name swap [ >>target ] when* add-connectors drop ]
    [ ?select ] bi ;

: set-node-field-string ( str bubble -- )
    children>> first editor>> set-editor-string ;

: reset-completion ( completion -- )
    f >>selected f swap set-control-value ;

: get-completion ( env --  completion )
    children>> second children>> second ;

:: enter-name ( name bubble -- )
    bubble control-value call?
    [ bubble find-env get-completion :> completion
      completion selected>>
      [ dup name>> bubble set-name-and-target completion reset-completion ]
      [ bubble control-value name >>name find-target { 
          { [ dup length 1 > ] [ completion set-control-value name bubble set-node-field-string ] }
          { [ dup length 1 = ] [ first name bubble set-name-and-target ] }
          { [ dup empty? ] [ drop bubble dup control-value unlink remove-from-parent unparent ] }
        } cond
      ] if*
    ] [ f name bubble set-name-and-target ] if ;

: create-connection ( connector -- )
    dup hand-gadget get-global
    [ [ connector? ] bi@ and ]
    [ [ control-value ] bi@ ?connect ] smart-when*
    find-env [ ] change-control-value ;

: make-keyboard-safe ( env quot -- )
    [ world-focus editor? not ] swap smart-when* ; inline

:: add-to-class ( env class -- )
    env [ control-value class? ]
    [ [ class add-from-class ] change-control-value ] smart-when* ;

:: add-to-word ( env class -- )
    hand-gadget get-global :> hand
    env [ control-value word? ] [
      [ class add-from-class
        hand connector?
        [ dup contents>> last 
          hand control-value input? [ output ] [ input ] if add-from-class 
          contents>> last hand control-value ?connect ] when
      ] change-control-value 
    ] smart-when* ;

:: add-to-vocab ( env class -- )
    env [ class add-from-class ] change-vocab-control-value ;

: add-input ( env -- ) [ introduce add-to-word ] make-keyboard-safe ;
: add-output ( env -- ) [ return add-to-word ] make-keyboard-safe ;
: add-text ( env -- ) [ text add-to-word ] make-keyboard-safe ;
: add-slot ( env -- ) [ slot add-to-class ] make-keyboard-safe ;
: add-constructor ( env -- ) [ constructor add-to-word ] make-keyboard-safe ;
: add-destructor ( env -- ) [ destructor add-to-word ] make-keyboard-safe ;
: add-accessor ( env -- ) [ accessor add-to-word ] make-keyboard-safe ;
: add-mutator ( env -- ) [ mutator add-to-word ] make-keyboard-safe ;
: add-call ( env -- ) [ call add-to-word ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-vocab ] make-keyboard-safe ;
: add-class ( env -- ) [ class add-to-vocab ] make-keyboard-safe ;

: disconnect-connector ( env -- )
    [ hand-gadget get-global dup
      [ [ connector? ] [ connected? ] bi and ] [ control-value disconnect ] smart-when*
      find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: remove-bubble ( env -- )
    [ hand-gadget get-global find-node
      [ [ outputs [ links>> [ control-value disconnect ] each ] each ]
        [ control-value dup dup forget-alt remove-from-parent
          parent>> swap set-control-value ] bi
      ] [ drop ] if*
    ] make-keyboard-safe ;

: edit-bubble ( env -- )
    [ hand-gadget get-global find-node
      [ dup f f rot set-name-and-target request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ dup hand-gadget get-global find-node
      [ [ control-value variadic? ]
        [ [ input add-from-class ] change-control-value ] smart-when*
      ] when* drop [ ] change-control-value
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ dup hand-gadget get-global find-node
      [ [ control-value [ variadic? ] [ inputs length 2 > ] bi and ]
        [ [ [ but-last ] change-contents ] change-control-value ] smart-when*
      ] when* drop [ ] change-control-value
    ] make-keyboard-safe ;

: toggle-result ( env -- )
    [ dup control-value {
        { [ dup { [ word? ] [ executable? ] } 1&& ]
          [ dup run-word result>> swap set-control-value ] }
        { [ dup result? ] [ parent>> swap set-control-value ] }
        [ drop drop ]
      } cond 
    ] make-keyboard-safe ;

:: matching-words* ( str -- seq )
    interactive-vocabs get [ vocab-words ] map concat [ name>> str head? ] filter ;

: matching-words ( str -- seq )
    [ f ] [ matching-words* ] if-empty ;

: show-completion ( env -- )
    [ find-world world-focus control-value first matching-words ]
    [ get-completion set-control-value ] bi ;

:: next-nth ( seq elt n -- elt' )
    seq [ elt eq? ] find drop n +
    seq length 1 - min 0 max
    seq nth ;

:: next-nth-word ( env n -- )
    env [ dup control-value definition? [
      [ vocab-control-value [ classes ] [ words ] bi append ]
      [ control-value n next-nth ] [ dupd set-control-value ] tri
    ] when drop ] make-keyboard-safe ;

:: next-nth-completion ( env n -- )
    env get-completion dup [ control-value ] [ selected>> ] bi
    n next-nth >>selected [  ] change-control-value drop ;

:: next-nth-word/completion ( env n -- )
    env dup get-completion control-value 
    [ n next-nth-completion ] [ n next-nth-word ] if ;

: previous-word ( env -- )  -1 next-nth-word/completion ;
: next-word ( env -- )  +1 next-nth-word/completion ;

: save-skov-image ( env -- )
    [ drop save export-vocabs ] make-keyboard-safe ;

: load-vocabs ( env -- )
    [ update-skov-root skov-root get-global swap set-control-value ] make-keyboard-safe ;

: target/alt ( elt -- factor-word )
    { { [ dup call? ] [ target>> ] }
      { [ dup definition? ] [ alt>> [ f ] [ first ] if-empty ] }
      [ drop f ] } cond ;

: show-help-browser ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value target/alt (browser-window) ] with-interactive-vocabs ]
      [ show-browser ] if* drop
    ] make-keyboard-safe ;
