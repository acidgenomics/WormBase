source("https://raw.githubusercontent.com/seqcloud/seqcloudR/master/R/manage_pkg.R")
devtools::use_data_raw()

manage_pkg(c("plyr",
             "R.utils",
             "readr",
             "readxl",
             "roxygen2",
             "stringr"),
           source = "cran")

manage_pkg("RCurl",
           source = "bioc")
