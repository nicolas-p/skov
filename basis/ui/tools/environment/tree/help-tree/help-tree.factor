! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: code code.factor-abstraction kernel models
ui.gadgets.borders ui.tools.environment.theme
ui.tools.environment.tree ;
IN: ui.tools.environment.tree.help-tree

: <help-tree> ( factor-word -- gadget )
    word new swap call-from-factor add-element
    <model> <tree> { 20 10 } <filled-border> with-background ;
