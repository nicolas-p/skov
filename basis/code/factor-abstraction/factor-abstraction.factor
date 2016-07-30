! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators kernel locals regexp sequences
splitting ;
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
    vocab new >>parent
    factor-word >>target
    add-connectors ;
