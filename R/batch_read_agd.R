#' Reading several agd files and converting the settings and raw data tables to csv.
#'
#' @importFrom readr write_csv
#' @importFrom dplyr mutate_
#' @param path_to_directory path to the directory where all agd are saved.
#' @param tz Timezone. It must be the same for all files
#'
#' @examples
#' \dontrun{
#' path_to_directory <- system.file("extdata", package = "convertagd")
#' batch_read_agd(path_to_directory, tz="GMT",
#'                all_in_one=TRUE)
#'                }
#' @details
#' The function saves results in the input directory as csv files with a "," as separator.
#' Tthe output tables will be called settings.csv and raw_data.csv.
#' @return
#' @export
#'
#' @examples
batch_read_agd <- function(path_to_directory, tz){
  # find files to transform
  list_files <- list.files(path_to_directory,
                           full.names = TRUE)
  list_files <- list_files[grepl("\\.agd",
                                 list_files)]


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



  # check files do not exist
  if (file.exists(paste0(path_to_directory,
                         "/settings.csv")) |
      file.exists(paste0(path_to_directory,
                         "/raw_data.csv"))){
    stop("There are already a settings.csv and/or a raw_data.csv in the directory !")# nolint
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
                   path = paste0(path_to_directory,
                                 "/raw_data.csv"),
                   append = TRUE)

  # loop over files

  for (file in list_files){
    converted <- read_agd(file, tz = tz)
    settings <- as.data.frame(t(converted[[1]]$"settingValue"))

    colnames(settings) <- settings_names
    settings <- mutate_(settings, filename = ~ file)

    # first line of the settings file
    if (!file.exists(paste0(path_to_directory,
                            "/settings.csv"))){
      readr::write_csv(settings,
                       path = paste0(path_to_directory,
                                     "/settings.csv"),
                       append = FALSE)
    }
    else{
      readr::write_csv(settings,
                       path = paste0(path_to_directory,
                                     "/settings.csv"),
                       append = TRUE)
    }

    # The raw data file should include a file_name column
    file_name <- gsub(path_to_directory, "", file)
    file_name <- gsub("/", "", file_name)
    file_name <- gsub(".agd", "", file_name)
    raw <- converted[[2]]
    raw <- dplyr::mutate_(raw,
                          file_name = ~ file_name)

    # better to keep datetime as character
    raw <- dplyr::mutate_(raw, timedate = lazyeval::interp(~ as.character(timedate)))

    readr::write_csv(raw, path = paste0(path_to_directory,
                                        "/raw_data.csv"),
                     append = TRUE)

  }

  # done, does not return anything.
}
