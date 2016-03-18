USING: kernel listener lists.lazy math.trig namespaces sequences
skov splitting ui ui.gadgets.borders ;
IN: ui.tools.listener

: show-listener ( -- ) [ border? ] find-window [ raise-window ] [ skov-window ] if* ;
: listener-window ( -- ) skov-window ;

USE: lists.lazy
USE: splitting
USE: math.trig

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.directories"
  "io.directories.hierarchy"
  "lists.lazy"
  "splitting"
  "math.functions"
  "math.trig"
  "math.vectors"
  "sequences.deep"
  "binary-search"
} append ] change-global
