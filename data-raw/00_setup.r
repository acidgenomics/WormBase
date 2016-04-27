devtools::use_data_raw()

manage_bioc <- function(bioc_pkg) {
  install_bioc_pkg <-
    bioc_pkg[!(bioc_pkg %in% installed.packages()[, "Package"])]
  if (length(install_bioc_pkg) > 0) {
    source("https://bioconductor.org/biocLite.R")
    biocLite()
    biocLite(install_bioc_pkg)
  }
  invisible(lapply(bioc_pkg, require, character.only = TRUE))
}
manage_cran <- function(cran_pkg) {
  install_cran_pkg <-
    cran_pkg[!(cran_pkg %in% installed.packages()[, "Package"])]
  if (length(install_cran_pkg) > 0) {
    install.packages(install_cran_pkg)
  }
  invisible(lapply(cran_pkg, require, character.only = TRUE))
}

bioc_pkg <- c(
  "RCurl"
)
cran_pkg <- c(
  "plyr",
  "R.utils",
  "readr",
  "readxl",
  "roxygen2",
  "stringr"
)
manage_bioc(bioc_pkg)
manage_cran(cran_pkg)
