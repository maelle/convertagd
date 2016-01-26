#' Reading a agd file
#'
#' @importFrom RSQLite SQLite
#' @importFrom DBI dbConnect dbReadTable
#' @importFrom dplyr tbl_df
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
  ad.set <- DBI::dbReadTable(con,"settings")
  ad.set <<- ad.set
  # find start date
  rawStart <- ad.set$settingValue[ad.set$settingName=="startdatetime"]
  # first convert to POSIXlt
  origen <- as.POSIXlt((as.numeric(rawStart)/1e7),
                       origin="0001-01-01 00:00:00", tz ="GMT")
  # then change to write timezone
  origen <- as.POSIXct(as.character(origen),tz=tz)

  # find length
  longitud <- ad.set$settingValue[ad.set$settingName=="epochcount"]
  longitud <- as.numeric(longitud)
  # now fetch the measurements table
  base <- DBI::dbReadTable(con, "data")
  base <- dplyr::tbl_df(base)
  base <- dplyr::mutate(base,
                        date = origen + seq(from=0,by=10,
                        length.out=longitud))
  base <- dplyr::select(base, date,
                        everything(),
                        -dataTimestamp)

  ad.set <- dplyr::tbl_df(ad.set)
  res <- list(settings=ad.set,
              raw.data=base)
  return(res)
}

