USING: accessors combinators.short-circuit combinators.smart
compiler.tree.builder.private kernel sequences skov.code
skov.execution ;
QUALIFIED: words
IN: compiler.tree.builder

: build-tree-from-code ( word/quot -- nodes )
    [ f ] dip build-tree-with ;

: build-tree-from-graph ( word/quot -- nodes )
    def>> first transform ;

: build-tree ( word/quot -- nodes )
    [ { [ words:word? ] [ def>> first word-definition? ] } 1&& ]
    [ build-tree-from-graph ]
    [ build-tree-from-code ] smart-if ;
