
<!-- README.md is generated from README.Rmd. Please edit that file -->

# anon

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg)
![](https://img.shields.io/badge/status-rough-red.svg)
<!-- badges: end -->

The `anon` package provides two functions to help define succinct
anonymous functions (also called *lambdas*).

## Features

`anon` provides two user-facing functions:

1.  `lambda()` for easily and compactly creating lambda expressions in
    R, while being broadly compatible with a number of existing lambda
    syntaxes. This function is also aliased to `L()` for the sake of
    brevity.
2.  `patch_purrr_mapper()` to patch `purrr` to allow `anon` to convert
    formulas to functions instead of `rlang::as_function()`. Using
    `anon` to convert formulas-to-functions enables:
      - automatic argument extraction (rather than forcing the arguments
        to be `.x` and `.y`)
      - explicit arguments through the use of 2 sided formulas i.e. the
        formal arguments are extracted from the expression on the LHS of
        a two-sided formula e.g. `a:b ~ a + b + 1` becomes `function(a,
        b) {a + b + 1}`

## Installation

You can install `anon` from
[github](https://github.com/coolbutuseless/anon) with:

``` r
remotes::install_github("coolbutuseless/anon")
```

## Example use of `lambda()`/`L()` for creating anonymous functions

The following calls all create the same anonymous function:

  - `function(x, y) x + y`
  - `L(.x + .y)`
  - `L(x + y)`
  - `L(~x + y)`
  - `L(x, y, x + y)`
  - `L(x, y ~ x + y)`
  - `L(x, y, ~x + y)`
  - `L(x:y ~ x +
y)`

## Example use of `patch_purrr_mapper()` to enable extended functionality for lambdas in `purrr`

By running `patch_purrr_mapper()` an extra S3 method is added for
`purrr::as_mapper()` i.e. `as_mapper.formula()`.

By doing so, any *formula-used-as-function* in `purrr` will be passed to
`anon::as_function_formula()` which allows for more expressiveness than
`rlang::as_function()`. i.e.

1.  Can use any name for the variables, not just `.x` and `.y`
2.  Can set explicit formal arguments (by specifying the LHS of the
    formula)
3.  If no explicit formal arguments are given, then all variable names
    on the RHS of the formula are used as formal arguments. The order of
    the formal arguments is the same as the order of appearance of the
    variables.
4.  If `.x` or `.y` appear on the RHS and no explicit formal arguments
    are given on the LHS, then they are used as the first formal
    arguments (regardless of the order in which they appear on the RHS)
5.  You can use `.` as a stand-in for the first argument.

<!-- end list -->

``` r
library(purrr)
anon::patch_purrr_mapper()

z <- 10L

map_int(1:3, ~. + 1L)
#> [1] 2 3 4

map_int(1:3, ~.x + 1L)
#> [1] 2 3 4

map_int(1:3, ~ value + 1L)
#> [1] 2 3 4

map_int(1:3, val ~ val + 1L)
#> [1] 2 3 4

map_int(1:3, val ~ val + z)
#> [1] 11 12 13

map2_dbl(1:3, 4:6, ~ .x / .y)
#> [1] 0.25 0.40 0.50

map2_dbl(1:3, 4:6, ~ a / b)
#> [1] 0.25 0.40 0.50

map2_dbl(1:3, 4:6, ~ b / a)
#> [1] 0.25 0.40 0.50

map2_dbl(1:3, 4:6, b:a ~ a / b)
#> [1] 4.0 2.5 2.0

pmap_int(list(1:2, 3:4, 5:6, 7:8), ~a * b * c * d)
#> [1] 105 384
```
