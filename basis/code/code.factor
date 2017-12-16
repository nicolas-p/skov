! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators
combinators.short-circuit combinators.smart compiler.units
effects fry hashtables.private kernel listener locals math
math.order math.parser namespaces prettyprint sequences
sequences.deep sequences.extras sets splitting strings
ui.gadgets vectors vocabs.parser ;
QUALIFIED: vocabs
QUALIFIED: definitions
QUALIFIED: words
IN: code

TUPLE: element < identity-tuple  name parent contents default-name ;

TUPLE: vocab < element ;
TUPLE: word < element  defined? alt result ;

TUPLE: node < element  quoted? ;
TUPLE: introduce < node  id ;
TUPLE: return < node ;
TUPLE: call < node  target completion ;
TUPLE: text < node ;
TUPLE: setter < node  id ;
TUPLE: getter < node  id ;

TUPLE: result < element ;

UNION: input/output  introduce return ;
UNION: link  setter getter ;
UNION: source  introduce text getter ;
UNION: sink  return setter ;

PREDICATE: quoted-node < node  quoted?>> ;

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

: walk ( node -- seq )
    [ contents>> [ walk ] map ] [ ] bi 2array ;

: sort-tree ( word -- seq )
    contents>> [ walk ] map flatten ;

: vocabs ( elt -- seq )  contents>> [ vocab? ] filter ;
: words ( elt -- seq )  contents>> [ word? ] filter ;
: calls ( elt -- seq )  sort-tree [ call? ] filter ;
: introduces ( elt -- seq )  sort-tree [ introduce? ] filter ;
: returns ( elt -- seq )  contents>> [ return? ] filter ;
: links ( elt -- seq )  sort-tree [ link? ] filter ;

: own-introduces ( elt -- seq )
    ! returns all "introduce" nodes in the child tree but ignores quoted nodes
    contents>> [ [ introduce? ] filter ]
    [ [ quoted?>> ] reject [ own-introduces ] map-concat ] bi
    append ;

:: add-element ( parent child -- parent )
    ! sets an existing element as the child of another existing element
    child parent >>parent parent [ ?push ] change-contents ;

: add-from-class ( parent child-class -- parent )
    ! sets a new element of a certain class as the child of an existing element
    new add-element ;

: add-with-name ( parent child-name child-class -- parent )
    ! sets a new element of a certain class and with a certain name
    ! as the child of an existing element
    new swap >>name add-element ;

: remove-from-parent ( child -- parent )
    ! removes a node from its parent
    dup parent>> [ contents>> remove-eq! drop ] keep ;

: replace* ( seq old rep -- seq )
    ! replaces an element with another element in a sequence
    [ 1array ] bi@ replace ;

:: replace-element ( old rep -- rep )
    ! replaces an element with another element
    old parent>>
    [ old rep old parent>> >>parent replace* ] change-contents drop rep ;

: replace-with-new-parent ( old class -- new )
    ! replaces an element with a new element of a certain class
    ! and sets the old element as a child of the new one
    dupd new replace-element swap add-element ;

: top-node? ( node -- ? )
    ! tells if the node has no children
    contents>> empty? ;

: bottom-node? ( node -- ? )
    ! tells if the node has no parent
    parent>> node? not ;

: middle-node? ( node -- ? )
    ! tells if a node has a parent and has children
    [ top-node? ] [ bottom-node? ] bi or not ;

: parent-node ( node -- node )
    ! returns the parent of the node, or the same node if the parent is a "word"
    [ parent>> word? ] [ parent>> ] smart-unless ;

: child-node ( node -- node )
    ! returns the first child of the node, or the same node if it has no children
    [ contents>> empty? ] [ contents>> first ] smart-unless ;

:: left-node ( node -- node )
    ! returns the brother node on the left, or the same node if there is nothing to the left
    node parent>> contents>> :> nodes
    node nodes index 1 -
    dup neg? [ drop node ] [ nodes nth ] if ;

:: right-node ( node -- node )
    ! returns the brother node on the right, or the same node if there is nothing to the right
    node parent>> contents>> :> nodes
    node nodes index 1 +
    dup nodes length = [ drop node ] [ nodes nth ] if ;

: arity ( node -- n )
    ! returns the number of children of a node
    contents>> length ;

