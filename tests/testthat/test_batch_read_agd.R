#################################################################################################
context("batch_read_agd")
#################################################################################################
test_that("batch_read_agd outputs files",{
  skip_on_cran()
  path_to_directory <- system.file("extdata", package = "convertagd")
  batch_read_agd(path_to_directory, tz="GMT")
  expect_true(file.exists(paste0(path_to_directory, "/", "settings.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "raw_data.csv")))


})

test_that("batch_read_agd outputs errors",{
  skip_on_cran()
  path_to_directory <- system.file("extdata", package = "convertagd")
  expect_error(batch_read_agd(path_to_directory, tz="GMT"),"There are already")

  file.remove(paste0(path_to_directory, "/", "settings.csv"))
  file.remove(paste0(path_to_directory, "/", "raw_data.csv"))
})
