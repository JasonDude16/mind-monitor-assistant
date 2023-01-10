compute_psd <- function(df, srate, window, chans, method = "fft", scale = "amp") {
  
  if (!any(scale %in% c("amp", "power", "dB"))) {
    stop("Options for scale are: `amp`, `power`, `dB`")
  }
  
  win <- window * srate
  win <- (win[1] + 1):win[2]
  
  # subset to window and channels
  x <- tidyr::drop_na(tibble::as_tibble(df[win, chans]))
  
  if (method == "fft") {
    # linearly spaced freqs to nyquist 
    hz <- seq(0, srate / 2, length.out = floor(nrow(x) / 2) + 1)
    fc <- Re(fft(as.matrix(x)))
    # normalization: multiply by 2 because amplitude is split between positive and negative 
    # frequencies for real-valued signal; 0 and nyquist should not be doubled 
    # https://www.udemy.com/course/solved-challenges-ants/learn/lecture/17322760#overview
    fc <- tibble::as_tibble(fc / nrow(x))
    spectrm <- purrr::map_df(fc, ~ c(.x[1], 2*abs(.x[-c(1, length(.x))]), .x[length(.x)])) 
  }
  
  if (scale == "power") {
    spectrm <- tibble::as_tibble(spectrm^2)
    
  } else if (scale == "dB") {
    spectrm <- tibble::as_tibble(10*log10(spectrm^2))
    
  }
  
  # column names were dropped if only one channel was selected
  colnames(spectrm) <- chans
  
  return(list("spectrum" = spectrm, "hz" = hz))
  
}