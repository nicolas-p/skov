! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators combinators.smart effects
kernel locals math math.parser sequences splitting strings words vectors ;
FROM: code => call word ;
IN: code.factor-abstraction

:: call-from-factor ( factor-word -- call )
    factor-word name>>
    { { [ " (accessor)" ?tail ] [ accessor ] }
      { [ " (mutator)" ?tail ] [ mutator ] }
      { [ " (constructor)" ?tail ] [ constructor ] }
      [ call ]
    } cond new swap >>name
    factor-word >>target ;

: node-from-factor ( factor-word -- node )
    { { [ dup words:word? ] [ call-from-factor ] }
      { [ dup string? ] [ text new >>name ] }
      { [ dup number? ] [ call new swap [ number>string >>name ] keep >>target ] } 
    } cond ;

: make-tree ( nodes -- tree )
    dup pop dup in-out drop length
    swapd [ dup make-tree ] replicate reverse nip [ add-element ] each ;

:: word-from-factor ( factor-word -- word )
    factor-word stack-effect
    [ in>> [ introduce new swap >>name ] map ]
    [ out>> [ return new swap >>name ] map ] bi
    factor-word def>> [ node-from-factor ] map
    swap 3append >vector make-tree
    word new swap add-element ;
