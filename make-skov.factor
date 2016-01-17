! Copyright (C) 2015 Nicolas Pénet.
USING: images.loader io.directories io.directories.hierarchy
io.pathnames kernel memory sequences ui.gadgets.icons
ui.gadgets.panes ui.images splitting system io.files io.encodings.utf8
ui ui.gadgets.borders skov listener namespaces lists.lazy combinators.smart ;

image-path "factor.image" "" replace set-current-directory

"extra/skov/theme" directory-files
[ first CHAR: . = ] reject
[ ".png" swap subseq? ] filter
[ "vocab:skov/theme/" prepend-path <image-name> <icon> gadget. ] each

os macosx = [
  "factor" delete-file
  "libfactor-ffi-test.dylib" delete-file
  "libfactor.dylib" delete-file
  "Factor.app" "Skov.app" move-file
  "Skov.app/Contents/MacOS/factor" "Skov.app/Contents/MacOS/skov" move-file
  "misc/icons/Skov.icns" "Skov.app/Contents/Resources/Skov.icns" move-file
  "Skov.app/Contents/Resources/Factor.icns" delete-file

  "Skov.app/Contents/Info.plist" utf8 2dup file-lines 
  [ ">factor<" ">skov<" replace
    ">Factor<" ">Skov<" replace 
    ">0.98<" ">0<" replace
    ">Factor developers<" ">Factor and Skov developers<" replace
    "Factor.icns" "Skov.icns" replace
  ] map -rot set-file-lines
] when

os windows = [
  "factor.exe" "skov.exe" move-file
  "factor.dll" delete-file
  "libfactor-ffi-test.dll" delete-file
  ".dir-locals.el" delete-file
  "factor.com" delete-file
] when

"basis" delete-tree
"core" delete-tree
"extra" delete-tree
"misc" delete-tree
"work" delete-tree
"README.md" delete-tree
"git-id" delete-tree
"Hello world (console)" delete-tree
"make-skov.factor" delete-file

IN: kernel
: special-while ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip while ; inline

: special-until ( initial pred: ( a -- ? ) body: ( b -- a ) -- final )
    [ [ preserving ] curry ] dip until ; inline

IN: syntax
: special-false ( -- false )  f ;

IN: ui.tools
MAIN: skov-window

IN: ui.tools.listener
: show-listener ( -- ) [ border? ] find-window [ raise-window ] [ skov-window ] if* ;
: listener-window ( -- ) skov-window ;

interactive-vocabs [ { 
  "io.encodings.utf8"
  "io.directories"
  "lists.lazy"
} append ] change-global

save
"factor.image" "skov.image" move-file
0 exit
