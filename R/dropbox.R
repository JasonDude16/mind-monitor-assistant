print_recent_files <- function(folder, regex = "[0-9]{4}-[0-9]{2}-[0-9]{2}--[0-9]{2}-[0-9]{2}-[0-9]{2}", range = 1:20) {
  
  files <- list.files(folder)
  dates <- stringr::str_extract(files, regex)
  
  if (length(files) < max(range)) {
    recent <- files[rev(order(dates))]
  } else {
    recent <- files[rev(order(dates))][range]
  }
  
  return(recent)
}