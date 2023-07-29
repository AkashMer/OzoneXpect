# loading in the data
data("airquality")

# Needs to be imputed
library(impute)
dat <- impute.knn(as.matrix(airquality), k = 10, rng.seed = 54268)$data

# Converting it back to a data frame
dat <- as.data.frame(dat)

# Now exploring
str(dat)

# Changing the names to lowercase for easier typing
names(dat) <- tolower(names(dat))

# Store this in a new object for correlation plot
datNum <- dat

# The Imputed values will need to be converted to whole numbers since 
# The month variable will be converted to a factor
library(dplyr)
dat <- dat %>%
    mutate(ozone = round(ozone),
           month = factor(month, labels = c("May", "June", "July", "August",
                                            "September")))

# Looking at the correlation plot
library(ggplot2)
library(GGally)
ggpairs(datNum, lower = list(continuous = "smooth"))
ggcorr(datNum)

# Looking closer at the relationship with temp and solar.r and wind
ggplot(dat, aes(temp, ozone)) + geom_point() +
    geom_smooth()
ggplot(dat, aes(temp, ozone)) + geom_point() +
    geom_smooth(method = "lm")

ggplot(dat, aes(solar.r, ozone)) + geom_point() +
    geom_smooth()
ggplot(dat, aes(solar.r, ozone)) + geom_point() +
    geom_smooth(method = "lm")

ggplot(dat, aes(wind, ozone)) + geom_point() +
    geom_smooth()
ggplot(dat, aes(wind, ozone)) + geom_point() +
    geom_smooth(method = "lm")

# Let's look at it from 3d point
library(plotly)
plot_ly(data = dat, x = ~temp, y = ~ozone, z = ~solar.r, color = ~month,
        size = ~wind, sizes = c(100,400))

# Temp and Solar.R seem important, wind, maybbeee

# Model building with simple linear model
fit1 <- lm(ozone ~ temp, dat)
fit2 <- lm(ozone ~ temp + solar.r, dat)
fit2wind <- lm(ozone ~ temp + wind, dat)
fit3 <- lm(ozone ~ temp + solar.r + wind, dat)
fit4 <- lm(ozone ~ temp + solar.r + wind + month, dat)

anova(fit1, fit2, fit3, fit4)
summary(fit1)
summary(fit2)
summary(fit2wind)
summary(fit3)
summary(fit4)
plot(fit1, which = 1)
plot(fit2, which = 1)
plot(fit2wind, which = 1)
plot(fit3, which = 1)
plot(fit4, which = 1)
library(olsrr)
ols_vif_tol(fit2)
ols_vif_tol(fit2wind)
ols_vif_tol(fit3)
ols_vif_tol(fit4)

# fit3 seems like what we would be going for

# Now fitting a loess model with the same number of predictors
library(caret)

# Fitting a loess model with cross validation for best span value
loessFit <- train(ozone ~ temp, data = dat,
                  method = "gamLoess",
                  trControl = trainControl(method = "cv"))

loessFit

# Fitting with span 0.5
fitLoess <- loess(ozone ~ temp, data = dat, span = 0.7)
summary(fitLoess)

# Make our plotting data
newdata <- data.frame(temp = seq(min(dat$temp), max(dat$temp), by = 0.05))
# Predicting and plotting
linear <- predict(fit1, newdata = newdata)
smooth <- predict(fitLoess, newdata = newdata)

# Let's plot both of them
ggplot(newdata) + geom_line(aes(temp, smooth), color = "blue") +
    geom_line(aes(temp, linear), color = "red")

# Let's plot ith the base system
with(dat, plot(temp, ozone))
lines(newdata$temp, linear, col = "red")
lines(newdata$temp, smooth, col = "blue")

# Let's try to recreate that with ggplot
ggplot() +
    geom_point(data = dat, aes(temp, ozone, color = month)) +
    geom_line(data = newdata, aes(temp, linear), color = "red") +
    geom_line(data = newdata, aes(temp, smooth), color = "blue")

# Let's bring in the month into picture
mayIndex <- which(dat$month == "May")
fitMay <- lm(ozone ~ temp, dat[mayIndex,])
loessMay <- loess(ozone ~ temp, dat[mayIndex,], span = 0.7)
# Make our plotting data
newdata <- data.frame(temp = seq(min(dat[mayIndex,]$temp),
                                 max(dat[mayIndex,]$temp), by = 0.05))
# Predicting and plotting
linearMay <- predict(fitMay, newdata = newdata)
smoothMay <- predict(loessMay, newdata = newdata)
ggplotly(ggplot() +
    geom_point(data = dat[mayIndex,], aes(temp, ozone, color = month)) +
    geom_line(data = newdata, aes(temp, linearMay), color = "red") +
    geom_line(data = newdata, aes(temp, smoothMay), color = "blue"))

predictor = "temp"
temp <- select(dat, c(ozone, any_of(predictor)))


dat <- data("airquality") %>%
    as.matrix() %>%
    impute.knn(k = 10, rng.seed = 541258)$data %>%
    as.data.frame() %>%
    mutate(Ozone = round(Ozone),
           Solar.R = round(Solar.R),
           Month = factor(Month, labels = c("May", "June", "July", "August",
                                            "September")))


# Imputing the missing values with rng seed 541258
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

