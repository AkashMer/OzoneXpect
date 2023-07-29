library(shiny)
library(shinydashboard)
library(shinyhelper)
library(dplyr)
library(impute)
library(plotly)
library(ggplot2)
library(gt)
library(datasets)

function(input, output, session) {
    
    # Observing the question mark helpers
    observe_helpers(withMathJax = TRUE)

    # Rendering a help file button
    output$infoHelp <- renderUI({
        h5("Click the blue question mark for any help") %>%
            helper(type = "markdown",
                   content = "info")
    }) # Closed render UI
    
    # Loading the data set
    # Imputing the missing values with rng seed 541258
    # Converted to a matrix since that's the way impute.knn works
    dat <- impute.knn(as.matrix(airquality), k = 10, rng.seed = 541258)$data
    
    # Converting it back to a data frame
    dat <- as.data.frame(dat) %>%
        # Rounding off the imputed values since ozone values should be integer
        mutate(Ozone = round(Ozone),
               # Same for Solar radiation
               Solar.R = round(Solar.R),
               # Converting month column to a factor
               Month = factor(Month, labels = c("May", "June", "July", "August",
                                                "September")))
    
    # Changing the column names to lower case for easier typing and matching
    names(dat) <- tolower(names(dat))
    
    # Extracting the predictor wanted by the user
    predictor <- reactive({
        input$predictor
    })
    
    # Extracting the month wanted by the user
    monthWanted <- reactive({
        input$month
    })
    
    # Getting the index of the values for the month
    monthIndex <- reactive({
        if(!(monthWanted() == "any")) {
            monthIndex <- which(dat$month == monthWanted())
            return(monthIndex)
        }else {
            return(1:nrow(dat))
        }
    })
    
    # Sub-setting the data to only include what the user wants
    datWanted <- reactive({
        if(monthWanted() == "any") {
            datWanted <- dat %>%
                select(ozone, any_of(predictor()))
            return(datWanted)
        }else {
            datWanted <- dat %>%
                filter(month == monthWanted()) %>%
                select(ozone, any_of(predictor()))
            return(datWanted)
        }
    })
    
    # Creating a custom red colored text to remind users to enter
    # values in the correct units
    output$reminder <- renderText("*Kindly enter in correct units")
    
    # Generating the input box depending on the predictor variable
    output$inputBox <- renderUI({
        
        # Input box in case temperature is chosen
        if(predictor() == "temp") {
            return(box(
                title = "How much is the temperature?",
                status = "info",
                textOutput("reminder"),
                tags$head(
                    tags$style("#reminder{color: red;
                                 font-style: italic;
                                 }"
                    ) # Closed tags style
                ), # Closed tags head
                numericInput(
                    "value",
                    markdown("Temperature in degrees F"),
                    value = 78,
                    min = 56,
                    max = 97,
                    step = 1
                ) %>% # Closed input
                    helper(type = "markdown",
                           content = "tempHelp"), # Added a help file
                "Press the button below", br(),
                # Added an action button to wait for user to want the prediction
                actionButton("event", "Predict")
                
            )) # closed temp box
        } # Closed if temp
        
        # Input box in case wind is chosen
        if(predictor() == "wind") {
            return(box(
                title = "How's the wind speed?",
                status = "info",
                textOutput("reminder"),
                tags$head(
                    tags$style("#reminder{color: red;
                                 font-style: italic;
                                 }"
                    ) # Closed tags style
                ), # Closed tags head
                numericInput(
                    "value",
                    "Wind Speed in miles/hour",
                    value = 10,
                    min = 1.7,
                    max = 20.7,
                    step = 0.1
                ) %>% # Closed input
                    helper(type = "markdown",
                           content = "tempHelp"), # Added a help file
                "Press the button below", br(),
                # Added an action button to wait for user to want the prediction
                actionButton("event", "Predict")
                
            )) # closed wind box
        } # Closed if wind
        
        # Input box in case solar radiation is chosen
        if(predictor() == "solar.r") {
            return(box(
                title = "How much solar radiation is recorded?",
                status = "info",
                textOutput("reminder"),
                tags$head(
                    tags$style("#reminder{color: red;
                                 font-style: italic;
                                 }"
                    ) # Closed tags style
                ), # Closed tags head
                numericInput(
                    "value",
                    markdown("Solar Radiation in Langleys(lang)  
                             in the frequency band 4000-7000 Angstroms"),
                    value = 186,
                    min = 7,
                    max = 334,
                    step = 1
                ) %>% # Closed input
                    helper(type = "markdown",
                           content = "tempHelp"), # Added a help file
                "Press the button below",
                # Added an action button to wait for user to want the prediction
                actionButton("event", "Predict")
                
            )) # closed solar box
        } # Closed if solar
    }) # Closed renderUI
    
    # Defining a logical value which will change depending on the below
    # mentioned observed events
    change <- reactiveValues(doPredict = FALSE)
    
    # Storing the value of predict button was pressed
    observeEvent(input$event, {
        change$doPredict <- input$event
    })
    
    # Observing if the input value was changed,
    # if so, reseting the predict button
    observeEvent(input$value, {
        change$doPredict <- FALSE
    })
    
    # Observing if the predictor was changed,
    # if so, resetting the predict button
    observeEvent(input$predictor, {
        change$doPredict <- FALSE
    })
    
    # Observing if the month was changed,
    # if so, restting the predict button
    observeEvent(input$month, {
        change$doPredict <- FALSE
    })
    
    # Defining the Simple Linear Model
    modelLinear <- reactive({
        lm(ozone ~ ., datWanted())
    })
    
    # Defining the leoss model
    # This model accounts takes into consideration the
    # non-linear relationship with the predictor
    modelLoess <- reactive({
        loess(ozone ~ ., data = datWanted(), span = 0.7)
    })
    
    # Displaying the plot
    output$plot <- renderPlotly({
        
        # Defining the plotting points for x axis
        newDat <- data.frame(seq(min(datWanted()[,2]),
                                        max(datWanted()[,2]),
                                        by = 0.05))
        names(newDat) <- predictor()
        
        # Creating a code of x-axis labels
        xAxisCode <- data.frame(code = c("temp", "wind", "solar.r"),
                                value = c("Temperature (°F)",
                                          "Wind Speed (miles/hr)",
                                          "Solar Radiation (lang)"))
        
        # Displaying the plot
        # If the predict button was pressed, them the prediction point
        # is also included in the plot
        if(change$doPredict) {
            
            # Predicting on the linear model
            linear <- predict(modelLinear(), newdata = newDat)
            
            # Predicting on the loess model
            smooth <- predict(modelLoess(), newdata = newDat)
            
            # Prediction value for the linear model
            valueDat <- data.frame(input$value)
            names(valueDat) <- predictor()
            predLinear <- predict(modelLinear(), newdata = valueDat)
            
            # Predicting value for the loess model
            predLoess <- predict(modelLoess(), newdata = valueDat)
            
            # Adding to the data fram to display
            valueDat <- cbind(valueDat, predLinear, predLoess)
            
            # Creating the plot
            plotModel <- ggplot() +
                # Plot the ozone against the predictor the user wanted
                geom_point(data = dat[monthIndex(),],
                           aes(.data[[predictor()]], ozone),
                           size = 0.7) +
                # Plot the linear model line
                geom_line(data = newDat, aes(.data[[predictor()]], linear,
                                             color = "Linear Model"),
                          linewidth = 1.5) +
                # Plot the loess model line
                geom_line(data = newDat, aes(.data[[predictor()]], smooth,
                                             color = "Loess Model"),
                          linewidth = 1.5) +
                # Adding the prediction points
                geom_point(data = valueDat, aes(.data[[predictor()]], predLinear,
                                         color = "Linear Model"), size = 3) +
                geom_point(data = valueDat, aes(.data[[predictor()]], predLoess,
                                         color = "Loess Model"), size = 3) +
                # Changing labels and adding title
                labs(title = "Ozone vs Predictor", y = "Ozone (ppb)",
                     x = xAxisCode$value[match(predictor(), xAxisCode$code)]) +
                # Adding the legend for different models
                scale_color_manual(name = "Model",
                                   values = c("#F8766D", "#00B0F6"),
                                   breaks = c("Linear Model", "Loess Model")) +
                # Changing to black and white thee
                theme_bw()
                
            # Returning a plotly object
            return(ggplotly(plotModel))
                
        } else {
            # Predicting on the linear model
            linear <- predict(modelLinear(), newdata = newDat)
            
            # Predicting on the loess model
            smooth <- predict(modelLoess(), newdata = newDat)
            
            # Creating the plot
            plotModel <- ggplot() +
                # Plot the ozone against the predictor the user wanted
                geom_point(data = dat[monthIndex(),],
                           aes(.data[[predictor()]], ozone),
                           size = 0.7) +
                # Plot the linear model line
                geom_line(data = newDat, aes(.data[[predictor()]], linear,
                                             color = "Linear Model"),
                          linewidth = 1.5) +
                # Plot the loess model line
                geom_line(data = newDat, aes(.data[[predictor()]], smooth,
                                             color = "Loess Model"),
                          linewidth = 1.5) +
                # Changing labels and adding title
                labs(title = "Ozone vs Predictor", y = "Ozone (ppb)",
                     x = xAxisCode$value[match(predictor(), xAxisCode$code)]) +
                # Adding the legend for different models
                scale_color_manual(name = "Model",
                                   values = c("#F8766D", "#00B0F6"),
                                   breaks = c("Linear Model", "Loess Model")) +
                # Changing to black and white thee
                theme_bw()
            
            # Returning a plotly object
            return(ggplotly(plotModel))
            
        } # Close if else
        
    }) # Closed renderPlotly
    
    # Prediction output
    output$table <- render_gt({
        
        # Outputing the prediction table only if the predict button was pressed
        # or if the entered value was changed
        # or if the predictor was changed
        # or if month was changed
        if(change$doPredict) {
            
            # Adding a warning if out of bounds value is added for the input
            if(!(between(input$value, min(dat$temp), max(dat$temp)) |
                 between(input$value, min(dat$wind), max(dat$wind)) |
                 between(input$value, min(dat$solar.r), max(dat$solar.r)))) {
                
                # Return a gt object informing the user of the mistake
                tab <- data.frame(warning = "The value entered above is out of bounds
                              or is in the wrong units")
                
                # Preparing the gt object
                tab <- gt(tab) %>%
                    cols_label(
                        warning = md("**Warning**")
                    ) %>%
                    tab_style(
                        style = cell_text(color = "red", style = "italic"),
                        locations = list(cells_column_labels(columns = everything()),
                                         cells_body(columns = everything()))
                    )
                
                # Returning the table
                return(tab)
            } # Closed warning if
            
            # Predictions
            # Getting the input data
            newDat <- data.frame(input$value)
            # Giving the correct name for matching in the model
            names(newDat) <- predictor()
            # Predicting on the linear model
            ozoneLinear <- predict(modelLinear(), newdata = newDat,
                                   interval = "prediction")
            # Predicting on the loess model
            predLoess <- predict(modelLoess(), newdata = newDat, se = TRUE)
            ozoneLoess  <- data.frame(predLoess$fit,
                                      predLoess$fit - predLoess$se.fit,
                                      predLoess$fit + predLoess$se.fit)
            
            # Combining the predictions into a single data framw
            result <- data.frame(ozone=c(ozoneLinear[1,1], ozoneLoess[1,1]),
                                 lower=c(ozoneLinear[1,2], ozoneLoess[1,2]),
                                 upper=c(ozoneLinear[1,3], ozoneLoess[1,3]))
            
            # Creating a gt table object for printing
            tab <- gt(result) %>%
                tab_header(
                    title = md("**Predicted mean Ozone level in parts per 
                               billion(ppb)**")) %>%
                tab_spanner(
                    label = md("**95% Prediction Interval**"),
                    columns = c("lower", "upper")
                ) %>%
                cols_label(
                    ozone = md("**Mean Ozone Level(ppb)**"),
                    lower = md("*lower limit*"),
                    upper = md("*upper limit*")
                ) %>%
                tab_row_group(
                    label = md("**Loess Model**"),
                    rows = 2
                ) %>%
                tab_row_group(
                    label = md("**Linear Model**"),
                    rows = 1
                ) %>%
                tab_style(
                    style = cell_fill(color = "orange", alpha = 0.5),
                    locations = cells_body(columns = everything(),
                                           rows = ozone < 0 |
                                               lower < 0 |
                                               upper < 0)
                ) %>%
                tab_footnote(
                    footnote = md("*These negative values are not helpful*"),
                    locations = cells_body(columns = everything(),
                                           rows = ozone < 0 |
                                               lower < 0 |
                                               upper < 0)
                ) %>%
                tab_source_note(
                    source_note = md("*Reference: airquality data set from R 
                                     datasets package*")
                )
            
            # Returning the table
            return(tab)
            
        } else {
            return()
        } # Closed if else for displaying prediction results
    }) # Closed both render_gt
} # Closed serve function
