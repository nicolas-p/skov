! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators
combinators.short-circuit combinators.smart kernel locals models
namespaces sequences code ui.environment
ui.environment.connection-gadget ui.environment.theme  system
ui.gadgets ui.gadgets.worlds ui.gestures ui.pens.image ;
FROM: code => inputs outputs ;
IN: ui.environment.connector-gadget

: selected? ( node-gadget -- ? )
    { { [ dup find-vocab not ] [ drop t ] }
      { [ dup control-value name>> empty? ] [ drop t ] }
      { [ dup control-value vocab? ] [ [ find-env vocab-control-value ] [ control-value ] bi eq? ] }
      { [ dup control-value definition? ] [ [ find-env control-value ] [ control-value ] bi eq? ] }
    } cond ;

: (node-theme) ( node-gadget -- img-name bg-colour text-colour )
    dup selected?
    [ control-value
      { { [ dup connector? ] [ drop "connector" dark-background light-text-colour ] }
        { [ dup vocab? ] [ drop "vocab" orange-background dark-text-colour ] }
        { [ dup text? ] [ drop "text" grey-background dark-text-colour ] }
        { [ dup tuple-definition? ] [ drop "class" blue-background dark-text-colour ] }
        { [ dup slot? ] [ drop "slot" blue-background dark-text-colour ] }
        { [ dup constructor? ] [ drop "constructor" green-background dark-text-colour ] }
        { [ dup destructor? ] [ drop "destructor" green-background dark-text-colour ] }
        { [ dup accessor? ] [ drop "accessor" green-background dark-text-colour ] }
        { [ dup mutator? ] [ drop "mutator" green-background dark-text-colour ] }
        { [ dup word? ] [ drop "word" green-background dark-text-colour ] }
        { [ dup word-definition? ] [ drop "word" green-background dark-text-colour ] }
      } cond
    ] [ control-value
      { { [ dup vocab? ] [ drop "vocab-faded" faded-background faded-text-colour ] }
        { [ dup word? ] [ drop "word-faded" faded-background faded-text-colour ] }
        { [ dup word-definition? ] [ drop "word-faded" faded-background faded-text-colour ] }
        { [ dup tuple-definition? ] [ drop "class-faded" faded-background faded-text-colour ] }
      } cond ] if
    [ os windows? not [ drop transparent ] when ] dip ;

: <connector-gadget> ( value -- connector-gadget )
    <model> connector-gadget new swap >>model connector-size dup 2array >>dim ;

: connector-theme ( connector-gadget -- connector-gadget )
    dup [ control-value { [ node? not ] [ invisible?>> ] } 1&& ] 
    [ drop "special" ]
    [ parent>> (node-theme) 2drop ] smart-if
    "connector" 2-theme-image <image-pen> t >>fill? >>interior ;

:: link ( connector-gadget -- connector-gadget )
    connector-gadget find-graph children>>
    [ outputs [ control-value connector-gadget control-value link>> eq? ] filter ] map
    concat first ;

: add-connections ( graph -- graph )
    dup connections [ unparent ] each
    dup nodes
    [ inputs
      [ control-value connected? ] filter
      [ dup link 2dup connect <connection-gadget> ] map
    ] map concat [ add-gadget ] each ;

M: connector-gadget connect
    dupd [ swap suffix ] change-links swap [ swap suffix ] change-links drop ;

: proto-connection>> ( definition-gadget -- pc )
    children>> [ proto-connection? ] filter first ;

: create-connection ( connector-gadget -- )
    dup hand-gadget get-global
    [ [ connector-gadget? ] bi@ and ]
    [ [ control-value ] bi@ ?connect ] smart-when*
    find-env [ ] change-control-value ;

: display-proto-connection ( connector-gadget -- )
    hand-click-loc get-global <proto-connection> add-gadget drop ;

: update-proto-connection ( connector-gadget -- )
    proto-connection>> hand-loc get-global >>loc2 relayout ;

M: connector-gadget graft*
    connector-theme drop ;

M: connector-gadget connected?
    links>> [ connector-gadget? ] any? ;

: connector-status-text ( connector-gadget -- str )
    [ control-value name>> ] [ connected? ] bi [ "     ( X  disconnect )" append ] when ;

: make-bigger ( connector-gadget -- connector-gadget )
    "big" "connector" 2-theme-image <image-pen> t >>fill? >>interior ;

: make-smaller ( connector-gadget -- connector-gadget )
    connector-theme ;

connector-gadget H{
    { T{ button-down f f 1 }  [ [ find-vocab not ] [ display-proto-connection ] smart-when* ] }
    { T{ drag }               [ [ find-vocab not ] [ update-proto-connection ] smart-when* ] }
    { T{ button-up f f 1 }    [ [ find-vocab not ] [ create-connection ] smart-when* ] }
    { mouse-enter [ [ make-bigger connector-status-text ] keep show-status ] }
    { mouse-leave [ make-smaller hide-status ] }
} set-gestures
