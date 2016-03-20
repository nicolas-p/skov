USING: kernel listener lists.lazy math.trig namespaces sequences
skov splitting ui ui.gadgets.borders ;
IN: ui.tools.listener

: show-listener ( -- ) [ border? ] find-window [ raise-window ] [ skov-window ] if* ;
: listener-window ( -- ) skov-window ;

USE: lists.lazy
USE: math.trig

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.encodings.binary"
  "io.encodings.ascii"
  "io.binary"
  "io.directories"
  "io.directories.hierarchy"
  "lists.lazy"
  "splitting"
  "math.functions"
  "math.trig"
  "math.vectors"
  "math.intervals"
  "sequences.deep"
  "binary-search"
  "vectors"
  "quotations"
  "byte-arrays"
  "deques"
  "regexp"
  "calendar"
} append ] change-global
