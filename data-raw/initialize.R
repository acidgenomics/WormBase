options(repos = "http://cran.rstudio.com/")

install.packages("devtools")
install.packages("dplyr")
install.packages("magrittr")
install.packages("readr")
install.packages("readxl")
install.packages("roxygen2")
install.packages("stringr")
install.packages("tibble")

source("https://bioconductor.org/biocLite.R")
biocLite()
biocLite("biomaRt")
biocLite("RCurl")

devtools::install_github("seqcloud/seqcloudr")
devtools::use_data_raw()
