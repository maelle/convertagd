#' Reading a agd file
#'
#' @importFrom RSQLite SQLite
#' @importFrom DBI dbConnect dbReadTable
#' @importFrom dplyr tbl_df mutate_ select_
#' @importFrom lazyeval interp
#' @importFrom lubridate dmy
#' @importFrom PhysicalActivity wearingMarking
#' @param file Full path to the agd file to be converted
#' @param tz Timezone of the measurements
#'
#' @return A list of two data tables with the settings and the measurements.
#' @export
#'
#' @examples
#' file <- system.file("extdata", "dummyCHAI.agd", package = "convertagd")
#' testRes <- read_agd(file, tz = "GMT")
#' testRes[[1]]
#' testRes[[2]]
read_agd <- function(file, tz = "GMT"){
  # Connect to database and fetch the settings table
  con <- DBI::dbConnect(RSQLite::SQLite(), file)
  ad_set <- DBI::dbReadTable(con, "settings")
  ad_set <<- ad_set
  # find start date
  raw_start <- ad_set$"settingValue"[ad_set$"settingName" ==
                                       "startdatetime"]
  # first convert to POSIXlt
  origen <- as.POSIXlt( (as.numeric(raw_start) / 1e7),
                       origin = "0001-01-01 00:00:00",
                       tz = "GMT")
  # then change to write timezone
  origen <- as.POSIXct(as.character(origen), tz = tz)

  # find length
  longitud <- ad_set$"settingValue"[ad_set$"settingName" ==
                                      "epochcount"]
  longitud <- as.numeric(longitud)
  # now fetch the measurements table
  base <- DBI::dbReadTable(con, "data")
  base <- dplyr::tbl_df(base)
  base <- dplyr::mutate_(base,
                        date = lazyeval::interp(~ origen +
                          seq(from = 0, by = 10,
                        length.out = longitud)))
  base <- dplyr::select_(base,
                         .dots = list(quote(date),
                         lazyeval::interp(~ everything()),
                         quote(-dataTimestamp))) # nolint

  ad_set <- dplyr::tbl_df(ad_set)
  res <- list(settings = ad_set,
              raw.data = base)
  return(res)
}
