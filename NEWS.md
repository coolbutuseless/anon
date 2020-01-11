
# anon 0.1.2  20200111

* Replace `formula_to_1arg_function()` with `formula_to_function()` which 
  creates anonymous functions with multiple arguments (.x, .y, and .z) and 
  includes `.` as an alias for the first argument, `.x`
  
  
# anon 0.1.1

* Add `formula_to_1arg_function()` as an example of a simple function builder
  which does not rely on `rlang`.
    * Only allows a formula as input
    * Only builds a function with a single argument `.x`
    * Does not depend on any `rlang` functions

# anon 0.1.0

* Initial release.
