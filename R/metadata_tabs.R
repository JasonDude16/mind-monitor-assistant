metadata_tabs <- tabsetPanel(
  id = "metadata_tabs",
  type = "hidden",
  tabPanel(
    title = "Subject",
    textInput(
      inputId = "subj_name", 
      label = "Subject name"
    ),
    numericInput(
      inputId = "id",
      label = "ID",
      value = 100,
      min = 100,
      max = 999,
      step = 1
    ),
    selectInput(
      inputId = "sex",
      label = "Sex",
      choices = c("Male", "Female")
    ),
    dateInput(
      inputId = "dob", 
      label = "Date of Birth"
    ),
    numericInput(
      inputId = "caffeine",
      label = "Caffeine intake in previous 2 hrs",
      min = 0,
      max = 500,
      value = 120
    )
  ),
  tabPanel(
    title = "State"
  ),
  tabPanel(
    title = "Experiment",
    textInput(
      inputId = "exp_name", 
      label = "Experiment name"
    ),
    textInput(
      inputId = "exp_descr", 
      label = "Experiment description"
    ),
    selectInput(
      inputId = "condition",
      label = "Condition",
      choices = c("resting-EC", "resting-EO", "meditation-EC", "meditation-EO", "sleep", "nap")
    ),
    selectInput(
      inputId = "posture",
      label = "Posture",
      choices = c("seated- back supported", "seated- back unsupported", "standing", "lying down")
    ),
    selectInput(
      inputId = "location",
      label = "Location",
      choices = c("home-room")
    ),
    selectInput(
      inputId = "rating",
      label = "Recording Rating",
      choices = c("poor", "okay", "good")
    ),
    selectInput(
      inputId = "watered", 
      label = "Electrodes watered",
      choices = c("no", "yes")
    )
  ),
  tabPanel(
    title = "Misc",
    textInput(
      inputId = "comments", 
      label = "Comments"
    )
  )
)