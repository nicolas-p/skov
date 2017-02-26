! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code colors combinators
combinators.short-circuit combinators.smart kernel sequences
system ui.tools.environment.common ui.tools.environment.theme ui.gadgets
ui.pens.image ui.pens.tile ;
FROM: code => inputs outputs call ;
IN: ui.tools.environment.cell.theme

CONSTANT: min-cell-size 28

: selected? ( cell -- ? )
    { { [ dup find-vocab not ] [ drop t ] }
      { [ dup control-value name>> empty? ] [ drop t ] }
      { [ dup control-value vocab? ] [ [ find-env vocab-control-value ] [ control-value ] bi eq? ] }
      { [ dup control-value definition? ] [ [ find-env control-value ] [ control-value ] bi eq? ] }
    } cond ;

: (cell-theme) ( cell -- img-name bg-colour text-colour )
    dup selected?
    [ control-value
      { { [ dup input/output? ] [ drop "connector" dark-background light-text-colour ] }
        { [ dup vocab? ] [ drop "vocab" orange-background dark-text-colour ] }
        { [ dup text? ] [ drop "text" grey-background dark-text-colour ] }
        { [ dup constructor? ] [ drop "constructor" green-background dark-text-colour ] }
        { [ dup accessor? ] [ drop "accessor" green-background dark-text-colour ] }
        { [ dup mutator? ] [ drop "mutator" green-background dark-text-colour ] }
        { [ dup call? ] [ drop "word" green-background dark-text-colour ] }
        { [ dup word? ] [ drop "word" green-background dark-text-colour ] }
      } cond
    ] [ control-value
      { { [ dup vocab? ] [ drop "vocab-faded" faded-background faded-text-colour ] }
        { [ dup call? ] [ drop "word-faded" faded-background faded-text-colour ] }
        { [ dup word? ] [ drop "word-faded" faded-background faded-text-colour ] }
        { [ dup class? ] [ drop "class-faded" faded-background faded-text-colour ] }
      } cond ] if
    [ os windows? not [ drop transparent ] when ] dip ;

: cell-theme ( cell -- cell )
    dup (cell-theme)
    [ "left" "middle" "right" [ 2-theme-image ] tri-curry@ tri ] 2dip
    <tile-pen> >>interior
    horizontal >>orientation ;

: connector-theme ( connector -- connector )
    dup [ control-value node? not ] 
    [ drop "special" ]
    [ parent>> (cell-theme) 2drop ] smart-if
    "connector" 2-theme-image <image-pen> t >>fill? >>interior ;
