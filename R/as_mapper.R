

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a formula to a function in a manner compatible with \code{rlang::as_function()} but with more features.
#'
#' This is a modified form of \code{anon::lambda()} which only accepts a single
#' argument which must be a formula (either one- or two-sides).
#'
#' Use this as an alternate \code{as_mapper} in \code{purrr} by running \code{anon::patch_purrr}.
#'
#' @param form formula. one- or two-sided
#' @param .env environment of function
#'
#' @return function derived from the formula
#'
#' @import rlang
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as_function_formula <- function (form, .env = parent.frame())  {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Unpack the formula
  #  - the RHS is the body of the anonymous function
  #  - the LHS (if present) is parsed and all variable names become
  #    formal argument names for the resulting anonymous function.
  #     - allow `x + y ~ x + y + z` and `x:y ~ x + y + z` in order to
  #       specify multiple variables on the LHS
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  body      <- rlang::f_rhs(form)
  arg_names <- all.vars(rlang::f_lhs(form))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If no argument names were provided, then parse out all the variable names
  # from the function body and use them as the formal arguments.
  # In most cases, the order of the formal arguments is the order in which
  # they first appear in the body.
  # However, if .x, .y or .z appear in the arg_names parsed from the body,
  # then they are moved to the front. This is to retain compatibility with
  # the default purrr/rlang lambda syntax. A stern warning is shown if you
  # try to mix argument types.
  # If "." appears as a formal argument name, then a stern warning is shown
  # if any other variable name is present.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (length(arg_names) == 0L) {
    arg_names <- all.vars(body)

    specials <- c('.x', '.y', '.z')
    if (any(arg_names %in% specials)) {
      if (!all(arg_names %in% specials)) {
        warning("You're mixing '.x' style arguments with named arguments. Because '.x' style arguments are moved to the front of the argument list, it's probably better not to mix argument types.")
      }
      idx       <- which(arg_names %in% c('.x', '.y', '.z'))
      front     <- arg_names[ idx]
      rest      <- arg_names[-idx]
      arg_names <- c(sort(front), rest)
    }

    if (length(arg_names) > 1L && '.' %in% arg_names) {
        warning("You're mixing a bare '.' argument with other arguments. It's probably better not to mix argument types like this.")
      idx       <- which(arg_names == '.')
      front     <- arg_names[ idx]
      rest      <- arg_names[-idx]
      arg_names <- c(front, rest)
    }
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create a proper list of formal args for the function. Since this lambda
  # implementation does not support default args, all args point to a empty
  # epxression so that they're properly converted within `rlang::new_function()`
  # using `as.pairlist()`
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- rlang::set_names(rep(list(rlang::expr()), length(arg_names)), arg_names)


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create and return a new function
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  rlang::new_function(args, body, .env)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' use \code{anon::as_function_formula()} in \code{purrr} to extend the supported
#' syntax for anonmous functions.
#'
#' Patch purrr to allow an extended anonymous function syntax.
#'
#' Purrr uses the generic \code{as_mapper()} to determine how to convert the function in a
#' \code{map()} call into an actual function. There are methods which deal with
#' character values, lists and numerics.  There is no method which deals explicitly with
#' forumulas - instead a formula will just fall through to \code{as_mapper.default()}.
#'
#' So by creating \code{as_mapper.formula()} we can catch any formulas before
#' \code{purrr::as_mapper.default()} and convert them into a function using
#' \code{anon::as_function_formula()}
#'
#' Note: This doesn't really patch purrr, it just adds another function to your
#' environment.  It certainly feels like patching/monkey-patching the package though,
#' so that's why it's named as such.
#'
#' @examples
#' \dontrun{
#' library(anon)
#' patch_purrr_mapper()
#' map(1:3, ~value + 1)
#' }
#'
#' @param envir default: parent.frame()
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
patch_purrr_mapper <- function (envir = parent.frame()) {
    force(envir)
    assign('as_mapper.formula', as_function_formula, envir = envir)
}

