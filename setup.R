# Load the required packages
packages <- c(
    "steinbaugh/basejump",
    "devtools",
    "knitr",
    "magrittr",
    "parallel",
    "R.utils",
    "RCurl",
    "readxl",
    "rmarkdown",
    "tidyverse"
)
if (!all(basename(packages) %in% rownames(installed.packages()))) {
    install <- setdiff(basename(packages), rownames(installed.packages()))
    source("https://bioconductor.org/biocLite.R")
    biocLite(pkgs = install)
}
invisible(lapply(
    X = basename(packages),
    FUN = library,
    character.only = TRUE
))

opts_chunk$set(
    audodep = TRUE,
    cache = TRUE,
    error = TRUE,
    fig.align = "center",
    fig.height = 8,
    fig.keep = "all",
    fig.path = "figures/",
    fig.retina = 2,
    fig.width = 8,
    message = TRUE,
    tidy = FALSE,
    warning = TRUE)

load_all()

dataDir <- "data-raw"
compress <- "xz"
