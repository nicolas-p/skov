! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors locals sequences ui.gadgets ui.gadgets.packs
ui.tools.environment.cell ui.tools.environment.common ;
IN: ui.tools.environment.tree

:: build-tree ( node -- shelf )
    <shelf> { 3 3 } >>gap 1 >>fill
    <pile> { 3 3 } >>gap 1 >>align node contents>> [ build-tree ] map add-gadgets add-gadget
    node <cell> add-gadget ;

:: <tree> ( word -- pile )
    <pile> word contents>> [ build-tree ] map add-gadgets ;
