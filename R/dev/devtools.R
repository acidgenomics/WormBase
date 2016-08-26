library("devtools")
use_package("devtools")

library("biomaRt")
use_package("biomaRt")

library("dplyr")
use_package("dplyr")

library("httr")
use_package("httr")

library("magrittr")
use_package("magrittr")

library("parallel")
use_package("parallel")

library("readr")
use_package("readr")

library("readxl")
use_package("readxl")

library("rmarkdown")
use_package("rmarkdown", "suggests")
# requireNamespace("rmarkdown", quietly = TRUE)

library("seqcloudr")
use_package("seqcloudr")

library("stringr")
use_package("stringr")

library("tibble")
use_package("tibble")

library("tidyr")
use_package("tidyr")

devtools::document()
devtools::use_data_raw()
