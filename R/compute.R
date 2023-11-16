# FFT normalization: 
## 1) normalize by length of signal 
## 2) multiply by 2 because amplitude is split between positive and negative freqs 
# https://www.udemy.com/course/solved-challenges-ants/learn/lecture/17322760#overview

fft_wrap <- function(x, srate) {
  
  if (!is.data.frame(x) || !is.matrix(x)) {
    x <- as.matrix(x)
  } 
  
  N <- nrow(x)
  hz <- seq(0, srate / 2, length.out = floor(N / 2) + 1)
  
  fc <- mvfft(as.matrix(x))
  fc <- fc / N
  spectrm <- apply(fc, 2, function (x) 2*abs(x[1:length(hz)]))
  spectrm <- tibble::as_tibble(spectrm)
  
  return(list("spectrum" = spectrm, "hz" = hz))
  
}

pwelch <- function(x, srate, winlen = 4*srate, overlap = .5) {

  if (!is.matrix(x) || !is.data.frame(x)) {
    x <- as.matrix(x)
  }
  
  # hann taper
  hwin <- .5 * (1-cos(2*pi*(1:winlen) / (winlen-1)))
  
  # get freqs and windows to loop over
  hz <- seq(0, srate/2, length.out = floor(winlen/2) + 1)
  windows <- seq(1, nrow(x) - winlen, winlen - winlen*overlap)
  
  nbins <- 1
  welchspect <- matrix(0, ncol = ncol(x), nrow = length(hz))
  for (wini in round(windows)) {
    # ensure the input stays a matrix 
    xsub <- as.matrix(x[wini:(wini + winlen - 1), ])
    
    # apply hanning to taper edges of window
    xsub_hann <- apply(xsub, 2, function(x) x * hwin)
    
    # apply fft and add to welchspect
    fc <- mvfft(as.matrix(xsub_hann)) / winlen
    welchspect <- welchspect + 2*abs(fc[1:length(hz), ]) 
    nbins <- nbins + 1
  }
  
  # average welchspect across bins
  welchspect <- welchspect / nbins
  welchspect <- tibble::as_tibble(welchspect)
  
  return(list("spectrum" = welchspect, "hz" = hz))
}

compute_psd <- function(df, srate, window, chans, scale = "amp", method = "welch", ...) {

  if (!any(scale %in% c("amp", "power", "dB"))) {
    stop("Options for scale are: `amp`, `power`, `dB`")
  }
  
  if (!any(method %in% c("fft", "welch"))) {
    stop("Options for method are: `fft`, `welch`")
  }
  
  win <- window * srate
  win <- (win[1] + 1):win[length(win)]
  
  # subset to window and channels
  x <- tidyr::drop_na(tibble::as_tibble(df[win, chans]))
  
  if (method == "welch") {
    psd <- pwelch(x, srate, ...)
    hz <- psd$hz
    spectrm <- psd$spectrum
  }

  if (method == "fft") {
    psd <- fft_wrap(x, srate)
    hz <- psd$hz
    spectrm <- psd$spectrum
  }
  
  if (scale == "power") {
    spectrm <- tibble::as.tibble(spectrm^2)
    
  } else if (scale == "dB") {
    spectrm <- tibble::as_tibble(10*log10(spectrm^2))
    
  }
  
  # column names were dropped if only one channel was selected
  colnames(spectrm) <- chans
  
  return(list("spectrum" = spectrm, "hz" = hz))
  
}
