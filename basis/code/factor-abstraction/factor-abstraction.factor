! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.import-export combinators
combinators.smart continuations effects kernel locals math
math.parser quotations regexp sequences splitting stack-checker
strings ;
FROM: code => inputs outputs return ;
QUALIFIED: words
IN: code.factor-abstraction

:: word-from-factor ( factor-word -- word )
    factor-word name>>
    { { [ " (accessor)" ?tail ] [ accessor ] }
      { [ " (mutator)" ?tail ] [ mutator ] }
      { [ " (constructor)" ?tail ] [ constructor ] }
      { [ " (destructor)" ?tail ] [ destructor ] }
      [ word ]
    } cond new swap >>name
    factor-word >>target
    add-connectors ;

CONSTANT: stack-shufflers [ drop 2drop 3drop nip 2nip dup 2dup 3dup 
    over 2over pick swap dupd swapd rot -rot ]

:: process-node ( stack node-list node -- stack node-list )
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

:: process-shuffler ( stack node-list node -- stack node-list )
    node stack-shufflers member?
    [ stack node 1quotation with-datastack node-list ]
    [ stack node-list node process-node ] if ;

:: process-quotation ( stack node-list node -- stack node-list )
    node quotation?
    [ stack node infer in>> length [ words:gensym ] replicate append
      node-list node [ process-quotation ] each ]
    [ stack node-list node process-shuffler ] if ;

:: word-definition-from-factor ( factor-word -- word-definition )
    factor-word stack-effect :> effect
    effect in>> [ drop words:gensym ] map :> stack
    stack
    word-definition new
    stack effect in>> [ introduce new swap >>name add-connectors dup outputs first rot >>id drop add-element ] 2each
    factor-word def>> [ process-quotation ] each
    swap effect out>> [ return new swap >>name add-connectors dup inputs first rot >>link drop add-element ] 2each
    ids>links ;
