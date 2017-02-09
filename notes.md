
# Introduction

This document is a stream of consciousness list of thoughts accompanying each 
commit. The commits will be named in accordance with the sections below.


## commit: inherited code

The complexity in lib/gilded\_rose.rb is out of control. The number of 
branch combinations the code can take makes it impossible to reason about 
as a whole.

Moreover the tests for conjured items do not pass.

It would be more interesting to think of the assessment of each item as its 
own process--and then share strategies where possible.

### In This Commit

1. Mark broken specs as pending, leaving as documentation. Fixing in current 
implementation is too painful.

### Mental TODO Roadmap

1. Organize legacy code as standard Ruby.
2. Remove garbage Given/When/Then rspec extension. Just use rspec.
3. No need to loop in `#update_quality`. Make this responsibility of calling 
code. (Loops are less composable than single operations.)
4. Identify inputs and outputs of "quality update" process. Kill mutation of 
`Item` struct.
5. Reassign namespace to terser `lib/gr`.
6. Implement each process.
7. Extract shared functionality into common code.

