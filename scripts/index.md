---
title: "OzoneXpect App"
author: "Akash Mer"
date: "2023-07-29"
framework   : io2012
highlighter : highlight.js
hitheme     : tomorrow
widgets     : []
mode        : selfcontained
knit: (function(input, ...){
    rmarkdown::render(input,
        output_dir = "C:/Users/akash/Documents/datasciencecoursera/OzoneXpect/docs",
        output_file = file.path("./index"))
    })
---



## **Introduction**

**OzoneXpect** aims to **predict mean Ozone levels in parts per billion(ppb)** based on the measurement taken or the information known by the user.  
The user is allowed to input the following information :
  
1. **Measurement taken/information known to the user** - Represented as a predictor in the app, user can choose from the following,
    + **Temperature***(default)*
    + **Wind speed**
    + **Solar Radiation**
2. **Current Month** - Month the above measurement was taken in. Also gives the option to not specify the month. User can choose from **May to September** or **Any Month***(default)*
3. **Measurement Value** - User can then enter the measurement value to be used for the prediction.
  
**Data Used** - The data for the app comes from the `airquality` data set in R `datasets` package which is as follows,

```r
str(airquality)
```

```
'data.frame':	153 obs. of  6 variables:
 $ Ozone  : int  41 36 12 18 NA 28 23 19 8 NA ...
 $ Solar.R: int  190 118 149 313 NA NA 299 99 19 194 ...
 $ Wind   : num  7.4 8 12.6 11.5 14.3 14.9 8.6 13.8 20.1 8.6 ...
 $ Temp   : int  67 72 74 62 56 66 65 59 61 69 ...
 $ Month  : int  5 5 5 5 5 5 5 5 5 5 ...
 $ Day    : int  1 2 3 4 5 6 7 8 9 10 ...
```
**27.45% of rows** contain missing values. `impute.knn()` function from the `impute` package was used to impute these mmissing values

- - - .class #id 

## **How does it predict?**

**OzoneXpect** predicts using 2 different models,
  
1. **Linear Model** - A linear model is built using the desired predictor as the outcome and using the data from the `airquality` data set. The data is subsetted in case a particular month was selected to ensure stratification and avoid any confounding due to the *month* variable. This model is built using the `lm()` function in R.
2. **Loess Model** - A non-linear model is built under the same circumstances as above. This model is built using the `loess()` function in R with a **span of 0.7**
  
Then, the mean ozone level is predicted using both models and returned with a 95% prediction interval for both models  

- - - .class #id 

## **Outputs**
  
### **1. Relationship Plot**

Salient Features : 
  
* An interactive scatter plot between ozone and the desired predictor is displayed as soon as any **predictor and month is selected and changes based on the changes in those 2 inputs**.
* **Lines representing both the models** are also included with the option to click and select which one appears left to the user
* Once the measurement input is done, the plot is updated with the prediction points plotted as well


