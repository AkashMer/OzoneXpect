## **Mean Ozone Level Predictions**
***
This table interactively changes with the values entered above after pressing the `Predict` button.  
Displays predictions assuming either,
  
* a linear relationship between the variables - **Linear Model**, or
* a non-linear relationship - **Loess Model**
  
The table also displays the **lower and upper bounds** for our prediction of mean ozone level thus attaching a **probability that the prediction would be between these bounds 95% of the times**  
  
**Orange** highlights indicate the predicted value should not be trusted.  
***
### **<span style="color:red;">Statistical knowledge required to understand this section</span>**
***
Functions calls used to build the model:
  
* **Linear Model** - `lm(ozone ~ predictor, data)`
* **Loess Model** - `loess(ozone ~ predictor, data)`
  
The data is subsetted if a particular month is chosen in the top-left box to stratify and give a more accurate prediction.  
  
Function calls to predict the ozone value made sure that they returned **prediction intervals** and not confidence intervals.
***
*Kindly refer to the Appendix section regarding where the data was obtained from and license information of this app*
***