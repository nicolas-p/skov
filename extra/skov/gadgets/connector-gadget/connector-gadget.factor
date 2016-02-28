! Copyright (C) 2015 Nicolas Pénet.
USING: accessors colors combinators combinators.smart kernel locals
namespaces sequences skov.code skov.gadgets
skov.gadgets.connection-gadget skov.theme skov.utilities
ui.gadgets ui.gadgets.worlds ui.gestures ui.pens.image system ;
IN: skov.gadgets.connector-gadget

: selected? ( node-gadget -- ? )
    { { [ dup find-vocab not ] [ drop t ] }
      { [ dup modell>> name>> empty? ] [ drop t ] }
      { [ dup modell>> vocab? ] [ [ find-vocab modell>> ] [ modell>> ] bi eq? ] }
      { [ dup modell>> word? ] [ [ find-env modell>> ] [ modell>> ] bi eq? ] }
      { [ dup modell>> tuple-class? ] [ [ find-env modell>> ] [ modell>> ] bi eq? ] }
    } cond ;

: (node-theme) ( node-gadget -- img-name bg-colour text-colour )
    dup selected?
    [ modell>>
      { { [ dup connector? ] [ drop "connector" dark-background light-text-colour ] }
        { [ dup vocab? ] [ drop "vocab" orange-background dark-text-colour ] }
        { [ dup text? ] [ drop "text" grey-background dark-text-colour ] }
        { [ dup tuple-class? ] [ drop "class" blue-background dark-text-colour ] }
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
        { [ dup tuple-class? ] [ drop "class-faded" faded-background faded-text-colour ] }
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
    connector-gadget find-def children>>
    [ outputs>> [ modell>> connector-gadget modell>> link>> eq? ] filter ] map
    concat first ;

M: connector-gadget connect
    dupd [ swap suffix ] change-links swap [ swap suffix ] change-links drop ;

: proto-connection>> ( definition-gadget -- pc )
    children>> [ proto-connection? ] filter first ;

: create-connection ( connector-gadget -- )
    dup find-def swap hand-gadget get-global [ modell>> ] bi@ ?connect
    parent>> update drop ;

: create-proto-connection ( connector-gadget -- )
    find-def hand-click-loc get-global <proto-connection> add-gadget drop ;

: update-proto-connection ( connector-gadget -- )
    find-def proto-connection>> hand-loc get-global >>loc2 relayout ;

M: connector-gadget graft*
    connector-theme drop ;

M: connector-gadget connected?
    links>> [ connector-gadget? ] any? ;
    
: connector-status-text ( connector-gadget -- str )
    [ modell>> name>> ] [ connected? ] bi [ "     ( x to disconnect )" append ] when ;

connector-gadget H{
    { T{ button-down f f 1 }  [ [ find-def ] [ create-proto-connection ] smart-when* ] }
    { T{ drag }               [ [ find-def ] [ update-proto-connection ] smart-when* ] }
    { T{ button-up f f 1 }    [ [ find-def ] [ create-connection ] smart-when* ] }
    { mouse-enter [ [ connector-status-text ] keep show-status ] }
    { mouse-leave [ hide-status ] }
} set-gestures
