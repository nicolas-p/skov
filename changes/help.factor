USING: accessors arrays assocs combinators help.markup
help.topics kernel make namespaces prettyprint regexp splitting
words words.symbol ;
IN: help

: skov-name ( str -- str )
    R/ .{2,}-.{2,}/ [ "-" " " replace ] re-replace-with ;

M: word article-name name>> skov-name ;

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [ name>> ] [ unparse ] if skov-name ;

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
