
globalVariables('.x')

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

