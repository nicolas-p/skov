! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar calendar.format images.loader io.directories vocabs regexp accessors combinators.smart
io.directories.hierarchy io.pathnames kernel memory namespaces sequences ui.theme.switching
ui.images splitting system io.files io.encodings.utf8 ui.tools.environment.common
code.import-export parser help help.markup words debugger ;

! Setting Skov version in YYYY-MM-DD format
gmt timestamp>ymd skov-version set-global

! Setting the Factor directory as working directory
image-path parent-directory set-current-directory

! Loading all bitmaps into the image
{ 
  "vocab:ui/tools/environment/theme/"
  "vocab:definitions/icons/"
  "vocab:ui/theme/images"
} [ 
  dup directory-files
  [ first CHAR: . = ] reject
  [ file-extension [ "png" = ] [ "tiff" = ] bi or ] filter
  [ dupd append-path <image-name> cached-image drop ] each drop
] each

! Modifying the macOS bundle and removing unused files
os macosx = [
  "factor" delete-file
  "libfactor-ffi-test.dylib" delete-file
  "libfactor.dylib" delete-file
  "Factor.app" "Skov.app" move-file
  "Skov.app/Contents/MacOS/factor" "Skov.app/Contents/MacOS/skov" move-file
  "misc/icons/Skov.icns" "Skov.app/Contents/Resources/Skov.icns" move-file
  "misc/fonts" "Skov.app/Contents/Resources/Fonts" move-file
  "Skov.app/Contents/Resources/Factor.icns" delete-file

  "Skov.app/Contents/Info.plist" utf8 [
    ">factor<" ">skov<" replace
    ">Factor<" ">Skov<" replace 
    ">0.98<" gmt timestamp>ymd ">" "<" surround replace
    "Factor developers<" "Factor and Skov developers<" replace
    "Factor.icns" "Skov.icns</string>
    <key>ATSApplicationFontsPath</key>
    <string>Fonts" replace
  ] change-file-contents 
] when

! Removing unused files on Windows
os windows = [
  "factor.exe" "skov.exe" move-file
  "factor.dll" delete-file
  "libfactor-ffi-test.dll" delete-file
  ".dir-locals.el" delete-file
  "factor.com" delete-file
] when

! Loading the changes made to Factor
"changes" directory-tree-files
[ first CHAR: . = ] reject
[ file-extension "factor" = ] filter
[ "changes" swap append-path run-file ] each

! Running the help.stylesheet vocabulary to update the fonts
"vocab:help/stylesheet/stylesheet.factor" run-file

! Deleting all Factor code files and other stuff
"basis" delete-tree
"core" delete-tree
"extra" delete-tree
"misc" delete-tree
"work/README.txt" delete-file
"README.md" delete-file
"git-id" delete-file
"changes" delete-tree
"make-skov.factor" delete-file

! Choosing dark mode
dark-mode

! Renaming every word
all-words [ [
    R/ .{2,}-.{2,}/ [ "-" " " replace ] re-replace-with
    R/ .+>>/ [ ">" "" replace " (accessor)" append ] re-replace-with
    R/ >>.+/ [ ">" "" replace " (mutator)" append ] re-replace-with
    R/ <.+>/ [ ">" "" replace "<" "" replace " (constructor)" append ] re-replace-with
    R/ >.+</ [ ">" "" replace "<" "" replace " (destructor)" append ] re-replace-with
    [ "+" = ] [ drop "add" ] smart-when
    [ "-" = ] [ drop "sub" ] smart-when
    [ "*" = ] [ drop "mul" ] smart-when
    [ "/" = ] [ drop "div" ] smart-when
    [ "." = ] [ drop "display" ] smart-when
    [ "gadget." = ] [ drop "display gadget" ] smart-when
    [ "e^" = ] [ drop "exp" ] smart-when
    [ "^" = ] [ drop "pow" ] smart-when
    [ "2^" = ] [ drop "pow 2" ] smart-when
    [ "10^" = ] [ drop "pow 10" ] smart-when
  ] change-name
] each

! Updating the help page of every word
all-words [ [ 
    [ "help" word-prop [ \ $description swap member? ] filter ]
    [ word-help* swap append ]
    [ swap "help" set-word-prop ] tri
  ] try
] each

! Saving and renaming the image
save
"factor.image" "skov.image" move-file
0 exit
