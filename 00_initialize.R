options(repos = "http://cran.rstudio.com/")

install.packages("devtools")
install.packages("roxygen2")

install.packages("plyr")
install.packages("readr")
install.packages("readxl")
install.packages("stringr")

source("https://bioconductor.org/biocLite.R")
biocLite()
biocLite("biomaRt")
biocLite("RCurl")

devtools::install_github("seqcloud/seqcloudR")
#! devtools::use_data_raw()
