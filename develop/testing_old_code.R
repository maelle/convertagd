file <- system.file("extdata", "dummyCHAI.agd", package = "convertagd")
source("develop/chai.actigraph.tools_20160126.R")
lala <- read.acti(file)

###############
library("convertagd")
library("dplyr")
file <- system.file("extdata", "dummyCHAI.agd", package = "convertagd")
testRes <- read_agd(file, tz = "GMT")
lala <- dplyr::mutate(testRes[[2]],
                      axis1._1 = lag(axis1, 1),
                      axis1.1 = lead(axis1, 1))
