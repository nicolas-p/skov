! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.environment.common
ui.tools.environment.cell ui.gadgets ;
FROM: code => inputs outputs ;
IN: ui.tools.environment.tree

:: <tree> ( node -- shelf )
    <shelf>
    <pile> node contents>> [ <tree> ] map add-gadgets add-gadget
    node add-gadget ;
