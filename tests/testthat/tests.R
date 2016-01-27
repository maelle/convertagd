library("convertagd")
#################################################################################################
context("read_agd")
#################################################################################################
test_that("read_agd outputs a list of two tbl_df",{
  file <- system.file("extdata", "dummyCHAI.agd", package = "convertagd")
  testRes <- read_agd(file, tz = "GMT")
  expect_that(testRes, is_a("list"))
  expect_that(length(testRes), equals(2))
  expect_that(testRes[[1]], is_a("tbl_df"))
  expect_that(testRes[[2]], is_a("tbl_df"))
})

#################################################################################################
if (requireNamespace("lintr", quietly = TRUE)) {
  context("lints")
  test_that("Package Style", {
    skip_on_appveyor()
    lintr::expect_lint_free()
  })
}
