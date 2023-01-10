# not currently using, but keeping in case I want it
# if (input$print_cols) {
#   
#   cn <- colnames(data()$df)
#   index <- 1:length(cn)
#   
#   columns_text <- paste(
#     "Columns:", ifelse(
#       index %% 3 == 0, 
#       paste0(cn, ", \n          "), 
#       ifelse(
#         index != length(index), 
#         paste0(cn, ","),
#         cn
#       )
#     )
#   )
# } else {
#   columns_text <- NULL
# }