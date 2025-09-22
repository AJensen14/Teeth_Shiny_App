

# Define the server
server <- function(input, output, session) {
  # clickable links to other tab ####
  # main_nav --> Data
  observeEvent(input$go_to_data, {
    updateNavbarPage(session, inputId = "main_nav", selected = "Data")
  })
  # Main_nav --> about us
  observeEvent(input$go_to_about, {
    updateTabsetPanel(session, inputId = "main_nav", selected = "About us")
  })
  
  # Trying to get the protocol text from my R code ####
  output$protocol_text <- renderText({
    req(input$protocol_select)
    
    # get rid of spaces in text
    tissue_name <- str_replace_all(input$protocol_select, " ", "")
    
    # extract protocol summary
    protocol_text <- protocol_texts[[tissue_name]]
    
    # a return message to see if i have messaged something up
    if (is.null(protocol_text)) {
      return("No protocol available for this tissue.")
    }
    return(protocol_text)
  })
  # ouput the pdf files, this bit is a bit crap and may change to download ####
  #observeEvent(input$open_protocol, {
  #  req(input$protocol_select)
    
    # Clean the input 
  #  tissue_name <- str_replace_all(input$protocol_select, " ", "")
    
    # Construct the URL to the PDF
  #  pdf_url <- paste0("pdf/", tissue_name, ".pdf")
    
    # Debug: print the URL
    # print(pdf_url)
    
    # Use shinyjs to open the PDF in a new tab
  #  shinyjs::runjs(sprintf("window.open('%s', '_blank')", pdf_url))
  #})
  
  # DE results ####
  get_de_data <- function(tissue, condition) {
    # Set the file path
    file_path <- paste0("www/de_results/", tissue, "/", condition, "/results.csv")
    if (file.exists(file_path)) {
      return(read.csv(file_path))
    } else {
      showNotification(paste("File not found:", file_path), type = "error")
      return(NULL)
    }
  }
  
  # Reactive expression to read the DE data based on user input ####
  de_data <- reactive({
    req(input$data_select, input$condition_select)
    get_de_data(input$data_select, input$condition_select)
  })
  
  # Generate volcano plot based on the DE data ####
  output$volcano_plot <- renderPlotly({
    df <- de_data() %>% 
      mutate(Regulation = case_when(FC > 1 & pval < 0.05 ~ "Up",
                                    FC < -1 & pval < 0.05 ~ "Down",
                                    FC > -1 & FC < 1 & pval < 0.05 ~ "Unchanged",
                                    pval > 0.05 ~ "ns")) %>% 
      mutate(Regulation = factor(Regulation, levels = c("Up", "Down", "Unchanged", "ns"))) %>% 
      mutate(label = case_when(Regulation == "Up" | Regulation == "Down"~X))
    
    ggplotly(ggplot(df, aes(x = FC, y = -log10(pval), text = paste("Protein:", X, "<br>log2FC:", FC, "<br>pval:", pval))) +
      geom_vline(xintercept = -1, linetype = "dashed") +
      geom_vline(xintercept = 1, linetype = "dashed") +
      geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
      geom_point(shape = 21, col = "black", alpha = 0.9, aes(fill = Regulation)) +
      scale_fill_manual(values = c("Up" = "red", "Down" = "blue", "Unchanged" = "gray", "ns" = "black")) +
      theme_minimal() +
      labs(
        title = paste0(input$data_select, " ", input$condition_select, " Volcano Plot"),
        x = "Fold change (log2)",
        y = "-log(pvalue)",
        fill = "Condition"
      ) +
      theme(axis.text = element_text(size = 12), axis.title = element_text(size = 14)), tooltip = "text")
    
    # Make it interacitve
    
  })
  
  # Display the number of proteins detected in the DE data ####
  output$protein_count <- renderText({
    df <- de_data()
    num_proteins <- nrow(df)
    paste("Number of proteins detected:", num_proteins)
  })
  
  # Enable plot download ####
  #output$download_plot <- downloadHandler(
  #  filename = function() {
  #    paste(input$data_select, "_", input$condition_select, "_volcano_plot.png", sep = "")
  #  },
  #  content = function(file) {
  #    df <- de_data()
  #    ggplot(df, aes(x = logFC, y = -log10(p_value))) +  # Assuming 'logFC' and 'p_value' are columns
  #      geom_point(aes(color = ifelse(p_value < 0.05, "Significant", "Not Significant")), size = 2) +
  #      scale_color_manual(values = c("Significant" = "red", "Not Significant" = "black")) +
  #      labs(title = paste(input$data_select, "-", input$condition_select, "Volcano Plot"),
  #           x = "Log2 Fold Change", y = "-Log10 P-value") +
  #      theme_minimal() +
  #      ggsave(file, width = 8, height = 6)
  #  }
  #)
  # sort out venn check ####
  output$shared_proteins <- renderPrint({
    selected <- unlist(input$selected_tissues)
    excluded <- unlist(input$excluded_tissues)
    
    # Step 1: Inclusion
    if (length(selected) == 0) {
      cat("No tissues selected in the inclusion list.")
      return()
    }
    
    included_proteins <- Reduce(intersect, protein_data[selected])
    
    # Step 2: Exclusion
    if (length(excluded) > 0) {
      excluded_proteins <- unique(unlist(protein_data[excluded]))
      filtered_proteins <- setdiff(included_proteins, excluded_proteins)
    } else {
      filtered_proteins <- included_proteins
    }
    
    # Output for proteins shared
    if (length(filtered_proteins) == 0) {
      cat("No proteins match the selected filters.")
    } else {
      cat(paste(filtered_proteins, collapse = " "))
    }
    
    # Output for total protein count
    output$total_protein_count <- renderText({
      length(filtered_proteins)
    })
  })
}
