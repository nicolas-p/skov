USING: accessors arrays assocs classes code.factor-abstraction
combinators generic help.markup help.topics kernel make
namespaces prettyprint words words.symbol ;
IN: help

M: word article-name name>> explicit-clean-name ;

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [ name>> ] [ unparse ] if explicit-clean-name ;

<PRIVATE

: (word-help) ( word -- element )
    [
        {
            [ \ $vocabulary swap 2array , ]
            [ \ $graph swap 2array , ]
            [ word-help % ]
            [ \ $related swap 2array , ]
            [ dup global at [ get-global \ $value swap 2array , ] [ drop ] if ]
        } cleave
    ] { } make ;

PRIVATE>

M: generic article-content (word-help) ;

M: class article-content (word-help) ;
