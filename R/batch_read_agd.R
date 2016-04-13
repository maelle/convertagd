#' Reading several agd files and converting the settings and raw data tables to csv.
#'
#' @importFrom readr write_csv
#' @importFrom dplyr mutate_
#' @param path_to_directory path to the directory where all agd are saved.
#' @param tz Timezone. It must be the same for all files
#' @param all_in_one Boolean indicating whether the output should be a list of list of two tables
#' (settings and raw data)
#'  or a list of two tables (settings and raw data for all files with a column file_name)
#'
#' @examples
#' \dontrun{
#' path_to_directory <- system.file("extdata", package = "convertagd")
#' batch_read_agd(path_to_directory, tz="GMT",
#'                all_in_one=TRUE)
#'                }
#' @details
#' The function saves results in the working directory as csv files with a "," as separator.
#' If all_in_one=TRUE, the output tables
#'  in this case will be called settings.csv and raw_data.csv. Else there will be a settings
#'  and a raw data file (originalfile_name_settings.csv and originalfile_name_raw.csv) for each
#'   file.
#' @return
#' @export
#'
#' @examples
batch_read_agd <- function(path_to_directory, tz,
                           all_in_one){
  # find files to transform
  list_files <- list.files(path_to_directory,
                          full.names = TRUE)
  list_files <- list_files[grepl(".agd",
                                 list_files) == TRUE]


  # names of the settings
  settings_names <- c("softwarename", "softwareversion",
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


  if (all_in_one == TRUE){
    # check files do not exist
    if (file.exists("settings.csv") |
       file.exists("raw_data.csv")){
      stop("There are already a settings.csv and/or a raw_data.csv in your working directory !")# nolint
    }

    # prepare file with raw data
    readr::write_csv(data.frame("date",
                       "axis1",
                       "axis2",
                       "axis4",
                       "steps",
                       "lux",
                       "incline",
                       "filename"),
                     path = "raw_data.csv",
                     append = TRUE)

    # loop over files

    for (file in list_files){
      converted <- read_agd(file, tz = tz)
      settings <- as.data.frame(t(converted[[1]]$"settingValue"))
      colnames(settings) <- settings_names
      settings <- mutate_(settings, filename = ~ file)

      # first line of the settings file
      if (!file.exists("settings.csv")){
        readr::write_csv(settings,
                         path = "settings.csv",
                         append = FALSE)
      }
      else{
        readr::write_csv(settings,
                         path = "settings.csv",
                         append = TRUE)
      }

      # The raw data file should include a file_name column
      file_name <- gsub(path_to_directory, "", file)
      file_name <- gsub("/", "", file_name)
      file_name <- gsub(".agd", "", file_name)
      raw <- converted[[2]]
      raw <- dplyr::mutate_(raw,
                   file_name = ~ file_name)
      readr::write_csv(raw, path = "raw_data.csv",
                       append = TRUE)

    }
  }

  if (all_in_one == FALSE){
    # loop over files
    for (file in list_files){
      # file_name
      file_name <- gsub(path_to_directory, "", file)
      file_name <- gsub("/", "", file_name)
      file_name <- gsub(".agd", "", file_name)

      # check files do not exist
      setting_name <- paste0(file_name, "_settings.csv")
      raw_name <- paste0(file_name, "_raw.csv")
      if (file.exists(setting_name) |
         file.exists(raw_name)){
        stop(paste0("There are already a",
                    setting_name,
                    " and/or a",
                    raw_name,
                    " in your working directory !"))
      }
      # save the two files
      converted <- read_agd(file, tz = tz)
      settings <- as.data.frame(t(converted[[1]]$"settingValue"))
      colnames(settings) <- settings_names
       readr::write_csv(settings,
                         path = setting_name,
                         append = FALSE)

      raw <- converted[[2]]
      readr::write_csv(raw, path = raw_name,
                       append = FALSE)

    }
  }
 # done, does not return anything.
}
