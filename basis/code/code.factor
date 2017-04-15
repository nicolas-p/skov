! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
compiler.units effects fry hashtables.private kernel listener
locals math math.parser namespaces sequences sequences.deep sets
splitting ui.gadgets vectors vocabs.parser combinators.short-circuit ;
QUALIFIED: vocabs
QUALIFIED: definitions
QUALIFIED: words
IN: code

TUPLE: element < identity-tuple  name parent contents ;

TUPLE: vocab < element ;
TUPLE: word < element  defined? alt result ;

TUPLE: node < element ;
TUPLE: introduce < node id ;
TUPLE: return < node ;
TUPLE: call < node  target ;
TUPLE: text < node ;
TUPLE: constructor < call ;
TUPLE: accessor < call ;
TUPLE: mutator < call ;

TUPLE: input < element  link ;

UNION: input/output  introduce return input ;

TUPLE: result < element ;

: walk ( node -- seq )
    [ contents>> [ walk ] map ] [ ] bi 2array ;

: sort-tree ( word -- seq )
    contents>> [ walk ] map flatten ;

: vocabs ( elt -- seq )  contents>> [ vocab? ] filter ;
: words ( elt -- seq )  contents>> [ word? ] filter ;
: calls ( elt -- seq )  sort-tree [ call? ] filter ;
: introduces ( elt -- seq )  sort-tree [ introduce? ] filter ;
: returns ( elt -- seq )  contents>> [ return? ] filter ;

GENERIC: connectors ( elt -- seq )
GENERIC: inputs ( elt -- seq )
M: element connectors ( elt -- seq )  contents>> [ input/output? ] filter ;
M: element inputs ( elt -- seq )  contents>> [ input? ] filter ;

:: add-element ( parent child -- parent )
     child parent >>parent parent [ ?push ] change-contents ;

: add-from-class ( parent child-class -- parent )
     new add-element ;

: add-with-name ( parent child-name child-class -- parent )
     new swap >>name add-element ;

: remove-from-parent ( child -- )
     dup parent>> contents>> remove-eq! drop ;

:: change-name ( str pair -- str )
    str pair first = [ pair second ] [ str ] if ;

:: insert-node ( elt -- )
    elt parent>> contents>> :> nodes
    elt nodes index :> n
    call new "" >>name elt add-element elt parent>> >>parent :> new-node
    new-node n nodes set-nth ;

:: remove-node ( elt -- )
    elt parent>> contents>> :> nodes
    elt nodes index :> n
    elt contents>> first elt parent>> >>parent :> child
    child n nodes set-nth ;

:: change-node-type ( elt class -- )
    elt parent>> contents>> :> nodes
    elt nodes index :> n
    elt contents>> first :> child
    class new elt name>> >>name elt contents>> [ add-element ] each elt parent>> >>parent
    n nodes set-nth ;

GENERIC: factor-name ( obj -- str )

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

GENERIC: path ( obj -- str )

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
    dup parent>> [ name>> ] bi@ = ;

: input-output-names ( call -- seq seq )
    [ introduces ] [ returns ] bi [ [ name>> ] map ] bi@ ;

SINGLETON: recursion

:: in-out ( call -- seq seq )
    call target>>
    { { [ dup recursion? ] [ drop call parent>> input-output-names ] }
      { [ dup number? ] [ drop { } { "number" } ] }
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

GENERIC: connected? ( connector -- ? )

M: node connected?
    connectors [ connected? ] any? ;

M: input connected?
    link>> f = not ;

: connected ( seq -- seq )  [ connected? ] filter ;
: unconnected ( seq -- seq )  [ connected? ] reject ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

:: unlink ( node -- node )
    node node parent>> contents>>
    [ inputs connected [ [ link>> parent>> node eq? ] [ f >>link ] smart-when ] map drop ] each ;

GENERIC: disconnect ( connector -- )

M: input disconnect
    f >>link drop ;

: complete-graph? ( def -- ? )
    contents>> unconnected empty? ;

: any-empty-name? ( def -- ? )
    contents>> [ name>> empty? ] any? ;

: executable? ( def -- ? )
   { [ complete-graph? ]
     [ introduces empty? ]
     [ returns empty? ]
     [ calls empty? not ]
     [ defined?>> ]
     [ any-empty-name? not ]
   } 1&& ;

: error? ( def -- ? )
    { [ complete-graph? not ]
      [ defined?>> not ]
      [ any-empty-name? ] 
      [ contents>> empty? ]
    } 1|| ;

CONSTANT: simple-variadic-words { "add" "mul" "and" "or" "min" "max" }
CONSTANT: special-variadic-words { "1array" "1sequence" "each" "map" "append" "produce" }

: simple-variadic? ( call -- ? )
    name>> simple-variadic-words member? ;

: special-variadic? ( call -- ? )
    name>> special-variadic-words member? ;

: variadic? ( call -- ? )
    [ simple-variadic? ] [ special-variadic? ] bi or ;

: save-result ( str word  -- )
    swap dupd result new swap >>contents swap >>parent >>result drop ;

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

: forget-alt ( vocab/def -- )
    { { [ dup vocab? ] [ path [ vocabs:forget-vocab ] with-compilation-unit ] }
      { [ dup word? ] [ alt>> [ [ definitions:forget ] with-compilation-unit ] each ] }
      [ drop ]
    } cond ;

: neighbors ( node -- seq )
    inputs connected [ link>> parent>> ] map ;

: connected-nodes ( node -- seq )
    dup neighbors [ connected-nodes ] map 2array flatten members ;

:: gather-graphs ( seq graph -- seq )
    seq [ graph subset? ] reject dup [ graph swap subset? ] any? [ graph suffix ] unless ;

: remove-partial-graphs ( seq -- seq ) 
    f [ gather-graphs ] reduce ;

: group-connected-nodes ( word -- seq )
    contents>> connected [ connected-nodes ] map remove-partial-graphs ;
