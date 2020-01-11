

test_that("formula_to_function works", {
  f <- formula_to_function(~.x + 3)
  expect_equal(3.5, f(0.5))

  expect_error(formula_to_function('a'), 'character')

})
