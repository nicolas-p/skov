USING: accessors combinators.short-circuit combinators.smart
compiler.tree.builder.private kernel sequences skov.code
skov.execution compiler.tree ;
QUALIFIED: words
IN: compiler.tree.builder

: build-tree-from-code ( word/quot -- nodes )
    [ f ] dip build-tree-with ;

: build-tree-from-graph ( word/quot -- nodes )
    def>> first ;

: build-tree ( word/quot -- nodes )
    [ { [ words:word? ] [ def>> first sequence? ] [ def>> first [ #call? ] any? ] } 1&& ]
    [ build-tree-from-graph ]
    [ build-tree-from-code ] smart-if ;