```r
if(system.file(package = "dplyr") == "") install.packages("dplyr")
if(system.file(package = "impute") == "") install.packages("impute")
if(system.file(package = "ggplot2") == "") install.packages("ggplot2")
if(system.file(package = "plotly") == "") install.packages("plotly")
library(dplyr)
library(impute)
library(ggplot2)
library(plotly)

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

# Defining the Simple Linear Model for each predictor
modelLinear <- lm(ozone ~ temp, dat)
modelLoess <- loess(ozone ~ temp, dat, span = 0.7)

# Defining the plotting points for x axis
newDat <- data.frame(temp = seq(min(dat$temp), max(dat$temp), by = 0.05))

# Predicting on the linear model
linear <- predict(modelLinear, newdata = newDat)
            
# Predicting on the loess model
smooth <- predict(modelLoess, newdata = newDat)
    
# Prediction value for the linear model
valueDat <- data.frame(temp = 78)
predLinear <- predict(modelLinear, newdata = valueDat)
            
# Predicting value for the loess model
predLoess <- predict(modelLoess, newdata = valueDat)
            
# Adding to the data fram to display
valueDat <- cbind(valueDat, predLinear, predLoess)
            
# Creating the plot
plotModel <- ggplot() +
    # Plot the ozone against the predictor the user wanted
    geom_point(data = dat,
           aes(temp, ozone),
               size = 0.7) +
    # Plot the linear model line
    geom_line(data = newDat, aes(temp, linear,
                             color = "Linear Model"),
              linewidth = 1.5) +
    # Plot the loess model line
    geom_line(data = newDat, aes(temp, smooth,
                                 color = "Loess Model"),
              linewidth = 1.5) +
    # Adding the prediction points
    geom_point(data = valueDat, aes(temp, predLinear,
                             color = "Linear Model"), size = 3) +
    geom_point(data = valueDat, aes(temp, predLoess,
                             color = "Loess Model"), size = 3) +
    # Changing labels and adding title
    labs(title = "Example Plot", y = "Ozone (ppb)",
         x = "Temperature (°F)") +
    # Adding the legend for different models
    scale_color_manual(name = "Model",
                       values = c("#F8766D", "#00B0F6"),
                       breaks = c("Linear Model", "Loess Model")) +
    # Changing to black and white thee
    theme_bw()
            
# Returning a plotly object
ggplotly(plotModel)
```

```
## Error in loadNamespace(name): there is no package called 'webshot'
```
  
### **2. Predictions**

Salient Features :
  
* A table is displayed to the user **only if the input values are within the corresponding bounds of minimum and maximum values** in the `airquality` data set to ensure higher accuracy.
* Any **negative values taken by the prediction or the 95% prediction interval bounds are highlighted with orange** to inform the user that these values are incorrect.
  

```r
if(system.file(package = "gt") == "") install.packages("gt")
library(gt)

# Predicting om the linear model
ozoneLinear <- predict(modelLinear, newdata = valueDat,
                                   interval = "prediction")

# Predicting on the loess model
predLoess <- predict(modelLoess, newdata = valueDat, se = TRUE)
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
        title = md("**Example Prediction**")) %>%
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
tab
```

<!--html_preserve--><div id="scopkbfmsd" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#scopkbfmsd table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#scopkbfmsd thead, #scopkbfmsd tbody, #scopkbfmsd tfoot, #scopkbfmsd tr, #scopkbfmsd td, #scopkbfmsd th {
  border-style: none;
}

#scopkbfmsd p {
  margin: 0;
  padding: 0;
}

#scopkbfmsd .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#scopkbfmsd .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#scopkbfmsd .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#scopkbfmsd .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#scopkbfmsd .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#scopkbfmsd .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#scopkbfmsd .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#scopkbfmsd .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#scopkbfmsd .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#scopkbfmsd .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#scopkbfmsd .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#scopkbfmsd .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#scopkbfmsd .gt_spanner_row {
  border-bottom-style: hidden;
}

#scopkbfmsd .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#scopkbfmsd .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#scopkbfmsd .gt_from_md > :first-child {
  margin-top: 0;
}

#scopkbfmsd .gt_from_md > :last-child {
  margin-bottom: 0;
}

#scopkbfmsd .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#scopkbfmsd .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#scopkbfmsd .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#scopkbfmsd .gt_row_group_first td {
  border-top-width: 2px;
}

#scopkbfmsd .gt_row_group_first th {
  border-top-width: 2px;
}

#scopkbfmsd .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#scopkbfmsd .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#scopkbfmsd .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#scopkbfmsd .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#scopkbfmsd .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#scopkbfmsd .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#scopkbfmsd .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#scopkbfmsd .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#scopkbfmsd .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#scopkbfmsd .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#scopkbfmsd .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#scopkbfmsd .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#scopkbfmsd .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#scopkbfmsd .gt_left {
  text-align: left;
}

