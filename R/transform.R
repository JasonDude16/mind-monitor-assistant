downsample <- function(df, n) {
  df[seq(1, nrow(df), n), ]
}

rawmuse_to_mv <- function(df, col_names = NULL) {
  
  require(purrr)
  
  if (is.null(col_names)) {
    col_names <- colnames(df)
  }
  
  # converting from MUSE units to mV
  # https://www.krigolsonlab.com/muse-data-collection.html
  df[col_names] <- as.data.frame(map_if(df[col_names], is.numeric, function(.x) {
    (.x - mean(.x, na.rm = TRUE)) * 1.64498
  }))
  
  return(df)
  
}

fooof_as_tibble <- function(fm, space = "log") {
  
  df <- tibble(
    freqs = log10(fm$freqs),
    ps = fm$power_spectrum,
    fs = fm$fooofed_spectrum_,
    ap_offset = fm$aperiodic_params_[1],
    ap_exponent = fm$aperiodic_params_[2],
    slope = ap_offset + (-ap_exponent * freqs),
    r2 = fm$r_squared_
  )
  
  if (space == "linear") {
    df[c("freqs", "ps", "fs", "slope")] <- 10^df[c("freqs", "ps", "fs", "slope")]
  }
  return(df)
}

fir_kernel <- function(srate, l_freq, h_freq, order = 500) {
  
  nyquist <- srate * .5
  band_edges <- c(l_freq / nyquist, h_freq / nyquist)
  
  firkern <- signal::fir1(order, band_edges, type = "pass")
  
  return(firkern)
  
}