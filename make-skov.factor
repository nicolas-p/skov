! Copyright (C) 2015 Nicolas Pénet.
USING: calendar calendar.format images.loader io.directories
io.directories.hierarchy io.pathnames kernel memory namespaces sequences
ui.images splitting system io.files io.encodings.utf8 skov skov.import-export parser ;

gmt timestamp>ymd skov-version set-global

image-path parent-directory set-current-directory

{ 
  "vocab:skov/theme/"
  "vocab:definitions/icons/"
  "vocab:ui/gadgets/theme/"
} [ 
  dup directory-files
  [ first CHAR: . = ] reject
  [ file-extension [ "png" = ] [ "tiff" = ] bi or ] filter
  [ dupd append-path <image-name> cached-image drop ] each drop
] each

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

os windows = [
  "factor.exe" "skov.exe" move-file
  "factor.dll" delete-file
  "libfactor-ffi-test.dll" delete-file
  ".dir-locals.el" delete-file
  "factor.com" delete-file
] when

"changes" directory-tree-files
[ first CHAR: . = ] reject
[ file-extension "factor" = ] filter
[ "changes" swap append-path run-file ] each

"basis" delete-tree
"core" delete-tree
"extra" delete-tree
"misc" delete-tree
"work/README.txt" delete-file
"README.md" delete-file
"git-id" delete-file
"changes" delete-tree
"make-skov.factor" delete-file

save
"factor.image" "skov.image" move-file
0 exit
