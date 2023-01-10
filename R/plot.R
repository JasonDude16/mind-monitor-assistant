# scale 
plot_raw <- function(df, srate, window, chans, cols = NULL, str_rm = "RAW_", plot_title = NULL,
                     overlay = FALSE, scale_fctr = 0.5, range_labs = TRUE, hline = TRUE, scale_by_window = FALSE) {
  
  # tibble for consistency
  df <- tibble::as_tibble(df)
  
  # + 1 because R is 1-indexed
  win <- window * srate
  win <- (win[1] + 1):win[2]
  dur <- win / srate
  
  if (scale_by_window) {
    df <- df[win, chans]
    
  } else {
    # using all loaded data for y-axis scaling 
    df <- df[chans]
    
  }
  
  # default plot params
  yaxt <- NULL
  ylim <- range(df, na.rm = TRUE)

  if (!overlay) {
    
    ticks <- 1:(length(chans) + 1) * 2
    offset <- ticks[-1] - 1
    
    # getting ranges so we can add to plot
    maxs <- round(apply(df, 2, function(x) max(abs(range(x, na.rm = TRUE)))), 0)
    mins <- -maxs

    # adjust by scaling factor
    ymins <- offset - scale_fctr
    ymaxs <- offset + scale_fctr
    
    # make all values within -1:1 * scale_fctr and apply offset
    df <- purrr::map2_dfr(df, offset, function(.x, .y) {
      (.x / max(abs(range(.x, na.rm = TRUE)))) * scale_fctr + .y
    })
    
    # change default plotting params
    ylim <- c(min(ticks), max(ticks))
    yaxt <- "n"
    
  }
  
  # now subset to window since we've calculated ranges
  if (!scale_by_window) {
    df <- df[win, ]
  }
  
  if (is.null(cols)) {
    cols <- c("forestgreen", "steelblue", "darkred", "darkorange", "purple", "salmon")
  }
  
  # plotting first channel
  plot(
    x = dur,
    y = df[[chans[1]]],
    type = "l",
    col = cols[1],
    xlab = "Time(s)",
    ylab = "",
    ylim = ylim,
    yaxt = yaxt,
    main = plot_title
  )
  
  # adding additional channels to plot
  if (length(chans) > 1) {
    for (i in seq_along(chans)[-1]) {
      lines(dur, df[[chans[i]]], type = "l", col = cols[i])
    } 
  }
  
  if (!overlay) {
    axis(2, at = offset, labels = stringr::str_remove(chans, str_rm), las = 1)
    
    if (range_labs) {
      axis(2, at = ymins, labels = mins, las = 1)
      axis(2, at = ymaxs, labels = maxs, las = 1) 
    }
    
    if (hline) {
      labs <- c(ymins, ymaxs)
      for (lab in 1:length(labs)) {
        abline(h = labs[lab], lty = 2)
      } 
    }
    
  }
  
}

plot_psd <- function(spectrum, hz, chans = NULL, freq_min = 0.1, freq_max = max(hz), 
                     cols = NULL, str_rm = "RAW_", ...) {
  
  if (is.null(cols)) {
    cols <- c("forestgreen", "steelblue", "darkred", "darkorange", "purple", "salmon")
  }
  
  if (is.null(chans)) {
    chans <- colnames(spectrum)
  }
  
  # plotting subset, inclusive freq bounds
  index <- which(hz >= freq_min & hz <= freq_max)
  hz <- hz[index]
  spectrum <- spectrum[index, ]
  
  plot(
    hz,
    spectrum[[chans[1]]],
    type = "l",
    col = cols[1],
    xlab = "Frequency (Hz)",
    ...
  )
  
  # adding additional channels to plot
  if (length(chans) > 1) {
    for (i in seq_along(chans)[-1]) {
      lines(hz, spectrum[[chans[i]]], type = "l", col = cols[i])
    } 
  }
  
  legend(
    "topright",
    legend = stringr::str_remove(chans, str_rm),
    col = cols[1:length(chans)],
    lty = 1
  )
  
}
