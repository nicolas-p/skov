USING: accessors help.topics kernel prettyprint words
words.symbol ;
IN: help

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [ name>> ] [ unparse ] if ;
