get_events <- function(df, elements_col, srate, drop = "/muse/elements/") {
  tibble::tibble(
    "eventloc" = which(df[[elements_col]] != ""),
    "eventloc_sec" = eventloc / srate,
    "events_full" = df[[elements_col]][eventloc],
    "events_partial" = stringr::str_remove(events_full, drop)
  )
}
