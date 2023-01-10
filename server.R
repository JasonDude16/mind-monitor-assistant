library(shiny)
library(shinythemes)
library(dplyr)
library(purrr)
library(rdrop2)
# https://github.com/karthik/rdrop2

options(shiny.maxRequestSize = 300*1024^2, readr.show_progress = FALSE)

shinyServer(function(input, output, session) {
  
  ########## DROPBOX SECTION ##########
  observeEvent(input$reload, {
    session$reload()
  })
  
  output$ui_not_authenticated_text <- renderUI({
    if (!file.exists(".httr-oauth")) {
      span(h3("Status: Not Authenticated", style = "color:salmon"))
    }
  })
  
  output$ui_not_authenticated_button <- renderUI({
    if (!file.exists(".httr-oauth")) {
      actionButton(
        inputId = "auth", 
        label = "Authenticate Me",
        icon = icon("user"),
        width = "165px",
        style = "margin-top: 10px; font-size: 16px"
      )
    }
  })
  
  observeEvent(input$auth, {
    drop_auth()
    showNotification("Authentication complete. Use the 'Refresh App' button to reload.", duration = NULL)
  })
  
  output$ui_authenticated_text <- renderUI({
    if (file.exists(".httr-oauth")) {
      span(h3("Status: Authenticated"), style = "color:lightgreen")
    }
  })
  
  output$ui_authenticated_button <- renderUI({
    if (file.exists(".httr-oauth")) {
      "button" = actionButton(
        inputId = "dbbutton", 
        label = "Download Data",
        icon = icon("download"),
        width = "165px",
        style = "margin-top: 10px; font-size: 16px"
      )
    }
  })
  
  output$folder <- renderPrint({
    if (input$showfolder) {
      cat("Files: ", paste(print_recent_files(input$localfolder, range = 1:20), "\n       "))
    }
  })
  
  observeEvent(input$dbbutton, {
    
    # verify dropbox folder is valid 
    fold <- tryCatch(
      drop_dir(input$dbfolder), 
      error = function(e) {showNotification("Error encountered. Make sure dropbox path is specified correctly. If issue persists, try re-authenticating")}
    )
    
    # if path was valid and data frame was returned
    if (is.data.frame(fold)) {
      
      # exclude zip files
      index <- stringr::str_which(basename(fold[["name"]]), ".zip")
      if (length(index) > 0) {
        fold <- fold[-index, ]
      }
      
      # get file paths
      files <- file.path(fold$path_display, paste0(basename(fold$path_display), ".csv"))
      
      # create local folder if it doesn't exist
      if (!dir.exists(input$localfolder)) {
        dir.create(input$localfolder)
      }
      
      # excluding files already in local folder if overwrite is false
      if (!input$overwrite_db) {
        files <- files[which(basename(files) %in% list.files(input$localfolder) == FALSE)]
      }
      
      withProgress(message = "Downloading files...", {
        purrr::walk(
          files,
          drop_download,
          input$localfolder,
          input$overwrite_db, 
          verbose = FALSE, 
          progress = FALSE
        )
        incProgress(1 / length(files))
      })
      
      showNotification("Download(s) complete!")
      
    }

  }, once = TRUE)
  
  ########## LOAD DATA SECTION ##########
  raw <- reactive({
    
    df <- suppressMessages(
      read.csv(
        file = input$file$datapath, 
        nrows = input$duration*input$srate
      )
    )
    
    events <- get_events(df, elements_col = "Elements", srate = input$srate)
    df <- df[-events[["eventloc"]], ]
    
    # get number of rows in file, assuming file has header (n - 1)
    cmd <- paste("cat", input$file$datapath, "| wc -l")
    n <- as.numeric(system(cmd, intern = TRUE)) - 1
    
    return(list("df" = df, "events" = events, "n" = n))
    
  })
  
  df <- reactive({
    
    df <- downsample(raw()$df, as.numeric(input$downsample))
    
    if (input$convert) {
      df <- rawmuse_to_mv(df, col_names = colnames(select(df, contains(input$raw_id))))
    }
    
    return(df)
  })
  
  output$df <- renderPrint({
    req(input$file)
    
    dur_min <- floor((raw()$n / input$srate) / 60)
    dur_sec <- round((raw()$n / input$srate) - (dur_min * 60), 0)
    
    fs <- input$file$size / 1e6
    size_in_mem <- lobstr::obj_size(data())
    
    if (fs < 1) {
      fs <- paste(round(fs * 1e3, 1), "kB")
    } else if (fs > 1000) {
      fs <- paste(round(fs / 1e3, 1), "GB")
    } else {
      fs <- paste(round(fs, 1), "MB")
    }
    
    if (size_in_mem < 1e6) {
      size_in_mem <- paste(round(size_in_mem / 1e3, 1), "kB")
    } else {
      size_in_mem <- paste(round(size_in_mem / 1e6, 1), "MB")
    }
    
    cat(
      " File size:          ", fs, "\n",
      "Size in memory:     ", size_in_mem, "\n",
      "First timestamp:    ", format.Date(df()$TimeStamp[1], method = 'toISOString'), "\n",
      "Number of rows:     ", raw()$n, "\n",
      "Recording duration: ", paste(dur_min, "min", dur_sec, "sec"), "\n",
      "Number of columns:  ", length(colnames(df())), "\n"
    )
  })
  
  ########## TRANSFORM SECTION ##########
  
  # TODO: this doesn't seem right
  observeEvent(input$apply, {
    output$transformations <- renderPrint({
      req(input$file)
      
      cat(
        " CURRENT SETTINGS ", "\n",
        "High pass filter: ", "\n",
        "Low pass filter:  ", "\n",
        "Notch filter:     ", "\n",
        "Resampling rate:  ", input$srate / as.numeric(input$downsample), "\n",
        "RAW data units:   ", ifelse(input$convert, "uV", "MUSE Units"), "\n"
      )
    })
  })
  
  ########## METADATA SECTION ##########
  observeEvent(input$category, {
    updateTabsetPanel(inputId = "metadata_tabs", selected = input$category)
  })
  
  observeEvent(c(input$file, input$id), {
    updateTextInput(
      inputId = "outname", 
      value = paste0(
        tools::file_path_sans_ext(input$file$name), 
        "_metadata_ID", 
        input$id,
        ".csv"
      )
    )
  })
  
  observeEvent(input$savemetadata, {
    
    if (is.null(input$file)) {
      showNotification("Need to upload a file before saving metadata!")
      
    } else {
      fp <- file.path(input$localfolder, input$outname)
      
      if (file.exists(fp) && !input$overwrite_metadata) {
        showNotification("File already exists. Please delete file before saving.")
        
      } else {
        write.csv(
          data.frame(
            path = input$localfolder,
            file = input$file$name,
            srate = input$srate,
            id = input$id,
            sex = input$sex,
            subj_name = input$subj_name,
            dob = input$dob,
            elec_watered = input$watered,
            exp_name = input$exp_name,
            exp_descr = input$exp_descr,
            condition = input$condition,
            posture = input$posture,
            location = input$location,
            caffeine = input$caffeine,
            rating = input$rating,
            comments = input$comments
          ),
          file = file.path(input$localfolder, input$outname)
        )
        
        showNotification(paste0("Saved to: ", input$localfolder, "!")) 
        
      }
      
    }
    
  })
  
  ########## PLOT SECTION ##########
  observeEvent(input$plot, {
    updateTabsetPanel(inputId = "plot_tabs", selected = input$plot)
  })
  
  observeEvent(input$file, {
    updateSelectInput(
      inputId = "chans", 
      choices = colnames(df()), 
      selected = colnames(select(df(), contains(input$raw_id))), 
    )
  })
  
  observeEvent(input$file, {
    win_max <- round(nrow(df()) / (input$srate / as.numeric(input$downsample)), 0)
    updateSliderInput(
      inputId = "window", 
      max = win_max,
      value = c(0, round(win_max / 4, 0))
    )
  })
  
  output$plot <- renderPlot({
    req(input$file)
    
    # make sure channel is updated first
    if (!is.null(input$chans)) {
      if (input$plot == "Raw") {
        plot_raw(
          df = df(), 
          srate = input$srate / as.numeric(input$downsample), 
          window = input$window, 
          chans = input$chans,
          overlay = input$overlay,
          scale_by_window = input$scale_by_window,
          range_labs = input$range_labs,
          hline = input$hlines,
          scale_fctr = input$scale_fctr,
          str_rm = input$str_rm,
          plot_title = input$plot_title,
          common_scale = input$common_scale,
          plot_events = input$plot_events,
          events = raw()$events
        )
        
      }
      if (input$plot == "PSD") {
        
        psd <- compute_psd(
          df = df(), 
          srate = input$srate / as.numeric(input$downsample), 
          window = input$window, 
          chans = input$chans,
          method = input$method,
          scale = input$scale
        )
        
        if (input$scale == "amp") {
          ylab <- "Amplitude (uV)"
          
        } else if (input$scale == "power") {
          ylab <- "Power (uV^2)"
          
        } else if (input$scale == "dB") {
          ylab <- "Decibels (10*log10(uV^2))"
          
        }
        
        plot_psd(
          spectrum = psd$spectrum, 
          hz = psd$hz,
          str_rm = input$str_rm,
          main = input$plot_title,
          ylab = ylab
        )
        
      }  
    }
    
  })
  
  # not sure how to avoid duplicating code for saving base R plots
  observeEvent(input$saveplot, {
    
    folder <- paste0(".", .Platform$file.sep, "plots", .Platform$file.sep)
    eeg_file <- tools::file_path_sans_ext(input$file$name)
    file <- paste0(Sys.Date(), "-", input$plot, "-", eeg_file, "-", input$plot_title, ".png")
    path <- paste0(folder, file)
    
    png(path)
    plot_raw(
      df = df(), 
      srate = input$srate / as.numeric(input$downsample), 
      window = input$window, 
      chans = input$chans,
      overlay = input$overlay,
      scale_by_window = input$scale_by_window,
      range_labs = input$range_labs,
      hline = input$hlines,
      scale_fctr = input$scale_fctr,
      str_rm = input$str_rm,
      plot_title = input$plot_title,
      common_scale = input$common_scale,
      plot_events = input$plot_events,
      events = raw()$events
    )
    dev.off()
    
    showNotification(paste(file, "saved to ./plots!"))
  })
  
})
