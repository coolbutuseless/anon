
<!-- README.md is generated from README.Rmd. Please edit that file -->

# anon

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg)
<!-- badges: end -->

The `anon` package provides three functions to help define succinct
anonymous functions (also often referred to as *lambdas*).

## Features

`anon` provides three user-facing functions:

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
3.  `formula_to_function()` is the simplest example of converting a
    formula to a function. This function is free of any dependency on
    `rlang`, but has quite limited functionality i.e. it assumes that
    the required function only takes a maximum of 3 arguments (`.x`,
    `.y`, `.z`)

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
  - `L(x:y ~ x + y)`

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

## `formula_to_function()`

The `anon` package aims to be comprehensive on what sort of formula
construction is allowed. However it is not yet on CRAN (which can be
inconvenient) and it is a dependency you may not want.

So `anon::formula_to_function()` is an example of a very portable,
dependency-free way to create functions from formulas that could be
extracted from `anon` and used in your own code. It has some severe
restrictions

  - Input can only be a 1-sided formula e.g. `~.x + 1`
  - The created function takes 3 formal argument (`.x`, `.y`, `.z`)
      - they must be given in this order, but it is not necessary to use
        them all
      - a single period (`.`) is also available as an alias of the first
        argument, `.x`

<!-- end list -->

``` r
f <- formula_to_function(~.x + .y)
f(2.5, 3)
#> [1] 5.5


g <- formula_to_function(~. + 10)
g(9)
#> [1] 19
```

The body of `formula_to_function()` is very simple, and is easily
copy/pasted into your code.

``` r
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a formula to a function
#'
#' This aims to be a dependency free, very simple formula-to-function convertor.
#'
#' The only supported arguments for the generated function are \code{.x, .y, .z}.
#' A single period (\code{.}) is an alias for \code{.x}. All other variables are assumed to
#' come from the environment.
#'
#' @param form formula
#' @param .env environment of function
#'
#' @return function whose code is taken from the RHS of the given formula, with
#' formal arguments of \code{.x, .y, .z}
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
formula_to_function <- function (form, .env = parent.frame())  {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # This is the entirity of the sanity checking
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (!inherits(form, 'formula') || length(form) != 2L) {
    stop("formula_to_function(): Argument 'form' must be a formula. ",
         "Current class: ", deparse(class(form)), call. = FALSE)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Creat func with formal arguments (.x, .y, .z).   '.' acts an alias for '.x'
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  f              <- function() {}
  formals(f)     <- alist(.x = , .y =, .z =, . = .x)
  body(f)        <- form[[-1]]
  environment(f) <- .env

  f
}
```
