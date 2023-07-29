# **DESCRIPTION**

**Kindly press the blue question marks in case you need help and
explanation**

*OzoneXpect* can be used to **estimate mean ozone levels depending on
temperature/wind speed/solar radiation** using the `airquality` data set
from R `datasets` package

### **Top left box**

This is used to select one of the dependent values out of the three
mentioned above, default is *Temperature*  
This also allows you to enter the current month, default is *Any Month*

### **Top right box**

Input the value known by you and then press the `Predict` button.  
Each variable out of the three has a range mentioned in the help section
when the blue question mark is clicked.

### **Bottom left box**

Displays a plot showing the relationship between mean ozone levels and
the selected dependent variable.  
This plot interactively changes with the values entered above.  
Displays a **scatter plot** between the **mean Ozone level and the
measurement chosen above** and adds a line passing through those points
representing,

1.  **Linear Model** - A line representing a linear relationship between
    the variables plotted
2.  **Loess Model** - A line representing a non-linear relationship
    between the variables plotted

Certain Notable Features:

-   Hovering the mouse over values will display the data values
-   You can use the zoom button to zoom in or make a box with your mouse
    to zoom in to a particular interested area
-   Clicking on the models will allow you to choose which model is
    displayed in the plot
-   Once the `Predict` button is pressed in the top-right box, the
    prediction point is also added to the plot

### **Bottom right box**

Displays the mean ozone level predictions.  
The table interactively changes with the values entered above after
pressing the `Predict` button.  
Displays predictions assuming either,

-   a linear relationship between the variables - **Linear Model**, or
-   a non-linear relationship - **Loess Model**

The table also displays the **lower and upper bounds** for our
prediction of mean ozone level thus attaching a **probability that the
prediction would be between these bounds 95% of the times**

**Orange** highlights indicate the predicted value should not be
trusted.

#### **Statistical knowledge required to understand this section**

Functions calls used to build the model:

-   **Linear Model** - `lm(ozone ~ predictor, data)`
-   **Loess Model** - `loess(ozone ~ predictor, data)`

The data is subsetted if a particular month is chosen in the top-left
box to stratify and give a more accurate prediction.

Function calls to predict the ozone value made sure that they returned
**prediction intervals** and not confidence intervals.

### **Appendix box**

Lists references for the datasets used in this app.

### **Code details:**

App written as a **Shiny App in R version 4.3.1 (2023-06-16 ucrt) using
RStudio IDE**  
**Packages** used,

-   **shiny** : *Version 1.7.4.1*
-   **shinydashboard** : *Version 0.7.2*
-   **shinyhelper** : *Version 0.3.2*
-   **dplyr** : *Version 1.1.2*
-   **impute** : *Version 1.74.1*
-   **plotly** : *Version 4.10.2*
-   **ggplot2** : *Version 3.4.2*
-   **gt** : *Version 0.9.0*
-   **datasets** : *Version 4.3.1*
