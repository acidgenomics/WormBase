devtools::use_data_raw()

devtools:install_github("seqcloud/seqcloudr")
library(seqcloudr)

manage_pkg(c("plyr",
             "R.utils",
             "readr",
             "readxl",
             "roxygen2",
             "stringr"),
           source = "cran")

manage_pkg("RCurl",
           source = "bioc")
