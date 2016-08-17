library(dplyr)
# Source all files in R folder
sapply(list.files(pattern = "[.]R$", path = "R", full.names = TRUE), source)
devtools::use_data_raw()
