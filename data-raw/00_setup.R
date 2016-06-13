## install.packages("devtools", repos = "http://cran.rstudio.com/")
## devtools::install_github("seqcloud/seqcloudR")
library(seqcloudR)
seqcloudR::setup_pkg(c("plyr",
                       "R.utils",
                       "readr",
                       "readxl",
                       "roxygen2",
                       "stringr"),
                     source = "cran")
seqcloudR::setup_pkg("RCurl",
                     source = "bioc")
devtools::use_data_raw()
