! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays code code.factor-abstraction kernel
locals sequences ui.gadgets.borders ui.tools.environment.theme
ui.tools.environment.tree ;
IN: ui.tools.environment.tree.help-tree

:: <help-tree> ( factor-word -- gadget )
    word new
    factor-word call-from-factor dup in-out :> ( in out )
    in [ introduce new swap >>name ] map >>contents
    out [ return new swap >>name swap 1array >>contents ] unless-empty
    1array >>contents
    <inside-tree> { 20 10 } <filled-border> with-background ;
