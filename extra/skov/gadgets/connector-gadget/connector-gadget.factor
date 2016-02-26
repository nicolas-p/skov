! Copyright (C) 2015 Nicolas Pénet.
USING: accessors colors combinators combinators.smart kernel locals
namespaces sequences skov.code skov.gadgets
skov.gadgets.connection-gadget skov.theme skov.utilities
ui.gadgets ui.gadgets.worlds ui.gestures ui.pens.image system ;
IN: skov.gadgets.connector-gadget

: in-vocab? ( node-gadget -- ? )
    [ vocab-gadget? ] find-parent ;

: selected? ( node-gadget -- ? )
    { { [ dup in-vocab? not ] [ drop t ] }
      { [ dup modell>> name>> empty? ] [ drop t ] }
      { [ dup modell>> vocab? ] [ [ [ vocab-gadget? ] find-parent modell>> ] [ modell>> ] bi eq? ] }
      { [ dup modell>> word? ] [ [ [ environment-gadget? ] find-parent modell>> ] [ modell>> ] bi eq? ] }
      { [ dup modell>> tuplee? ] [ [ [ environment-gadget? ] find-parent modell>> ] [ modell>> ] bi eq? ] }
    } cond ;

: (node-theme) ( node-gadget -- img-name bg-colour text-colour )
    dup selected?
    [ modell>>
      { { [ dup connector? ] [ drop "connector" dark-background light-text-colour ] }
        { [ dup vocab? ] [ drop "vocab" orange-background dark-text-colour ] }
        { [ dup text? ] [ drop "text" grey-background dark-text-colour ] }
        { [ dup tuplee? ] [ drop "class" blue-background dark-text-colour ] }
        { [ dup slot? ] [ drop "slot" dark-background light-text-colour ] }
        { [ dup constructor? ] [ drop "constructor" green-background dark-text-colour ] }
        { [ dup destructor? ] [ drop "destructor" green-background dark-text-colour ] }
        { [ dup accessor? ] [ drop "accessor" green-background dark-text-colour ] }
        { [ dup mutator? ] [ drop "mutator" green-background dark-text-colour ] }
        { [ dup word? ] [ drop "word" green-background dark-text-colour ] }
      } cond
    ] [ modell>>
      { { [ dup vocab? ] [ drop "vocab-faded" faded-background faded-text-colour ] }
        { [ dup word? ] [ drop "word-faded" faded-background faded-text-colour ] }
        { [ dup tuplee? ] [ drop "class-faded" faded-background faded-text-colour ] }
      } cond ] if
    [ os windows? not [ drop transparent ] when ] dip ;

:: <connector-gadget> ( model -- connector-gadget )
    connector-gadget new model >>modell { 8 8 } >>dim ;

: connector-theme ( connector-gadget -- connector-gadget )
    dup [ modell>> special-connector? ] 
    [ drop "special" ] 
    [ parent>> (node-theme) 2drop ] smart-if 
    "connector" 2-theme-image <image-pen> t >>fill? >>interior ;

:: link ( connector-gadget -- connector-gadget )
    connector-gadget parent>> parent>> children>>
    [ outputs>> [ modell>> connector-gadget modell>> link>> eq? ] filter ] map
    concat first ;

M: connector-gadget connect
    dupd [ swap suffix ] change-links swap [ swap suffix ] change-links drop ;

: proto-connection>> ( definition-gadget -- pc ) children>> [ proto-connection? ] filter first ;

: create-connection ( connector-gadget -- )
    dup parent>> parent>> swap
    hand-gadget get-global [ modell>> ] bi@ ?connect
    update drop ;

: create-proto-connection ( connector-gadget -- )
    [ definition-gadget? ] find-parent
    hand-click-loc get-global <proto-connection> add-gadget drop ;

: update-proto-connection ( connector-gadget -- )
    parent>> parent>> proto-connection>> hand-loc get-global >>loc2 relayout ;

: inside-word? ( connector-gadget -- ? )
    parent>> parent>> definition-gadget? ;

M: connector-gadget graft*
    connector-theme drop ;

M: connector-gadget connected?
    links>> [ connector-gadget? ] any? ;
    
: connector-status-text ( connector-gadget -- str )
    [ modell>> name>> ] [ connected? ] bi [ "     ( d to disconnect )" append ] when ;

connector-gadget H{
    { T{ button-down f f 1 }  [ [ inside-word? ] [ create-proto-connection ] smart-when* ] }
    { T{ drag }               [ [ inside-word? ] [ update-proto-connection ] smart-when* ] }
    { T{ button-up f f 1 }    [ [ inside-word? ] [ create-connection ] smart-when* ] }
    { mouse-enter [ [ connector-status-text ] keep show-status ] }
    { mouse-leave [ hide-status ] }
} set-gestures
