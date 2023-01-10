plot_filter <- function(kern, srate, xlim = NULL) {
  hz <- seq(0, srate, length.out = length(kern))
  par(mfrow = c(1, 2))
  plot(
    0:(length(kern) - 1) / srate,
    kern,
    type = "l",
    xlab = "Time (s)",
    ylab = ""
  )
  plot(
    hz[1:(length(kern) / 2)],
    abs(fft(kern)[1:(length(kern) / 2)])^2,
    type = "l",
    xlab = "Frequency (Hz)",
    ylab = "Gain",
    xlim = xlim
  )
  par(mfrow = c(1, 1))
}

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