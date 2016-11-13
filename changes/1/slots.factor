USING: kernel sequences words ;
IN: slots

: reader-word ( name -- word )
    " (accessor)" append "accessors" create-word
    dup t "reader" set-word-prop ;

: writer-word ( name -- word )
    " (writer)" append "accessors" create-word
    dup t "writer" set-word-prop ;

: setter-word ( name -- word )
    " (mutator)" append "accessors" create-word ;

: changer-word ( name -- word )
    "change " prepend "accessors" create-word ;
