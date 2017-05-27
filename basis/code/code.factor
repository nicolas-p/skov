! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators
combinators.short-circuit combinators.smart compiler.units
effects fry hashtables.private kernel listener locals math
math.parser namespaces prettyprint sequences sequences.deep
sequences.extras sets splitting strings ui.gadgets vectors
vocabs.parser ;
QUALIFIED: vocabs
QUALIFIED: definitions
QUALIFIED: words
IN: code

TUPLE: element < identity-tuple  name parent contents default-name ;

TUPLE: vocab < element ;
TUPLE: word < element  defined? alt result ;

TUPLE: node < element ;
TUPLE: introduce < node  id ;
TUPLE: return < node ;
TUPLE: call < node  target ;
TUPLE: text < node ;
TUPLE: constructor < call ;
TUPLE: accessor < call ;
TUPLE: mutator < call ;
TUPLE: subtree < node ;
TUPLE: setter < node  id ;
TUPLE: getter < node  id ;

TUPLE: result < element ;

UNION: input/output  introduce return ;
UNION: link  setter getter ;
UNION: source  introduce text getter ;
UNION: sink  return setter ;

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

:: add-element ( parent child -- parent )
     child parent >>parent parent [ ?push ] change-contents ;

: add-from-class ( parent child-class -- parent )
     new add-element ;

: add-with-name ( parent child-name child-class -- parent )
     new swap >>name add-element ;

: remove-from-parent ( child -- parent )
     dup parent>> [ contents>> remove-eq! drop ] keep ;

: replace* ( seq old rep -- seq )
    [ 1array ] bi@ replace ;

:: replace-element ( old rep -- rep )
     old parent>>
     [ old rep old parent>> >>parent replace* ] change-contents drop rep ;

: replace-with-new-parent ( old class -- new )
    dupd new replace-element swap add-element ;

:: change-name ( str pair -- str )
    str pair first = [ pair second ] [ str ] if ;

: top-node? ( node -- ? )
    contents>> empty? ;

: bottom-node? ( node -- ? )
    parent>> node? not ;

: middle-node? ( node -- ? )
    [ top-node? ] [ bottom-node? ] bi or not ;

: parent-node ( node -- node )
    [ parent>> word? ] [ parent>> ] smart-unless ;

: child-node ( node -- node )
    [ contents>> empty? ] [ contents>> first ] smart-unless ;

:: left-node ( node -- node )
    node parent>> contents>> :> nodes
    node nodes index 1 -
    dup neg? [ drop node ] [ nodes nth ] if ;

:: right-node ( node -- node )
    node parent>> contents>> :> nodes
    node nodes index 1 +
    dup nodes length = [ drop node ] [ nodes nth ] if ;

:: change-nodes-above ( elt names -- )
    elt contents>> length :> old-n
    names length :> n
    elt {
      { [ n old-n > ] [ n old-n - [ call add-from-class ] times drop ] }
!     { [ n old-n < ] [ contents>> n swap shorten ] }
      [ drop ]
    } cond
    names elt contents>> [ default-name<< ] 2each ;

: insert-node ( node -- new-node )
    call replace-with-new-parent ;

:: insert-node-left ( node -- new-node )
    node parent>> contents>> :> nodes
    call new node parent>> >>parent dup :> new-node
    node nodes index
    nodes insert-nth! new-node ;

:: insert-node-right ( node -- new-node )
    node parent>> contents>> :> nodes
    call new node parent>> >>parent dup :> new-node
    node nodes index 1 +
    nodes insert-nth! new-node ;

: ?insert-subtree ( elt -- )
    [ subtree? ] [ subtree replace-with-new-parent ] smart-unless drop ;

: remove-node ( elt -- parent/child )
    [ contents>> empty? ]
    [ remove-from-parent ]
    [ dup child-node replace-element ] smart-if ;

:: (change-node-type) ( elt class -- new-elt )
    elt class new elt name>> >>name elt contents>> [ add-element ] each replace-element ;

: change-node-type ( elt class -- new-elt )
    2dup {
        { introduce [ top-node? ] }
        { text      [ top-node? ] }
        { return    [ bottom-node? ] }
        [ drop drop t ]
    } case [ (change-node-type) ] [ drop ] if ;

