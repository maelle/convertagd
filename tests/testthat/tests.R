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
  expect_true(file.exists(paste0(path_to_directory, "/", "settings.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "raw_data.csv")))
  batch_read_agd(path_to_directory, tz="GMT",
                 all_in_one=FALSE)
  expect_true(file.exists(paste0(path_to_directory, "/", "dummyCHAI2_settings.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "dummyCHAI2_raw.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "dummyCHAI_settings.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "dummyCHAI_raw.csv")))

})

test_that("batch_read_agd outputs errors",{
  skip_on_cran()
  path_to_directory <- system.file("extdata", package = "convertagd")
  expect_error(batch_read_agd(path_to_directory, tz="GMT",
                 all_in_one=TRUE),"There are already")
  expect_error(batch_read_agd(path_to_directory, tz="GMT",
                              all_in_one=FALSE),"There are already")

  file.remove(paste0(path_to_directory, "/", "settings.csv"))
  file.remove(paste0(path_to_directory, "/", "raw_data.csv"))
  file.remove(paste0(path_to_directory, "/", "dummyCHAI2_settings.csv"))
  file.remove(paste0(path_to_directory, "/", "dummyCHAI2_raw.csv"))
  file.remove(paste0(path_to_directory, "/", "dummyCHAI_settings.csv"))
  file.remove(paste0(path_to_directory, "/", "dummyCHAI_raw.csv"))
})
