#' Reading several agd files and converting the settings and raw data tables to csv.
#'
#' @importFrom readr write_csv
#' @importFrom dplyr mutate
#' @param pathToDirectory path to the directory where all agd are saved.
#' @param tz Timezone. It must be the same for all files
#' @param allInOne Boolean indicating whether the output should be a list of list of two tables
#' (settings and raw data)
#'  or a list of two tables (settings and raw data for all files with a column filename)
#'
#' @examples
#' \dontrun{
#' pathToDirectory <- system.file("extdata", package = "convertagd")
#' batch_read_agd(pathToDirectory, tz="GMT",
#'                allInOne=TRUE)
#'                }
#' @details
#' The function saves results in the working directory as csv files with a "," as separator.
#' If allInOne=TRUE, the output tables
#'  in this case will be called settings.csv and raw_data.csv. Else there will be a settings
#'  and a raw data file (originalfilename_settings.csv and originalfilename_raw.csv) for each
#'   file.
#' @return
#' @export
#'
#' @examples
batch_read_agd <- function(pathToDirectory, tz,
                           allInOne){
  # find files to transform
  listFiles <- list.files(pathToDirectory,
                          full.names = TRUE)
  listFiles <- listFiles[grepl(".agd", listFiles)==TRUE]


  # names of the settings
  settingsName <- c("softwarename", "softwareversion",
                    "osversion", "machinename",
                    "datetimeformat", "decimal",
                    "grouping", "culturename",
                    "finished", "devicename",
                    "filter", "deviceserial",
                    "deviceversion", "modenumber",
                    "epochlength", "startdatetime",
                    "stopdatetime", "downloaddatetime",
                    "batteryvoltage", "original sample rate",
                    "subjectname", "sex", "race",
                    "limb", "epochcount",
                    "sleepscorealgorithmname",
                    "customsleepparameters",
                    "notes" )


  if(allInOne == TRUE){
    # check files do not exist
    if(file.exists("settings.csv") |
       file.exists("raw_data.csv")){
      stop("There are already a settings.csv and/or a raw_data.csv in your working directory !")
    }

    # loop over files
    for(file in listFiles){
      converted <- read_agd(file, tz=tz)
      settings <- as.data.frame(t(converted[[1]]$settingValue))
      colnames(settings) <- settingsName
      # first line of the settings file
      if(!file.exists("settings.csv")){
        readr::write_csv(settings,
                         path = "settings.csv",
                         append = FALSE)
      }
      else{
        readr::write_csv(settings,
                         path = "settings.csv",
                         append = TRUE)
      }

      # The raw data file should include a fileName column
      fileName <- gsub(pathToDirectory, "", file)
      fileName <- gsub("/", "", fileName)
      fileName <- gsub(".agd", "", fileName)
      raw <- converted[[2]]
      raw <- dplyr::mutate(raw,
                   fileName=fileName)
      readr::write_csv(raw, path = "raw_data.csv",
                       append = TRUE)

    }
  }

  if(allInOne == FALSE){
    # loop over files
    for(file in listFiles){
      # filename
      fileName <- gsub(pathToDirectory, "", file)
      fileName <- gsub("/", "", fileName)
      fileName <- gsub(".agd", "", fileName)

      # check files do not exist
      settingName <- paste0(fileName, "_settings.csv")
      rawName <- paste0(fileName, "_raw.csv")
      if(file.exists(settingName) |
         file.exists(rawName)){
        stop(paste0("There are already a",
                    settingName,
                    " and/or a",
                    rawName,
                    " in your working directory !"))
      }
      # save the two files
      converted <- read_agd(file, tz=tz)
      settings <- as.data.frame(t(testRes[[1]]$settingValue))
      colnames(settings) <- settingsName
       readr::write_csv(settings,
                         path = settingName,
                         append = FALSE)

      raw <- converted[[2]]
      readr::write_csv(raw, path = rawName,
                       append = FALSE)

    }
  }
 # done, does not return anything.
}
