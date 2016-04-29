devtools:install_github("seqcloud/seqcloudR")
devtools::use_data_raw()
library(seqcloudR)

manage_pkg(c("plyr",
             "R.utils",
             "readr",
             "readxl",
             "roxygen2",
             "stringr"),
           source = "cran")

manage_pkg("RCurl",
           source = "bioc")
