# repos = "http://cran.rstudio.com/"
install.packages("devtools")
install.packages("plyr")
install.packages("R.utils")
install.packages("readr")
install.packages("readxl")
install.packages("roxygen2")
install.packages("stringr")

source("https://bioconductor.org/biocLite.R")
biocLite()
biocLite("RCurl")

library(devtools)
devtools::use_data_raw()
