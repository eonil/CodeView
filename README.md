Eonil/CodeView
==============
2015/01/09
Hoon H.





Provides a custom-built high-performance code-editing view for Cocoa applications.

`NSTextView` is very good for textual editing, but not for code editing because its backend is too opaque to optimise for.
I decided to build a fast code editing view by eliminating all the unnecessary features.



Suspended Experiment
--------------------
This is an experimental implementation of code editor view implemented from scratch without Cocoa text system such as
`NSTextView`.
This project initially started due to slow loading of `NSTextView`, but I finally discovered a switch that makes the
view to load everything very fast, and I suspended this project. This project will not continue until I feel need for 
this again.



Goals 
-----
-	This view is designed for fast rendering and editing of fixed-font code text.
-	Fully UTF-8 based back-end. So I can replace the backend eventually with something else than `NSString`.

Non-Goals
---------
-	No word-wrap.
-	No ruler.
-	No complex layout.
-	No custom rich text formatting (font/color/styling). Everything will be controlled by predefined logics.
-	Perfect international text input. Though I will add a proper support, but I don't focus on it.
	Actually non-ASCII character keybowrd input are out of interest.
-	No right-to-left layout support.
-	No vertical layout support.
-	Space optimisation. This view is memory hog. Space optimisation is not a current godl. Currently editing of
	10MiB file needs over 500MiB memory to wire up internal structure.
-	Large file support. This view is optimised for small-to-mid scale source code. (up to 10 MiB) Support for 
	large text files simply needs some superier algorithms, and I don't want to do it now.
-	No fast index based location calculation. Texts are split into lines, and you should always use a line/column 
	based pointing. Referring character index needs full recalulation of positions.
-	No infinite width support. If you have very long source code line, then some if it will not be editable.
	Current limit is about 128 characters.
-	No code folding. I don't need it.


Design Summary
--------------
Loads everything into memory, and split into lines. This is a kind of space partitioning.
Line collection is just a Swift array. That its internal implementation is opaque, but its performance it acceptable.
I believe it is using a kind of B-Tree.
Lines are also interconnected in double-linked-list manner to enable navigations easier.
Each line has UTF-8 encoded data, and you can perform byte-to-byte based text comparison. That means unambiguous, and
super fast.
Each line contains annotations. A line is a minimal unit for annotation. User can subclass annotation class to attach 
their own custom data.

Center of view is `CodeStorage` class. `CodeView` owns a `CodeStorage` instance but does not expose it externally. 
Direct access to the `CodeStorage` will not allowed. 


Works Done
-----------
-	Backend line-based storage.
-	Rendering
-	Selecting
-	Caret management.



Works To Do
-----------
-	Text input.
-	Selection rendering optimisation. (`DrawableLine` caching)
-	Selection rendering optimisation. (drawing only delta lines)
-	Layout tuning.
-	Syntax highlighting.
-	On-demand width extending.
-	Clipboard support.
-	Saving (exporting as plain string) support.
-	Font rendering tuning. 


Issues
------
-	Graphical line cache needed for on-screen lines. (caching `DrawableLine`)
















License
-------
MIT licensed.


