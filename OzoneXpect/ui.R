library(shiny)
library(shinydashboard)
library(shinyhelper)
library(plotly)
library(gt)

dashboardPage(skin = "purple",
    # Adding the title of the app
    dashboardHeader(title = "OzoneXpect"),

    # Disabling the sidebar menu
    dashboardSidebar(disable = TRUE),
    
    # Defining the body of the app
    dashboardBody(
        # Adding custom tags for the name of the app
        tags$head(
            tags$style(".main-header .logo{font-weight: bold;
                                 font-size: 30px;
                                 }"
            ) # Closed tags style
        ), # Closed tags head
        
        # First row
        fluidRow(
            
            # Box 1
            box(background = "light-blue",
                title = "What information do you have?",
                solidHeader = TRUE,
                
                # Adding a help file for this box
                uiOutput("infoHelp"),
                
                # Predictor Input
                selectInput(
                    "predictor",
                    label = "Kindly select one of the following:",
                    choices = c("Temperature" = "temp",
                                "Wind Speed" = "wind",
                                "Solar Radiation Level" = "solar.r")
                ) %>% # Closed predictor input
                    helper(type = "markdown",
                           content = "predictorHelp"), # Added a help file
                
                # Month Input
                selectInput(
                    "month",
                    label = "Choose the current month",
                    choices = c("Any month" = "any",
                                "May" = "May",
                                "June" = "June",
                                "July" = "July",
                                "August" = "August",
                                "September" = "September")
                ) %>% # Closed month input
                    helper(type = "markdown",
                           content = "monthHelp"), # Added a help file
                
            ), # Closed box1
            
            # Input box to input the value of the predictor chosen by the user
            uiOutput("inputBox")
            
        ), # Closed 1st row
        
        # Second row
        fluidRow(
            
            # Box for plot output
            box(
                plotlyOutput("plot") %>%
                    helper(type = "markdown",
                           content = "plotHelp") # Added a help file
            ), # Closed the plot box
            
            # Box for displaying predicted values of ozone
            box(
                title = "Predictions",
                status = "success",
                solidHeader = TRUE,
                gt_output("table") %>%
                    helper(type = "markdown",
                           content = "predictionHelp") # Added a help file
            )
            
        ), # Closed 2nd row
        
        # Third row
        fluidRow(
            box(
                width = 12,
                title = markdown("**APPENDIX:**"),
                background = "black",
                markdown("**Source:**"),
                markdown("The data were obtained from the New York State 
                         Department of Conservation (ozone data) and the 
                         National Weather Service (meteorological data)"),
                markdown("**Reference:**"),
                markdown("Chambers, J. M., Cleveland, W. S., Kleiner, B. 
                         and Tukey, P. A. (1983) *Graphical Methods for 
                         Data Analysis*. Belmont, CA: Wadsworth."),
                
            ) # Closed box
        ) # Closed 3rd row
        
    ) # Closed dashboardbody
    
) # Closed dashboardpage()
