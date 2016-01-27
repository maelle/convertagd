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

#################################################################################################
context("batch_read_agd")
#################################################################################################
test_that("batch_read_agd outputs files",{
  skip_on_cran()
  path_to_directory <- system.file("extdata", package = "convertagd")
  batch_read_agd(path_to_directory, tz="GMT",
                 all_in_one=TRUE)
  expect_true(file.exists("settings.csv"))
  expect_true(file.exists("raw_data.csv"))
  batch_read_agd(path_to_directory, tz="GMT",
                 all_in_one=FALSE)
  expect_true(file.exists("dummyCHAI2_settings.csv"))
  expect_true(file.exists("dummyCHAI2_raw.csv"))
  expect_true(file.exists("dummyCHAI_settings.csv"))
  expect_true(file.exists("dummyCHAI_raw.csv"))

})

test_that("batch_read_agd outputs errors",{
  skip_on_cran()
  path_to_directory <- system.file("extdata", package = "convertagd")
  expect_error(batch_read_agd(path_to_directory, tz="GMT",
                 all_in_one=TRUE),"There are already a settings.csv and/or a raw_data.csv in your working directory !")
  expect_error(batch_read_agd(path_to_directory, tz="GMT",
                              all_in_one=FALSE),"There are already adummyCHAI_settings.csv and/or adummyCHAI_raw.csv in your working directory !")

  file.remove("settings.csv")
  file.remove("raw_data.csv")
  file.remove("dummyCHAI2_settings.csv")
  file.remove("dummyCHAI2_raw.csv")
  file.remove("dummyCHAI_settings.csv")
  file.remove("dummyCHAI_raw.csv")
})
