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


**This is a work in progress - a pre-developers version.**

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

Metatrader with Python (Multi-Platform)

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

Fortunately, Metatrader can be extended by writing C-coded function
libraries that are called from MQL. These are usually simple C-coded
function calls, but it opens the possibility of calling any C-coded
interpreted program, including an interpreted language such as
Python. This is a very good solution to extending Metatrader, as
Python is the premiere language for scientific computation, and is
being very rapidly adopted by the financial community (Quants). Python
has an excellent programing culture of unit and functional testing,
and is state-of-the-art in computer science.

The aim of the OTMql4Lib is to develop a bridge to Python that can be
called from Metatrader, under Windows and Linux. This allows
Metatrader to be used as a front-end, receiving market data and
executing orders, but with all the important algorithmic work,
database access or user-interface extensions done in Python. This
allows for the important algorithmic code to be subjected to much more
rigorous testing, and makes it much easier to maintain.  The bridge
can be also used to feed standard high-speed financial message buses
to distributed applications (e.g. FITS or ZeroMq): see our OTMlq4Zmq project.


