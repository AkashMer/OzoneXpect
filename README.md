# **Kindly visit the following site to view the application - OzoneXpect, [OzoneXpect](http://akashmer.shinyapps.io/OzoneXpect)**

# **Kindly visit the following site to view the presentation pitch, no need to download the repository, this is a github pages site, [OzoneXpect Pitch](https://akashmer.github.io/OzoneXpect/#(1))**
  
# **OzoneXpect**
An app which **predicts mean ozone levels in parts per billion(ppb)** using  the *airquality* data set from the R **datasets** package
  
# **Repository contains**
  
* **OzoneXpect** : A sub-directory which stores all the files used to build the app
    + **helpfiles** - A sub-directory which contains all the help files difsplyed dynamically in the app
    + **rsconnect** - A sub-directory which contains information regarding the deployment of this app on the shiny.io website
    + **DESCRIPTION** - A Debian Control File (DCF) which is used to set the show method of the app and author and license
    + **LICENSE** - GPL v3 license for the code in this app
    + **Readme.md** - The DESCRIPTION file on how the app works as a markdown file. This markdown file is displayed with the app
    + **server.R** - R script which performs calculations and returns objects in the app
    + **ui.R** - R script which specifies all the user interface elements which will accept the input from the user and accept the output from the server
* **docs** : A sub-directory to store the **presentation pitch** as an HTML file - **index.html**. A markdown version of the file and a figures sub-directory containing all the files used in the report in can also be found here
* **scripts** : A sub-directory to store all the raw R scripts and R markdown files used to create the report
    + **pitch_cache/slidy** : A sub-directory to store all the cached data and code from *pitch.Rmd*
    + **appDescription.Rmd** : Raw R markdown file used to create the *Readme.md* DESCRIPTION file for the app
    + **modelBuilding.R** : A raw R script which was used to explore the data set and decide on which type of prediction models to use. This file does not have many comments and contains some old code used in the app in early stages. This file if only for the purposes of the author
    + **pitch.Rmd** : Raw R markdown file used to create the pitch presentation viewed as HTML in the **docs** directory
* **LICENSE** : GPL v3 license for the code in this repository
  
Written in **Markdown file in R version 4.3.1 (2023-06-16 ucrt) using RStudio IDE**  
Written by **Akash Mer**