
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lambda expressions
#'
#' @param ... dots
#' @param .env environment of function
#'
#' @return function
#'
#' @import rlang
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
lambda <- function (..., .env = parent.frame())  {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Capture the dots (without evaluating) + count them
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dots <- match.call(expand.dots = FALSE)$...
  n    <- length(dots)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If the last argument is a formula, unpack it i.e.
  #  - the LHS are argument names for the resulting lambda.
  #     - usually only a single argname expected e.g.   x ~ x + 1
  #     - but to be compat with gsubfn, allow `x + y ~ x + y + z` and
  #       `x:y ~ x + y + z`
  #  - the RHS is the body of the lambda
  #
  # If the last argument is not a formula, then treat it as the body of the lambda
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  last_arg_is_formula <- rlang::is_formula(dots[[n]])
  if (last_arg_is_formula) {
    body                <- rlang::f_rhs(dots[[n]])
    extra_arg_names     <- all.vars(rlang::f_lhs(dots[[n]]))
  } else {
    body                <- dots[[n]]
    extra_arg_names     <- character(0)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If no argument names were provided, then parse out all the variable names
  # from the function body and use them as the formal arguments. The order of
  # the formal argumens is the order in which they first appear in the body.
  #
  # Otherwise, create a vector of all the argnames by joining the
  # lead argnames with the extra argnames
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (n == 1 && length(extra_arg_names) == 0L) {
    all_arg_names <- all.vars(body)
  } else {
    first_args      <- dots[-n]
    first_arg_names <- as.character(substitute(first_args))
    all_arg_names   <- c(first_arg_names, extra_arg_names)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create a proper list of formal args for the function. Since this lambda
  # implementation does not support default args, all args point to a empty
  # epxression so that they're properly converted within `rlang::new_function()`
  # using `as.pairlist()`
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- rlang::set_names(rep(list(rlang::expr()), length(all_arg_names)), all_arg_names)


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create and return a new function
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  rlang::new_function(args, body, .env)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname lambda
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
L <- lambda


if (FALSE) {
  L(x + y)
  L(~x + y)
  L(x, y, x + y)
  L(x, y ~ x + y)
  L(x, y, ~x + y)
  L(x:y ~ x + y)
}