#scopkbfmsd .gt_center {
  text-align: center;
}

#scopkbfmsd .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#scopkbfmsd .gt_font_normal {
  font-weight: normal;
}

#scopkbfmsd .gt_font_bold {
  font-weight: bold;
}

#scopkbfmsd .gt_font_italic {
  font-style: italic;
}

#scopkbfmsd .gt_super {
  font-size: 65%;
}

#scopkbfmsd .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#scopkbfmsd .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#scopkbfmsd .gt_indent_1 {
  text-indent: 5px;
}

#scopkbfmsd .gt_indent_2 {
  text-indent: 10px;
}

#scopkbfmsd .gt_indent_3 {
  text-indent: 15px;
}

#scopkbfmsd .gt_indent_4 {
  text-indent: 20px;
}

#scopkbfmsd .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_title gt_font_normal gt_bottom_border" style><strong>Example Prediction</strong></td>
    </tr>
    
    <tr class="gt_col_headings gt_spanner_row">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="2" colspan="1" scope="col" id="&lt;strong&gt;Mean Ozone Level(ppb)&lt;/strong&gt;"><strong>Mean Ozone Level(ppb)</strong></th>
      <th class="gt_center gt_columns_top_border gt_column_spanner_outer" rowspan="1" colspan="2" scope="colgroup" id="&lt;strong&gt;95% Prediction Interval&lt;/strong&gt;">
        <span class="gt_column_spanner"><strong>95% Prediction Interval</strong></span>
      </th>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="&lt;em&gt;lower limit&lt;/em&gt;"><em>lower limit</em></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="&lt;em&gt;upper limit&lt;/em&gt;"><em>upper limit</em></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="3" class="gt_group_heading" scope="colgroup" id="&lt;strong&gt;Linear Model&lt;/strong&gt;"><strong>Linear Model</strong></th>
    </tr>
    <tr class="gt_row_group_first"><td headers="**Linear Model**  ozone" class="gt_row gt_right" style="background-color: rgba(255,165,0,0.5);"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> 41.06939</td>
<td headers="**Linear Model**  lower" class="gt_row gt_right" style="background-color: rgba(255,165,0,0.5);"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> -2.581093</td>
<td headers="**Linear Model**  upper" class="gt_row gt_right" style="background-color: rgba(255,165,0,0.5);"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> 84.71988</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="3" class="gt_group_heading" scope="colgroup" id="&lt;strong&gt;Loess Model&lt;/strong&gt;"><strong>Loess Model</strong></th>
    </tr>
    <tr class="gt_row_group_first"><td headers="**Loess Model**  ozone" class="gt_row gt_right">32.99557</td>
<td headers="**Loess Model**  lower" class="gt_row gt_right">30.053930</td>
<td headers="**Loess Model**  upper" class="gt_row gt_right">35.93720</td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="3"><em>Reference: airquality data set from R
datasets package</em></td>
    </tr>
  </tfoot>
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="3"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> <em>These negative values are not helpful</em></td>
    </tr>
  </tfoot>
</table>
</div><!--/html_preserve-->

- - - .class #id 

## **Strengths**
  
1. The user is **afforded a lot of input options** like deciding the predictor, informing the app about the current month, and thus is able to **get mean ozone levels depending on a variety of conditions**.
2. An **interactive** plot is displayed which **updates depending on the user's input**
3. **Both linear and non-linear predictions are returned**, thus allowing the user to choose whatever predictions they want
4. User is **informed about incorrect predictions as well**
5. Predictions are coupled with **95% prediction intervals** thus providing the probability statistic behind the uncertainty in the predictions
  
### *Limitations and Plans to tackle the limitations*
  
1. Small data set - In search for larger data sets representing similar variables
2. Only 6/12 months included - In search for data sets containing measurements for around the year
3. Data was not divided into train/test sets due to the already small sample size - Prediction intervals and the associated probability of error is provided though