:: change-nodes-above ( elt names -- )
    elt arity :> old-n
    names length :> n
    elt {
      { [ n old-n > ] [ n old-n - [ call add-from-class ] times drop ] }
!     { [ n old-n < ] [ contents>> n swap shorten ] }
      [ drop ]
    } cond
    names elt contents>> [ default-name<< ] 2each ;

: insert-node ( node -- new-node )
    ! replaces a node with a new "call" which has the node as a child
    call replace-with-new-parent ;

:: insert-node-left ( node -- new-node )
    ! inserts a new "call" to the left of a node
    node parent>> contents>> :> nodes
    call new node parent>> >>parent dup :> new-node
    node nodes index
    nodes insert-nth! new-node ;

:: insert-node-right ( node -- new-node )
    ! inserts a new "call" to the right of a node
    node parent>> contents>> :> nodes
    call new node parent>> >>parent dup :> new-node
    node nodes index 1 +
    nodes insert-nth! new-node ;

: remove-node ( node -- parent/child )
    ! removes a node from its parent if the node has no children,
    ! otherwise replaces the node by its first child
    [ contents>> empty? ]
    [ remove-from-parent ]
    [ dup child-node replace-element ] smart-if ;

:: change-node-type ( elt class -- new-elt )
    ! replaces a node by a node of a different type that has the same name and contents
    elt class new elt name>> >>name elt contents>> [ add-element ] each replace-element ;

: no-return? ( node -- ? )
    ! tells if the word that contains the node has no "return" child
    [ word? ] find-parent returns empty? ;

: ?change-node-type ( elt class -- new-elt )
    ! replaces a node by a node of a different type that has the same name and contents
    ! only if certain conditions are met
    2dup {
        { introduce [ top-node? ] }
        { text      [ top-node? ] }
        { getter    [ top-node? ] }
        { return    [ [ bottom-node? ] [ no-return? ] bi and ] }
        { setter    [ bottom-node? ] }
        [ drop drop t ]
    } case [ change-node-type ] [ drop ] if ;

: name-or-default ( elt -- str )
    ! returns the name of the element, or its default name, or its class
    { { [ dup name>> empty? not ] [ name>> ] }
      { [ dup default-name>> empty? not ] [ default-name>> ] }
      { [ dup introduce? ] [ drop "input" ] }
      { [ dup return? ] [ drop "output" ] }
      { [ dup call? ] [ drop "word" ] }
      { [ dup getter? ] [ drop "get" ] }
      { [ dup setter? ] [ drop "set" ] }
      [ class-of unparse ] } cond >string ;

CONSTANT: special-words { "while" "until" "if" "times" "produce" }
GENERIC: factor-name ( elt -- str )

M: element factor-name
    name>> ;

M: call factor-name
    name>> dup special-words member? [ "special " swap prepend ] when ;

GENERIC: path ( elt -- str )

