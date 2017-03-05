! Copyright (C) 2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code kernel locals sequences ui.gadgets
ui.gadgets.packs ui.tools.environment.cell ;
IN: ui.tools.environment.tree

TUPLE: space < gadget ;
: <space> ( -- gadget ) space new ;
M: space pref-dim*  drop { 5 0 } ;

:: build-tree ( node -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> { 3 0 } >>gap 1 >>align
        <space> add-gadget
        node contents>> [ build-tree ] map add-gadgets
        <space> add-gadget
    add-gadget
    node <cell> add-gadget ;

:: <inside-tree> ( word -- pile )
    <shelf> word contents>> [ build-tree ] map add-gadgets ;

:: <outside-tree> ( word -- shelf )
    <pile> 1 >>fill 1/2 >>align
    <shelf> { 3 0 } >>gap 1 >>align word introduces [ <cell> ] map add-gadgets add-gadget
    word <cell> add-gadget
    word returns [ first <cell> add-gadget ] unless-empty ;
