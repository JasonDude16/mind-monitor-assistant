plot_tabs <- tabsetPanel(
  id = "plot_tabs",
  type = "hidden",
  tabPanel(
    title = "Raw",
    checkboxInput(
      inputId = "plot_events",
      label = "Plot events",
      value = TRUE
    ),
    checkboxInput(
      inputId = "overlay",
      label = "Overlay channels"
    ),
    checkboxInput(
      inputId = "scale_by_window",
      label = "Scale by window",
      value = TRUE
    ),
    checkboxInput(
      inputId = "common_scale",
      label = "Common Scale",
      value = TRUE
    ),
    checkboxInput(
      inputId = "range_labs",
      label = "Show range labels",
      value = TRUE
    ),
    checkboxInput(
      inputId = "hlines",
      label = "Show horizontal lines",
      value = TRUE
    ),
    numericInput(
      inputId = "scale_fctr", 
      label = "Scale Factor", 
      value = 0.5
    )
  ),
  tabPanel(
    title = "PSD",
    radioButtons(
      inputId = "method",
      label = "Method",
      choiceValues = c("fft", "welch"),
      choiceNames = c("FFT", "Welch"),
      selected = "welch"
    ),
    radioButtons(
      inputId = "scale",
      label = "Scale",
      choiceValues = c("amp", "power"),
      choiceNames = c("Ampltiude", "Power"),
      selected = "power"
    )
  ),
  tabPanel(
    title = "FOOOF",
    sliderInput(
      inputId = "freq_range",
      label = "Frequency Range", 
      min = 1, 
      max = 50, 
      step = 1, 
      value = c(2, 30)
    ),
    numericInput(
      inputId = "min_peak_ht",
      label = "Minimum Peak Height",
      value = 0,
      min = 0
    ),
    numericInput(
      inputId = "peak_thresh",
      label = "Peak Threshold",
      value = 2,
      min = 0
    ),
    radioButtons(
      inputId = "space",
      label = "Space",
      choiceValues = c("log", "linear"),
      choiceNames = c("Log-Log", "Linear"),
      selected = "log"
    )
  )
)