M: vocab path
    parents reverse rest [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: word path
    parents reverse rest but-last [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: call path
    target>> [ words:word? ] [ vocabulary>> ] [ drop f ] smart-if ;

M: node path
    drop f ;

: replace-quot ( seq -- seq )
    [ array? ] [ first [ "quot" swap subseq? not ] [ " quot" append ] smart-when ] smart-when ;

: convert-stack-effect ( stack-effect -- seq seq )
    ! converts a stack effect into two sequences of input and output names
    [ in>> ] [ out>> ] bi [ [ replace-quot ] map ] bi@ ;

: same-name-as-parent? ( call -- ? )
    ! tells if a call has the same name as its parent
    dup [ word? ] find-parent [ name>> ] bi@ = ;

: input-output-names ( word -- seq seq )
    ! returns two sequences containing the input and output names of a word
    [ introduces ] [ returns ] bi [ [ name>> ] map members ] bi@ ;

SINGLETON: recursion

GENERIC: (in-out) ( elt -- seq seq )

M: source (in-out)
    drop f { "" } ;

M: sink (in-out)
    drop { "" } f ;

M:: call (in-out) ( call -- seq seq )
    call target>>
    { { [ dup recursion? ] [ drop call parent>> input-output-names ] }
      { [ dup number? ] [ drop { } { "" } ] }
      { [ dup not ] [ drop { } { } ] }
      [ "declared-effect" words:word-prop convert-stack-effect ]
    } cond ;

CONSTANT: sequence-variadic-words { "array" } ! "sequence" "each" "map" "append" "produce" }
CONSTANT: special-variadic-words { "call" }

: simple-variadic? ( call -- ? )
    (in-out) { [ drop length 2 = ] [ nip length 1 = ]
        [ first swap first2 dupd = -rot = and ] } 2&& ;

: comparison-variadic? ( call -- ? )
    (in-out) [ length 2 = ] [ ?first "?" = ] bi* and ;

: sequence-variadic? ( call -- ? )
    name>> sequence-variadic-words member? ;

: special-variadic? ( call -- ? )
    name>> special-variadic-words member? ;

: variadic? ( call -- ? )
    { [ simple-variadic? ] [ comparison-variadic? ]
      [ sequence-variadic? ] [ special-variadic? ] } cleave or or or ;

:: in-out ( elt -- seq seq )
    { { [ elt call? not ] [ elt (in-out) ] }
      { [ elt simple-variadic? ]
        [ elt (in-out) [ first [  ] curry elt arity 2 max swap replicate ] dip ] }
      { [ elt sequence-variadic? ]
        [ elt arity 1 max [ "x" ] replicate { "seq" } ] }
      { [ elt name>> "call" = ]
        [ f elt arity 1 - [ "x" suffix ] times "quot" suffix { "result" } ] }
      [ elt (in-out) ]
    } cond ;

:: matching-words ( str -- seq )
    ! returns all Factor words whose name begins with a certain string
    interactive-vocabs get [ vocabs:vocab-words ] map concat [ name>> str head? ] filter ;

:: matching-words-exact ( str -- seq )
    ! returns all Factor words that have a certain name
    interactive-vocabs get [ vocabs:vocab-words ] map concat [ name>> str = ] filter ;

:: find-target ( call -- seq )
    ! returns the Factor word that has the same name as the call
    call factor-name :> name
    { { [ call same-name-as-parent? ] [ recursion 1array ] }
      { [ name string>number ] [ name string>number 1array ] }
      [ name matching-words-exact ]
    } cond ;

: (un)quote ( node -- node )
    ! toggles the "quoted?" attribute of a node
    [ not ] change-quoted? ;

:: ?add-words-above ( elt -- )
    elt elt in-out drop change-nodes-above
    elt contents>> [ ?add-words-above ] each ;

:: ?add-word-below ( elt -- )
    elt in-out nip [ first elt insert-node default-name<< ] unless-empty ;

:: ?add-words ( word -- word )
    word contents>>
    [ word call add-from-class drop ]
    [ [ dup ?add-word-below ?add-words-above ] each ]
    if-empty word ;

: any-empty-name? ( word -- ? )
    ! tells if there are any empty names in the child tree of a word
    sort-tree
    [ [ introduce? ] [ [ quoted-node? ] find-parent ] bi and ] reject
    [ name>> empty? ] any? ;

: executable? ( word -- ? )
    ! tells if a word has the right properties to be executable
   { [ word? ]
     [ introduces [ [ quoted-node? ] find-parent ] reject empty? ]
     [ returns empty? ]
     [ calls empty? not ]
     [ any-empty-name? not ]
     [ defined?>> ]
   } 1&& ;

: error? ( word -- ? )
    ! tells if a word contains any error
    { [ defined?>> not ]
      [ any-empty-name? ] 
      [ contents>> empty? ]
    } 1|| ;

: save-result ( str word  -- )
    ! stores a string as the result of a word
    swap dupd result new swap >>contents swap >>parent >>result drop ;

: forget-alt ( vocab/word -- )
    ! deletes the Factor vocabulary or word that corresponds to the element
    { { [ dup vocab? ] [ path [ vocabs:forget-vocab ] with-compilation-unit ] }
      { [ dup word? ] [ alt>> [ [ definitions:forget ] with-compilation-unit ] each ] }
      [ drop ]
    } cond ;

: target/alt ( elt -- factor-word )
    { { [ dup call? ] [ target>> ] }
      { [ dup word? ] [ alt>> [ f ] [ first ] if-empty ] }
      [ drop f ] } cond ;
