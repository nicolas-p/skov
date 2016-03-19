USING: accessors arrays assocs combinators help.markup
help.topics kernel make namespaces prettyprint words
words.symbol ;
IN: help

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [ name>> ] [ unparse ] if ;

<PRIVATE

: (word-help) ( word -- element )
    [
        {
            [ \ $vocabulary swap 2array , ]
            [ word-help % ]
            [ \ $related swap 2array , ]
            [ dup global at [ get-global \ $value swap 2array , ] [ drop ] if ]
        } cleave
    ] { } make ;

PRIVATE>
