# OTMql4Lib
## Open Trading Metaquotes4 Library

## OpenTrading Mt4 Library Code
https://github.com/OpenTrading/OTMql4Lib

The OTMql4Lib aims to provide a high-quality library of code to Mt4
with testing and documentation, that can serve as a basis to other projects.

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

#### Coding Practices

##### Type Prefixing

We prefix all variable, function and method names with a lowercase letter
that indicates the type; it helps you anticipate what type a quantity
is, and to make explicit type conversions. This is not a rigid requirement,
but it helps cut down on a very common type of mistake, pun intended.

If the type changes, give it a new name with the initial letter changed.
In Mql, this scheme has the added advantage of avoiding any naming
conflict with Mql built-ins, or most Python standard library modules.

Choose the initial letter from the following list:

||'''Prefix Letter'''	||'''Variable Type'''					||
|| a			|| array 						||
|| b			|| boolean						||
|| c			|| complex (unused)					||
|| d			|| alist or dictionary					||
|| e			|| error string return value, empty for success		||
|| f			|| double	       	      	    			||
|| g			|| generic - unknown or mutable				||
|| h			|| hypertext - HTML/XML entity encoded string		||
|| i			|| integer		       	       			||
|| l			|| list or tuple	(unused)			||
|| o			|| instance or pointer to a class			||
|| p			|| pathname - name of a file or directory		||
|| s			|| ASCII string	      	     				||
|| t			|| date/time value					||
|| u			|| Unicode string					||
|| v			|| void - return value not to be used			||
|| z			|| non-empty string return value - empty is failure	||

WE adopt a standard directory structure for all projects, so that it
will be obvious what directory things should go in as the projects
progress, and it will make it easier to share code and transfer
knowledge between projects.  The directory structure must be complete
so that it will support the final wrapping of the deliverable,
including all documentation.

The standardized Unix layout works for both MultiPlatformCoding under
both Unix and Windows, and many configuration tools assume its layout. The
layout is the defacto-standard created by the [http://www.fsf.org/ GNU]
toolchain.

In your top project directory you should find:[M]

    * '''bin''': binary directory.  This will contain executables, for
    either the main program, or support tools. For multi-platform work
    assume that there may be platform and OS dependent subdirectories
    such as
	 * `bin/windows-x86`: windows subdirectory
	 * `bin/linux-x86`: linux subdirectory

    * '''etc''': configuration files - may be empty.

    * '''lib''': library directory.  This will contain object libraries, for
    either the main program, or support tools. For multi-platform work,
    assume that there will be platform and OS dependent files under `lib`.

    * '''net''': Repository for files downloaded from the net, for all
    bundled prerquisites of code or tools required by the program. It
    may also contain the orginal version of code that this project
    extends, so that it's easy to compare the preoject with its origins.
    Make protocol subdirectories such as `net/Http` `net/Ftp`
    and in these subdirectories, put the name of the site the package
    was downloaded from.

    * '''share''': platform independent library directories. For example,
    the on-line documentation might go in `share/doc` or in `share/html`
    and icons might go in `share/icons` etc.

    * '''src''': The source code for the application and any of the tools
    it requires. 

    * '''var''': variable run-time data, initially empty. May have 
    subdirectories like `var/log` for log files, 
    `var/cache` for runtime files, `var/tmp` for temporary files etc.
