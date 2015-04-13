# OTMql4Lib
## Open Trading Metaquotes4 Library



Metatrader has been a great international success, putting into the
hands of end-users the ability to do programmed trading, something
that was only previously available to large trading houses. It has
been widely adopted, provides a credible platform for Forex trading,
and there are a huge number of "experts" and programs that have been
developed for it.

However, Metatrader as a language is not without some significant
drawbacks. The language is very rudimentary from the computer science
point of view, and is a closed sole-source product. Very importantly
for writing robust, well-tested and easily maintained code, it lacks
proper error handling flow-of-control constructs, such as are found in
Java, Python or Lisp. This leads to poor quality code, as can be seen
by much of the MQL code in existence, including the code from the
manufacturer, MetaQuotes. The poor nature of the language combines
with the very poor coding practices of the community (e.g. not
checking error codes and no documentation or testing) to create a very
poor programming environment.

The OTMql4Lib aims to provide a high-quality library of code to Mt4
with testing and documentation, that can serve as a basis to other projects.

**This is a work in progress - a developers' pre-release version.**

### Installation

For the moment there is no installer: just "git clone" or download the
zip from github.com and unzip into an empty directory. Then recursively copy
the folder MQL4 over the MQL4 folder of your Metatrader installation. It will
not overwrite any system files, and keeps its files in subdirectories
called `OTMql4`.

### Project

Please file any bugs in the issues tracker:
https://github.com/OpenTrading/OTMql4Lib/issues

Use the Wiki to start topics for discussion:
https://github.com/OpenTrading/OTMql4Lib/wiki
It's better to use the wiki for knowledge capture, and then we can pull
the important pages back into the documentation in the share/doc directory.
You will need to be signed into github.com to see or edit in the wiki.
### Development

#### Type Prefixing

Prefix all variable, function and method names with a lowercase letter
that indicates the type; it helps you anticipate what type a quantity
is, and to make explicit type conversions. If the type changes, give
it a new name with the initial letter changed. In Mql, this scheme
has the added advantage of avoiding any naming conflict with Mql
built-ins or most standard library modules.

Choose the initial letter from the following list:

||'''Prefix Letter'''||'''Variable Type'''	||
|| a		|| array 	||
|| b		|| boolean	||
|| c		|| complex (unused)	||
|| d		|| alist or dictionary	||
|| e		|| error string return value, empty for success	||
|| f		|| double	||
|| g		|| generic - unknown or mutable (unused)	||
|| h		|| hypertext - HTML/XML entity encoded string	||
|| i		|| integer	||
|| l		|| list or tuple	||
|| o		|| instance or pointer to a class	||
|| p		|| pathname - name of a file or directory	||
|| s		|| ASCII string	||
|| t		|| date/time value	||
|| u		|| Unicode string	||
|| v		|| void - return value not to be used	||
|| z		|| non-empty string return value - empty is failure	||

