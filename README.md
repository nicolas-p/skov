# Skov

Skov is a visual programming system based on [Factor](https://github.com/slavapestov/factor/) and inspired by Lisp.

A functional program can be thought of as a tree (actually a graph) in which functions are connected together on several levels. Commonly used programming languages have to make more or less compromises to represent this tree as a one-dimensional stream of text. Skov uses a visual, two-dimensional representation to display the tree direcly. This makes the program easier to read and to reason about and reduces the risk of making mistakes. Skov lets you see a functional program as it really is.

Skov means *forest* in Danish because Skov contains a lot of trees.

More information on [the website](http://skov.software).

## Building Skov from Factor

* Download this repository
* Download a Factor binary package from [the Factor website](http://factorcode.org)
* Extract the `factor` directory from the package
* Move or copy all the contents from the Skov repository into the `factor` directory
* Drag and drop the `make-skov.factor` script onto the Factor application

(On Windows, this last step won't work. Instead, you have to start Factor and type `"make-skov.factor" run-file` and press _Enter_)

## Typeface

Skov uses the *Linux Biolinum* typeface. On Windows and Linux, you will need to download it from [here](http://www.linuxlibertine.org/index.php?id=91&L=1) and install it on your system.
