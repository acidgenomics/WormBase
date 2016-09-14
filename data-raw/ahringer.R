library(dplyr)
library(readr)
library(seqcloudr)
load("data-raw/ahringer.rda")
if (!exists("ahringer")) {
    ahringer <- list()
}

if (is.null(ahringer$wbrnai)) {
    ahringer[["wbrnai"]] <- historical2wbrnai(ahringer$raw$historical)
}


save(ahringer, file = "data-raw/ahringer.rda")
