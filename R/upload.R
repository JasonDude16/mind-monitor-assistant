get_events <- function(df, elements_col, srate, drop = "/muse/elements/") {
  tibble::tibble(
    "eventloc" = which(df[[elements_col]] != ""),
    "eventloc_sec" = eventloc / srate,
    "events_full" = df[[elements_col]][eventloc],
    "events_partial" = stringr::str_remove(events_full, drop)
  )
}

get_srate <- function(ts, round = TRUE) {
  x <- as.POSIXct(ts)
  srate <- length(x) / (as.numeric(x[length(x)] - x[1]) * 60)
  if (round) {
    srate <- round(srate, 0)
  }
  return(srate)
}
