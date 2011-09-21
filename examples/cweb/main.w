% This is an exersice of Literate Programming using cweb.
% Version 0.1 --- 2011

\nocon % omit table of contents
\datethis
%\def\SPARC{SPARC\-\kern.1em station}

{Exersice Literate Programming}

\par{}Here I'm trying to explain a common C++ program structure.

@ A C++ program starts with a main procedure, and has the following structure:

@c
@<Include files@>@/
@<The main program@>

@ Normally a program would include external files, such as the standard I/O
streams from |iostream|.

@<Include ...@>=
#include <iostream>

@ A C++ program will be start from the main procedure.

@d SIMPLE_MACRO "foo"

@<The main...@>=
int main(int argc, char**argv)
{
  std::cout<<SIMPLE_MACRO<<std::endl;
  return 0;
}
