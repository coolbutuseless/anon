context("test-lambda")

test_that("multiplication works", {
  res0 <- function(x, y) x + y
  res1 <- lambda(x + y)
  res2 <- lambda(~x + y)
  res3 <- lambda(x, y, x + y)
  res4 <- lambda(x, y ~ x + y)
  res5 <- lambda(x, y, ~x + y)
  res6 <- lambda(x:y ~ x + y)

  expect_identical(res0, res1)
  expect_identical(res0, res2)
  expect_identical(res0, res3)
  expect_identical(res0, res4)
  expect_identical(res0, res5)
  expect_identical(res0, res6)

})
