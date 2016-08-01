! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.import-export combinators
combinators.smart continuations effects kernel locals math
math.parser quotations regexp sequences splitting strings ;
FROM: code => inputs outputs return ;
QUALIFIED: words
IN: code.factor-abstraction

: remove-<> ( str -- str )
    ">" "" replace
    "<" "" replace ;

: explicit-clean-name ( str -- str )
    R/ .{2,}-.{2,}/ [ "-" " " replace ] re-replace-with
    R/ .+>>/ [ remove-<> " (accessor)" append ] re-replace-with
    R/ >>.+/ [ remove-<> " (mutator)" append ] re-replace-with
    R/ <.+>/ [ remove-<> " (constructor)" append ] re-replace-with
    R/ >.+</ [ remove-<> " (destructor)" append ] re-replace-with ;

:: word-from-factor ( factor-word -- word )
    factor-word name>> explicit-clean-name
    { { [ dup " (accessor)" tail? ] [ " (accessor)" "" replace accessor ] }
      { [ dup " (mutator)" tail? ] [ " (mutator)" "" replace mutator ] }
      { [ dup " (constructor)" tail? ] [ " (constructor)" "" replace constructor ] }
      { [ dup " (destructor)" tail? ] [ " (destructor)" "" replace destructor ] }
      [ word ]
    } cond new swap >>name
    factor-word >>target
    add-connectors ;

CONSTANT: stack-shufflers [ drop 2drop 3drop nip 2nip dup 2dup 3dup 
    over 2over pick swap dupd swapd rot -rot ]

:: process-node* ( stack node-list node -- stack node-list )
    node [ words:word? ] [ stack-effect [ in>> ] [ out>> ] bi [ length ] bi@ ] [ 0 1 ] smart-if*
    :> nout :> nin
    nout [ words:gensym ] replicate :> out
    stack nin cut* :> in out append
    node-list node
    { { [ dup words:word? ] [ word-from-factor ] }
      { [ dup string? ] [ drop text new node >>name add-connectors ] }
      { [ dup number? ] [ drop word new node number>string >>name node >>target add-connectors ] } 
    } cond dup
    [ inputs in [ >>link drop ] 2each ]
    [ outputs out [ >>id drop ] 2each ] bi
    add-element ;

:: process-node ( stack node-list node -- stack node-list )
    node stack-shufflers member?
    [ stack node 1quotation with-datastack node-list ]
    [ stack node-list node process-node* ] if ;

:: word-definition-from-factor ( factor-word -- word-definition )
    factor-word stack-effect :> effect
    effect in>> [ drop words:gensym ] map :> stack
    stack
    word-definition new
    stack effect in>> [ introduce new swap >>name add-connectors dup outputs first rot >>id drop add-element ] 2each
    factor-word def>> [ process-node ] each
    swap effect out>> [ return new swap >>name add-connectors dup inputs first rot >>link drop add-element ] 2each
    ids>links ;