predictor <- "temp"
monthWanted <- "September"

if(monthWanted == "any") {
    datWanted <- dat %>%
            select(ozone, any_of(predictor))
}else {
    datWanted <- dat %>%
        filter(month == monthWanted) %>%
        select(ozone, any_of(predictor))    
}


str(datWanted)
modelLinear <- lm(ozone ~ ., datWanted)
modelLoess <- loess(ozone ~ ., datWanted)
oLinear <- predict(modelLinear, data.frame(temp = 85), interval = "prediction")
predLoess <- predict(modelLoess, data.frame(temp = 85), se = TRUE)
oLoess  <- data.frame(predLoess$fit,predLoess$fit - predLoess$se.fit,
                      predLoess$fit + predLoess$se.fit)

result <- data.frame(ozone=c(oLinear[1,1], oLoess[1,1]),
                     lower=c(oLinear[1,2], oLoess[1,2]),
                     upper=c(oLinear[1,3], oLoess[1,3]))

row.names(result)
gt(result) %>%
    tab_header(
        title = md("**Predicted mean Ozone level in parts per billion(ppb)**")) %>%
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
    )

monthWanted <- "May"
predictor = "temp"
datWanted <- dat
if(monthWanted == "any") {
    datWanted <- dat %>%
        select(ozone, any_of(predictor))
}else {
    datWanted <- dat %>%
        filter(month == monthWanted) %>%
        select(ozone, any_of(predictor))   
}

# Long code removed from server file
# Predictions
if(predictor() == "temp") {
    # Getting the input data
    newDat <- data.frame(temp = input$value)
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
        )

    # Returning the table
    return(tab)
}

if(predictor() == "wind") {
    # Getting the input data
    newDat <- data.frame(wind = input$value)
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
        )

    # Returning the table
    return(tab)
}

if(predictor() == "solar.r") {
    # Getting the input data
    newDat <- data.frame(solar.r = input$value)
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
        )

    # Returning the table
    return(tab)
}


# Removed another big if else code
if(predictor() == "temp") {
    # Defining the plotting points for x axis
    newDat <- data.frame(temp = seq(min(datWanted()[,2]),
                                         max(datWanted()[,2]),
                                         by = 0.05))

    # Predicting on the linear model
    linear <- predict(modelLinear(), newdata = newDat)

    # Predicting on the loess model
    smooth <- predict(modelLoess(), newdata = newDat)

    # Creating the plot
    plotModel <- ggplot() +
        # Plot the ozone against the predictor the user wanted
        geom_point(data = dat[monthIndex(),], aes(temp, ozone)) +
        # Customizing the color scale
        scale_color_brewer(palette = "Dark2") +
        # Plot the linear model line
        geom_line(data = newDat, aes(temp, linear),
                  color = "#F8766D", linewidth = 1.5) +
        # Plot the loess model line
        geom_line(data = newDat, aes(temp, smooth),
                  color = "#00BFC4", linewidth = 1.5)

    # Returning a plotly object
    return(ggplotly(plotModel))

}
if(predictor() == "wind") {
    # Defining the plotting points for x axis
    newDat <- data.frame(wind = seq(min(datWanted()[,2]),
                                    max(datWanted()[,2]),
                                    by = 0.05))

    # Predicting on the linear model
    linear <- predict(modelLinear(), newdata = newDat)

    # Predicting on the loess model
    smooth <- predict(modelLoess(), newdata = newDat)

    # Creating the plot
    plotModel <- ggplot() +
        # Plot the ozone against the predictor the user wanted
        geom_point(data = dat[monthIndex(),], aes(wind, ozone)) +
        # Customizing the color scale
        scale_color_brewer(palette = "Dark2") +
        # Plot the linear model line
        geom_line(data = newDat, aes(wind, linear),
                  color = "#F8766D", linewidth = 1.5) +
        # Plot the loess model line
        geom_line(data = newDat, aes(wind, smooth),
                  color = "#00BFC4", linewidth = 1.5)

    # Returning a plotly object
    return(ggplotly(plotModel))
}
if(predictor() == "solar.r") {
    # Defining the plotting points for x axis
    newDat <- data.frame(solar.r = seq(min(datWanted()[,2]),
                                    max(datWanted()[,2]),
                                    by = 0.05))

    # Predicting on the linear model
    linear <- predict(modelLinear(), newdata = newDat)

    # Predicting on the loess model
    smooth <- predict(modelLoess(), newdata = newDat)

    # Creating the plot
    plotModel <- ggplot() +
        # Plot the ozone against the predictor the user wanted
        geom_point(data = dat[monthIndex(),], aes(solar.r, ozone)) +
        # Customizing the color scale
        scale_color_brewer(palette = "Dark2") +
        # Plot the linear model line
        geom_line(data = newDat, aes(solar.r, linear),
                  color = "#F8766D", linewidth = 1.5) +
        # Plot the loess model line
        geom_line(data = newDat, aes(solar.r, smooth),
                  color = "#00BFC4", linewidth = 1.5)

    # Returning a plotly object
    return(ggplotly(plotModel))
}


create_help_files(files = c("info", "predictorHelp", "monthHelp",
                            "tempHelp", "windHelp", "solarrhelp",
                            "plotHelp","predictionHelp"), 
                  help_dir = "helpfiles")