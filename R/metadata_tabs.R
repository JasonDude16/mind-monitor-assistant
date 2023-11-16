metadata_tabs <- tabsetPanel(
  id = "metadata_tabs",
  type = "hidden",
  tabPanel(
    title = "Subject",
    textInput(
      inputId = "subj_name", 
      label = "Subject name",
      value = "Jason"
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
      choices = c("male", "female")
    ),
    dateInput(
      inputId = "dob", 
      label = "Date of Birth",
      value = "1996-05-17"
    ),
    textInput(
      inputId = "subj_comments", 
      label = "Subject Comments"
    )
  ),
  tabPanel(
    title = "State",
    selectInput(
      inputId = "tension_anxiety",
      label = "Tension-Anxiety",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    selectInput(
      inputId = "depression_dejection",
      label = "Depression-Dejection",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    selectInput(
      inputId = "anger_hostility",
      label = "Anger-Hostility",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    selectInput(
      inputId = "fatigue_inertia",
      label = "Fatigue-Inertia",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    selectInput(
      inputId = "confusion_bewilderment",
      label = "Confusion-Bewilderment",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    selectInput(
      inputId = "vigor_activity",
      label = "Vigor-Activity",
      selected = "unknown",
      choices = c("1", "2", "3", "4", "5", "unknown")
    ),
    textInput(
      inputId = "state_comments",
      label = "State Comments"
    )
  ),
  tabPanel(
    title = "Experiment",
    textInput(
      inputId = "exp_name", 
      label = "Experiment name",
      value = "NA"
    ),
    selectInput(
      inputId = "condition",
      label = "Condition",
      selected = "unknown",
      choices = c(
        "resting-EC",
        "resting-EO",
        "meditation-EC",
        "meditation-EO",
        "sleep",
        "nap",
        "unknown"
      )
    ),
    selectInput(
      inputId = "posture",
      label = "Posture",
      selected = "unknown",
      choices = c(
        "seated- back supported",
        "seated- back unsupported",
        "standing",
        "lying down",
        "walking",
        "unknown"
      )
    ),
    selectInput(
      inputId = "location",
      label = "Location",
      selected = "unknown",
      choices = c("home-room", "unknown")
    ),
    selectInput(
      inputId = "rating",
      label = "Recording Rating",
      selected = "unknown",
      choices = c("poor", "fair", "good", "unknown")
    ),
    selectInput(
      inputId = "watered", 
      label = "Electrodes watered",
      selected = "unknown",
      choices = c("no", "yes", "unknown")
    ),
    textInput(
      inputId = "exp_comments", 
      label = "Experiment Comments"
    )
  ),
  tabPanel(
    title = "Misc",
    numericInput(
      inputId = "caffeine",
      label = "Caffeine intake in previous 2 hrs (mg)",
      min = 0,
      max = 500,
      value = 0
    ),
    selectInput(
      inputId = "physical_activity",
      label = "Physically active in last 60 min before recording?",
      selected = "unknown",
      choices = c("yes", "no", "unknown")
    )
  )
)