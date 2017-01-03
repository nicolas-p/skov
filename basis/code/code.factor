! Copyright (C) 2015-2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
compiler.units effects fry hashtables.private kernel listener
locals math math.parser namespaces sequences sequences.deep sets
splitting ui.gadgets vectors vocabs.parser ;
QUALIFIED: vocabs
QUALIFIED: definitions
QUALIFIED: words
IN: code

TUPLE: element < identity-tuple  name parent contents ;

TUPLE: vocab < element ;

TUPLE: definition < element  defined? alt ;
TUPLE: word < definition  result ;
TUPLE: class < definition ;

TUPLE: node < element ;
TUPLE: introduce < node ;
TUPLE: return < node ;
TUPLE: call < node  target ;
TUPLE: text < node ;
TUPLE: slot < node  initial-value ;
TUPLE: constructor < call ;
TUPLE: destructor < call ;
TUPLE: accessor < call ;
TUPLE: mutator < call ;

TUPLE: input < element  link invisible? ;
TUPLE: output < element  id invisible? ;

UNION: input/output  introduce return input output ;

TUPLE: result < element ;

: vocabs ( elt -- seq )  contents>> [ vocab? ] filter ;
: definitions ( elt -- seq )  contents>> [ definition? ] filter ;
: words ( elt -- seq )  contents>> [ word? ] filter ;
: classes ( elt -- seq )  contents>> [ class? ] filter ;
: calls ( elt -- seq )  contents>> [ call? ] filter ;
: introduces ( elt -- seq )  contents>> [ introduce? ] filter ;
: returns ( elt -- seq )  contents>> [ return? ] filter ;
: slots ( elt -- seq )  contents>> [ slot? ] filter ;

GENERIC: connectors ( elt -- seq )
GENERIC: inputs ( elt -- seq )
GENERIC: outputs ( elt -- seq )
M: element connectors ( elt -- seq )  contents>> [ input/output? ] filter ;
M: element inputs ( elt -- seq )  contents>> [ input? ] filter ;
M: element outputs ( elt -- seq )  contents>> [ output? ] filter ;

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

M: destructor factor-name
    name>> " (destructor)" append ;

M: accessor factor-name
    name>> " (accessor)" append ;

M: mutator factor-name
    name>> " (mutator)" append ;

GENERIC: path ( obj -- str )

M: vocab path
    parents reverse rest [ factor-name ] map "." join [ "scratchpad" ] when-empty ;

M: definition path
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

: add-invisible-connector ( node class -- node )
    new "invisible connector" >>name t >>invisible? add-element ;

: add-invisible-connectors ( node -- node )
    [ inputs empty? ] [ input add-invisible-connector ] smart-when
    [ outputs empty? ] [ output add-invisible-connector ] smart-when ;

GENERIC: (add-connectors) ( node -- node )
M: element (add-connectors)  ;
M: introduce (add-connectors)  f >>contents dup name>> output add-with-name ;
M: return (add-connectors)  f >>contents dup name>> input add-with-name ;
M: text (add-connectors)  f >>contents dup name>> output add-with-name add-invisible-connectors ;

M: call (add-connectors)
    f >>contents dup in-out
    [ [ input add-with-name ] each ]
    [ [ output add-with-name ] each ] bi*
    add-invisible-connectors ;

GENERIC: connect ( output input -- )

:: links ( output -- seq )
    output parent>> parent>> contents>> [ inputs [ link>> output eq? ] filter ] map concat ;

:: add-connectors ( elt -- elt )
    elt name>> [
      elt node? [
        elt inputs [ link>> ] map 
        elt outputs [ links ] map
      ] [ f f ] if :> saved-output-links :> saved-input-links
      elt (add-connectors)
      saved-input-links elt inputs [ connect ] 2each
      elt outputs saved-output-links [ [ connect ] with each ] 2each
    ] [ elt ] if ;

: order-connectors ( connector connector -- connector connector )
    dup output? [ swap ] when ;

: output-and-input? ( connector connector -- ? )
    [ output? ] [ input? ] bi* and ;

: same-node? ( connector connector -- ? )
    [ parent>> ] bi@ eq? ;

GENERIC: connected? ( connector -- ? )

M: node connected?
    connectors [ connected? ] any? ;

M: input connected?
    link>> output? ;

M: output connected?
    dup parent>> parent>> contents>> [ inputs [ link>> ] map ] map concat [ eq? ] with any? ;

: connected ( seq -- seq )  [ connected? ] filter ;
: unconnected ( seq -- seq )  [ connected? ] reject ;
: visible ( seq -- seq )  [ invisible?>> ] reject ;

: unevaluated? ( connector -- ? )
    name>> "quot" swap subseq? ;

M: input connect
    link<< ;

:: unlink ( node -- node )
    node node parent>> contents>>
    [ inputs connected [ [ link>> parent>> node eq? ] [ f >>link ] smart-when ] map drop ] each ;

GENERIC: disconnect ( connector -- )

M: input disconnect
    f >>link drop ;

M: output disconnect
    links [ disconnect ] each ;

: ?connect ( connector connector -- )
    order-connectors 
    [ [ output-and-input? ] [ nip connected? not ] [ same-node? not ] 2tri and and ]
    [ connect ] smart-when* ;

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
   } cleave>array [ ] all? ;

: error? ( def -- ? )
    { [ complete-graph? not ]
      [ defined?>> not ]
      [ any-empty-name? ] 
      [ contents>> empty? ]
    } cleave>array [ ] any? ;

CONSTANT: variadic-words { "add" "mul" "and" "or" "min" "max" }

: variadic? ( call -- ? )
    name>> variadic-words member? ;

: save-result ( str word  -- )
    swap dupd result new swap >>contents swap >>parent >>result drop ;

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

: forget-alt ( vocab/def -- )
    { { [ dup vocab? ] [ path [ vocabs:forget-vocab ] with-compilation-unit ] }
      { [ dup definition? ] [ alt>> [ [ definitions:forget ] with-compilation-unit ] each ] }
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
