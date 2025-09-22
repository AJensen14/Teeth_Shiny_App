# Making the UI
ui <- navbarPage(
  title = div(class = "custom-navbar", "Equine Tooth Ageing"),
  id = "main_nav",
  windowTitle = "Shiny Navigation App",
  useShinyjs(),
  
  # Home Tab ####
  tabPanel("Home",
           fluidPage(
             div(class = "container",
                 h2("Welcome to our ShinyApp"),
                 h4("This app aims to aid in the exploration of our equine tooth proteomics data"),
                 h4(actionLink("go_to_data", "Click here to begin exploring our data")),
                 
                 h3("What is the Equine Tooth Proteome Project"),
                 p("he Equine Tooth Proteome Project is an open-access resource developed to catalogue 
                   protein expression across different tissues of the equine tooth. Our primary focus is on identifying 
                   age-related and disease-associated protein changes in dental tissues. This platform allows researchers to explore these findings 
                   and gain insights into the molecular landscape of equine oral health and ageing."),
                 
                 h3("Why it matters"),
                 
                 fluidRow(column(12,p("This proteomic resource provides valuable insight into the biology of the equine tooth and how it changes with age and disease."),
                                 h4("It supports:"),
                                 tags$ul(
                                   tags$li(strong("Understanding the biology of dental ageing in horses:"),
                                     " By profiling protein expression in tissues such as pulp, dentin, enamel, and cementum, we can begin to uncover how ageing influences the tooth’s molecular composition."),
                                   tags$li(strong("Better diagnosis and management of equine dental disease:"),
             " Proteomic signatures may help identify markers of tissue degeneration or inflammation, supporting more targeted interventions."),
             tags$li(strong("Reference data for equine dental research:"),
             " This project provides benchmark protein profiles that can be used in future studies of age- or disease-related changes."),
             tags$li(strong("A model for broader veterinary and comparative aging research:"),
             " Teeth are highly mineralised, metabolically active tissues and share conserved ageing pathways with other mammals, including humans. Our findings may have implications beyond equine health.")),
             h3("How to use this resource"),
             p(HTML("This app provides access to mass spectrometry-based proteomic data collected from healthy and diseased horses across different age groups 
                    and tooth tissues (pulp, dentin, enamel, cementum). We have compiled and visualised these results to allow easy exploration of tissue-specific and 
                    age-related protein expression changes. To get started, click the <strong>Data</strong> tab above and select the tissue you are interested in.  
                    If you would like a quick overview of omics techniques in veterinary science or help with terminology, 
                    <a href='https://www.researchgate.net/publication/383530889_Study_design_synopsis_'Omics'_terminologies-A_guide_for_the_equine_clinician' target='_blank'>click here</a>.")),
             h3("Who is behind the Equine Tooth Proteome Project?"),
             p("This project is led by researchers at the University of Liverpool and is supported by funding from the british equine veterinary association and collaborative input from equine dental specialists at North Wales equine dental practice."),
             actionLink("go_to_about", "For more information about the team, Click here.")))))),
  
  # About Us Tab ####
  tabPanel("About Us",
           fluidPage(
             div(class = "container",
                 h2("About Us"),
                 p("The Equine Tooth Proteome Project began in December 2021 and is led by researchers at the University of Liverpool.
                 Due to the complexity of studying proteomic changes across dental tissues, the project brings together a team with diverse expertise 
                 in sample collection, mass spectrometry, data analysis, and veterinary biology."),
                 
                 h3("Meet the Team:"),
                 
                 # Team Member 1
                 fluidRow(
                   column(4,
                          img(src = "images/AndersJensen.jpg", height = "200px", width = "200px", class = "img-thumbnail")),
                   column(8,
                          h4(HTML("<strong>Name:</strong> Anders Jensen")),
                          h4(HTML("<strong>Role:</strong> PhD Researcher")),
                          p(HTML("<strong>Description:</strong> Specialises in equine proteomics with a particular focus on age-related and disease-associated changes in dental tissues. 
                               Responsible for sample preparation, LC-MS analysis, data processing, interpretation, and app development."))
                   )
                 ),
                 br(),
                 
                 # Team Member 2
                 fluidRow(
                   column(4,
                          img(src = "images/UOL_logo.png", height = "200px", width = "200px", class = "img-thumbnail")),
                   column(8,
                          h4(HTML("<strong>Name:</strong> Mandy Peffers")),
                          h4(HTML("<strong>Role:</strong> Project Supervisor")),
                          p(HTML("<strong>Description:</strong> Professor of Musculoskeletal Biology and Head of Department.
                               Provides oversight across all stages of the project and supports the strategic direction of the research."))
                   )
                 ),
                 br(),
                 
                 # Team Member 3 (Example)
                 fluidRow(
                   column(4,
                          img(src = "images/JohnDoe.jpg", height = "200px", width = "200px", class = "img-thumbnail")),
                   column(8,
                          h4(HTML("<strong>Name:</strong> Andy Peffers")),
                          h4(HTML("<strong>Role:</strong> Equine Dental Specialist")),
                          p(HTML("<strong>Description:</strong> Provided assistiance is sample collection and extraction of diseased samples used
                                 in the study. Diseased samples were donated with informed consent from the North Wales Equine Dental Practice."))
                   )
                 )
             )
           )
  ),
  
  # Methods tab for protocols and SOPs ####
  tabPanel("Methods",
           fluidPage(
             div(class = "container",
                 h2("Methods"),
                 h3("Protocols"),
                 p("Select a tissue from the dropdown below to view the relevant sample preperation protocol."),
                 selectInput("protocol_select", "Choose a stage of the protocol:",
                             choices = (protocol_steps),
                             selected = (protocol_steps)[1]),
                 
                 # Output for text summary (may improve how this looks)
                 h4("Protocol Summary:"),
                 verbatimTextOutput("protocol_text"),
                 
                 # Supposed to be able to open my pdf files (doesnt work)
                # br(),
                 #actionButton("open_protocol", "Open Full Protocol PDF", icon = icon("file-pdf"))
                 )
           )),
  # Data Tab ####
  tabPanel("Data",
           fluidPage(
             div(class = "container",
                 h2("Data Page"),
                 h3("Tissue Selection"),
                 selectInput("data_select", "Choose a tissue:",
                             choices = sort(analysis),
                             selected = sort(analysis)[1]),
                 selectInput("condition_select", "Choose a comparison",
                             choices = c("Ageing", "Disease"),
                             selected = "Ageing"),
                 h4("Differential abundance analysis:"),
                 plotlyOutput("volcano_plot", height = "600px", width = "600px"),
                 textOutput("protein_count"),
                 downloadButton("download_plot", "Download Plot"),
                 br(),
                 br(),
                 p("When selecting the ageing condition the points on the right (Red) are higher in older samples and
         the points on the left (Blue) are higher in younger samples. When selecting
         disease, the points on right are higher in disease and the points on the left are higher in old."),
                 
                 fluidRow(
                   column(6,
                          checkboxGroupInput(
                            inputId = "selected_tissues",
                            label = "✅ Include proteins found in all of these tissues:",
                            choices = names(protein_data),
                            inline = TRUE
                          )
                   ),
                   column(6,
                          checkboxGroupInput(
                            inputId = "excluded_tissues",
                            label = "❌ Exclude proteins found in any of these tissues:",
                            choices = names(protein_data),
                            inline = TRUE
                          )
                   )
                 ),
                 h4("Proteins shared in selected tissues:"),
                 verbatimTextOutput("shared_proteins"),
                 
                 h4("Total number of proteins in selected set:"),
                 textOutput("total_protein_count")
             )
           )
  ),
  # Contact Us Tab ####
  tabPanel("Contact us",
           fluidPage(
             div(class = "container",
                 h2("Contact Us"),
                 p("You can reach us via email or phone.")
             )
           )
  ),
  
  # CSS and mobile-friendly viewport ####
  header = tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  )
)
