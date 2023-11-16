library(shiny)
library(shinythemes)

options(shiny.maxRequestSize = 300*1024^2, readr.show_progress = FALSE)

shinyUI(
  fluidPage(
    shinyjs::useShinyjs(),
    theme = shinytheme("darkly"),
    titlePanel("Mind Monitor Assistant"),
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          id = "tabs",
          tabPanel(
            title = "DropBox",
            br(),
            uiOutput("ui_not_authenticated_text"),
            uiOutput("ui_authenticated_text"),
            br(),
            textInput(
              inputId = "dbfolder", 
              label = "Dropbox folder", 
              value = "Apps/Mind Monitor"
            ),
            textInput(
              inputId = "localfolder", 
              label = "Local folder",
              value = "~/Documents/Data/muse/dropbox"
            ),
            checkboxInput(
              inputId = "overwrite_db",
              label = "Allow overwrite"
            ),
            checkboxInput(
              inputId = "showfolder", 
              label = "Show recent files in local folder"
            ),
            verbatimTextOutput("folder"),
            fluidRow(
              column(
                uiOutput("ui_not_authenticated_button"),
                uiOutput("ui_authenticated_button"),
                width = 3
              ),
              column(
                actionButton(
                  inputId = "delete_token", 
                  label = "Delete Token", 
                  icon = icon("x"),
                  style = "margin-top: 10px; margin-left: 30px; font-size: 16px"
                ),
                width = 3
              ),
              column(
                actionButton(
                  inputId = "reload", 
                  label = "Refresh App", 
                  icon = icon("rotate-right"),
                  style = "margin-top: 10px; margin-left: 30px; font-size: 16px"
                ),
                width = 6
              )
            ),
          ),
          tabPanel(
            title = "Load Data",
            br(),
            numericInput(
              inputId = "duration", 
              label = "Max duration to upload (in sec)", 
              min = 1,
              max = 600,
              value = 30
            ),
            numericInput(
              inputId = "srate", 
              label = "Sampling rate", 
              min = 1,
              max = 1024,
              value = 256
            ),
            fileInput(
              inputId = "file", 
              label = "Select CSV file", 
              accept = ".csv"
            ),
            verbatimTextOutput("df")
          ),
          tabPanel(
            title = "Transform",
            br(),
            numericInput(
              inputId = "l_freq", 
              label = "High pass filter", 
              value = 0.5, 
              min = 0.1
            ),
            numericInput(
              inputId = "h_freq", 
              label = "Low pass filter", 
              value = 35
            ),
            selectInput(
              inputId = "downsample",
              label = "Downsample factor",
              choices = c(1, 2, 4, 8),
              selected = 1
            ),
            checkboxInput(
              inputId = "convert", 
              label = "Convert RAW MUSE units to uV",
              value = TRUE
            ),
            verbatimTextOutput("transformations"),
            actionButton(
              inputId = "apply",
              label = "Apply",
              width = "80px",
              style = "margin-top: 8px; font-size: 16px"
            )
          ),
          tabPanel(
            title = "Plot",
            br(),
            selectInput(
              inputId = "plot",
              label = "Plot type",
              choices = c("Raw", "PSD", "FOOOF")
            ),
            selectInput(
              inputId = "chans",
              label = "Channels",
              choices = c(""),
              multiple = TRUE
            ),
            textInput(
              inputId = "plot_title",
              label = "Plot title",
              value = "My brain waves"
            ),
            sliderInput(
              inputId = "window",
              label = "Window",
              min = 0,
              max = 100,
              value = c(0, 10),
              animate = TRUE
            ),
            plot_tabs,
            actionButton(
              inputId = "saveplot", 
              label = "Save Plot",
              width = "120px",
              icon = icon("save"),
              style = "margin-top: 8px; font-size: 16px"
            )
          ),
          tabPanel(
            title = "Metadata",
            br(),
            selectInput(
              inputId = "category",
              label = "Category",
              choices = c("Subject", "State", "Experiment", "Misc")
            ),
            hr(style = "border: 1px solid #34A56F"),
            metadata_tabs,
            hr(style = "border: 1px solid #34A56F"),
            textInput(inputId = "outname", label = "Metadata file name"),
            checkboxInput(
              inputId = "overwrite_metadata",
              label = "Allow overwrite"
            ),
            actionButton(
              inputId = "savemetadata", 
              label = "Save Metadata",
              width = "150px",
              icon = icon("save"),
              style = "margin-top: 8px; font-size: 16px"
            )
          )
        )
      ),
      mainPanel(
        plotOutput("plot", height = "700px")
      )
    )
  ) 
)