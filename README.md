
Luapp - A preprocessor based on Lua.

Derived from previous
[SLSLPP](http://lua-users.org/wiki/SlightlyLessSimpleLuaPreprocessor)
code by RiciLake and David Manura, which in turn was loosely based on
[SimpleLuaPreprocessor](http://lua-users.org/wiki/SimpleLuaPreprocessor) .

Design Qualities
================

This module has the following characteristics:

- This module is intended to be robust and fully tested.
- It is implemented entirely in Lua.
- The syntax is quite simple and unambiguous.
  There are two syntaxes available for embedding Lua preprocessor code in your
    text: $(...) or "#...".
  The former resembles the "Makefile", M4, or Perl style.
  The latter resembles the C preprocessor style.

~~~
    $(for x=1,3 do _put(x) end)
~~~

~~~
    #for x=1,3 do   -- not identical due to spacing differences
      $(x)
    #end
~~~

- The `#...` style allows text to be nested (lexically) in Lua code to be
    nested to text to be nested in Lua code, etc.
  For example:

~~~
    #for x=1,2 do
    x is now $(x)
    #  for y=1,2 do
    y is now $(y)
    #  end
    #end
    x and y are now $(x) and $(y)
~~~

  Outputs:

~~~
    x is now 1
    y is now 1
    y is now 2
    x is now 2
    y is now 1
    y is now 2
    x and y are now nil and nil
~~~

- The module will try to report an meangingful error if syntax is bad:
  `$(if x then then)`.
  However, there are probaby cases where it fails in this.
- It is possible to run the preprocessor on untrusted source.
  Just set the lookup table to `nil` or to a custom table.
- The processor loads the entire source into memory.
  For very large files that exceed available RAM, this might not be suitable.
- Speed should be reasonably good, though probabily not optimal due to
  checks (it has not been performance tested).
  There may be room for some optimization.


Syntax
======

- Any line having `#` in the first column is treated as Lua code.
- `$(chunk)` where `chunk` is a chunk of Lua code will evalute the chunk,
     outputting nothing.
  `chunk` must NOT call `return` (not supported--should it be?)
- `$(explist)` where `explist` is a Lua expression list will evaluate the
    expression list and output each element of the expression list as a string
    (via `tostring`).
  Note: if `x` in `$(x)` can be interpreted as both a chunk and an expression
    list, it is interpreted as an expression list.
  This allows function calls: `$(f())`.
- `$('$')` allows a `$` to be outputted literally. Example:
  `$('$')(1+2)` outputs `$(1+2)`. `$('#')` allows a `#` the be
  outputted literally in the first column. Example: `$('#')if`
  outputs `#if`.
- `$(chunk)` may contain calls to the function `_put`, which
  stringifies all its arguments and outputs them. For example,
  `$(_put(explist))` is the same as `$(explist)`. This can be
  useful for things like `$(for n=1,10 do _put(n, ' ') end)`.
- `$(x)` where `x` is not a valid Lua expression or statement
  generates an error.

~~~
  #if DEBUG
    Debug $(x).
  #else
    Release $(x).
  #end
~~~

Interface
=========

Import
------

~~~
  local preprocess = require "luapp" . preprocess
~~~

preprocess()
------------

~~~
  result, message = preprocess(t)
  where t = {input=input, output=output, lookup=lookup,
             strict=strict} or input
~~~

Preprocesses text.

- `input` - input source. 
    This can be the a readable filepath or a string.
    If omitted, this will be STDIN.
- `output` - output destination.
    This can be a writable filepath.
    If omitted, this will be STDOUT.
- lookup` - lookup table used for retrieving the values of global variables
    referenced by the preprocessed file.
    Global writes in the preprocessed file are not written to this table.
    If omitted, all global accesses will have the value `nil`.
    Often, this value is set to `_G` (the global table).
- `strict` - enable strict-like mode on global variables.
    Accessing global variables with value `nil` triggers an error.
    `true` or `false`.
    Default `true`.
- `result` - the result.
    The is normally the processed text (if output is set to 'string') or true.
    On failure, this is set to false and message is set.
- `message` - the error message string.
    This is set only if result is `false`.


Command Line Usage
==================

~~~
  luapp [key=value] [-i <input filepath>] [-o <output filepath>]
~~~

Examples:

~~~
  cat in.txt | luapp > out.txt
~~~

~~~
  luapp -i in.txt -o out.txt DEBUG=true
~~~

~~~
  luapp -e '$(1+2)'
~~~



History
=======

0.1 - 2014-08-19 Dave McEwan
  initial version adapted from David Manura's code.
  Tested with Lua 5.3.2


License
=======

Licensed under the same terms as Lua itself -- That is, the MIT license:


Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
