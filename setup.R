library(basejump)
library(devtools)
library(httr)
library(knitr)
library(parallel)
library(pbmcapply)
library(R.utils)
library(RCurl)
library(readxl)
library(stringr)
library(rlang)
library(tidyverse)

opts_chunk$set(
    audodep = TRUE,
    cache = TRUE,
    error = TRUE,
    fig.align = "center",
    fig.height = 7,
    fig.keep = "all",
    fig.path = "figures/",
    fig.width = 7,
    message = TRUE,
    tidy = FALSE,
    warning = TRUE)

load_all()