: name-or-default ( elt -- str )
    { { [ dup subtree? ] [ drop "" ] }
      { [ dup name>> empty? not ] [ name>> ] }
      { [ dup default-name>> empty? not ] [ default-name>> ] }
      { [ dup introduce? ] [ drop "input" ] }
      { [ dup return? ] [ drop "output" ] }
      { [ dup call? ] [ drop "word" ] }
      { [ dup getter? ] [ drop "get" ] }
      { [ dup setter? ] [ drop "set" ] }
      [ class-of unparse ] } cond >string ;

GENERIC: factor-name ( elt -- str )

M: element factor-name
    name>> ;

M: call factor-name
    name>> {
        { "while" "special while" }
        { "until" "special until" }
        { "if" "special if" }
        { "times" "special times" }
    } [ change-name ] each ;

M: constructor factor-name
    name>> " (constructor)" append ;

M: accessor factor-name
    name>> " (accessor)" append ;

M: mutator factor-name
    name>> " (mutator)" append ;

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
    [ in>> ] [ out>> ] bi [ [ replace-quot ] map ] bi@ ;

: same-name-as-parent? ( call -- ? )
    dup [ word? ] find-parent [ name>> ] bi@ = ;

: input-output-names ( word -- seq seq )
    [ introduces ] [ returns ] bi [ [ name>> ] map members ] bi@ ;

SINGLETON: recursion

GENERIC: in-out ( elt -- seq seq )

M: source in-out
    drop f { "" } ;

M: sink in-out
    drop { "" } f ;

M: subtree in-out
    drop { "" } { "" } ;

M:: call in-out ( call -- seq seq )
    call target>>
    { { [ dup recursion? ] [ drop call parent>> input-output-names ] }
      { [ dup number? ] [ drop { } { "..." } ] }
      { [ dup not ] [ drop { } { } ] }
      [ "declared-effect" words:word-prop convert-stack-effect ]
    } cond ;

:: matching-words-exact ( str -- seq )
    interactive-vocabs get [ vocabs:vocab-words ] map concat [ name>> str = ] filter ;

:: find-target ( call -- seq )
    call factor-name :> name
    { { [ call same-name-as-parent? ] [ recursion 1array ] }
      { [ name string>number ] [ name string>number 1array ] }
      [ name matching-words-exact ]
    } cond ;

:: ?add-subtrees ( elt -- )
    elt contents>> elt in-out drop
    [ "quot" swap subseq? [ ?insert-subtree ] [ drop ] if ] 2each ;

:: ?add-words-above ( elt -- )
    elt elt in-out drop change-nodes-above
    elt ?add-subtrees
    elt contents>> [ ?add-words-above ] each ;

:: ?add-word-below ( elt -- )
    elt in-out nip [ first elt insert-node default-name<< ] unless-empty ;

:: ?add-words ( word -- word )
    word contents>>
    [ word call add-from-class drop ]
    [ [ dup ?add-word-below ?add-words-above ] each ]
    if-empty word ;

: any-empty-name? ( def -- ? )
    sort-tree [ name>> empty? ] any? ;

: executable? ( def -- ? )
   { [ word? ]
     [ introduces empty? ]
     [ returns empty? ]
     [ calls empty? not ]
     [ any-empty-name? not ]
     [ defined?>> ]
   } 1&& ;

: error? ( def -- ? )
    { [ defined?>> not ]
      [ any-empty-name? ] 
      [ contents>> empty? ]
    } 1|| ;

CONSTANT: simple-variadic-words { "add" "mul" "and" "or" "min" "max" }
CONSTANT: special-variadic-words { "array" "sequence" } ! "each" "map" "append" "produce" }

: simple-variadic? ( call -- ? )
    name>> simple-variadic-words member? ;

: special-variadic? ( call -- ? )
    name>> special-variadic-words member? ;

: variadic? ( call -- ? )
    [ simple-variadic? ] [ special-variadic? ] bi or ;

: save-result ( str word  -- )
    swap dupd result new swap >>contents swap >>parent >>result drop ;

: forget-alt ( vocab/def -- )
    { { [ dup vocab? ] [ path [ vocabs:forget-vocab ] with-compilation-unit ] }
      { [ dup word? ] [ alt>> [ [ definitions:forget ] with-compilation-unit ] each ] }
      [ drop ]
    } cond ;
