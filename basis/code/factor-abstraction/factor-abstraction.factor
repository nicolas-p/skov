! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators kernel locals splitting ;
IN: code.factor-abstraction

:: call-from-factor ( factor-word -- call )
    factor-word name>>
    { { [ " (accessor)" ?tail ] [ accessor ] }
      { [ " (mutator)" ?tail ] [ mutator ] }
      { [ " (constructor)" ?tail ] [ constructor ] }
      [ call ]
    } cond new swap >>name
    factor-word >>target ;
