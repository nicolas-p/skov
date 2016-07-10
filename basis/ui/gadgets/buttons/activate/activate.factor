! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.smart fry help.topics
kernel listener locals models namespaces sequences
ui.gadgets.buttons.round strings ui.gadgets ui.gadgets.packs vocabs
words ;
IN: ui.gadgets.buttons.activate

: interactive? ( vocab-name -- ? )
    interactive-vocabs get-global member? ;

: vocab-name ( obj -- str )
    name>> [ word? ] [ vocabulary>> ] smart-when ;

: add-interactive-vocab ( vocab-name -- )
    [ interactive? not ] 
    [ interactive-vocabs [ swap suffix ] change-global ] smart-when* ;

: remove-interactive-vocab ( vocab-name -- )
    interactive-vocabs [ remove ] change-global ;

: <activate-button> ( vocab-name -- gadget )
    dup '[ _ swap [ not ] change-selected? 
      selected?>> [ add-interactive-vocab ] [ remove-interactive-vocab ] if 
    ] "activate" <word-button>
    swap interactive? >>selected? "Activate / Deactivate" >>tooltip ;

TUPLE: active/inactive < pack ;

: <active/inactive> ( model -- gadget )
    active/inactive new swap >>model ;
    
: vocab/word? ( obj -- ? )
    [ vocab? ] [ [ link? ] [ name>> word? ] [ drop f ] smart-if ] bi or ;

M: active/inactive model-changed
    dup clear-gadget swap
    value>> [ vocab/word? ]
    [ vocab-name <activate-button> add-gadget ] smart-when* drop ;
