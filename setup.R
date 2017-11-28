library(basejump)
library(devtools)
library(magrittr)
library(knitr)
library(parallel)
library(R.utils)
library(RCurl)
library(readxl)
library(rmarkdown)
library(tidyverse)

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
