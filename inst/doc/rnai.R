## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(results = "asis", render = pander::pander)
pander::panderOptions("table.style", "rmarkdown")
pander::panderOptions("table.alignment.default", "left")
pander::panderOptions("table.alignment.rownames", "right")
devtools::load_all()

## ------------------------------------------------------------------------
t(
    rnai("sbp-1", format = "name")
)

## ---- eval = FALSE-------------------------------------------------------
#  rnai("WBGene00004735", format = "gene")
#  rnai("Y47D3B.7", format = "sequence")

## ------------------------------------------------------------------------
t(
    rnai("III-6C01", library = "ahringer384")
)

## ------------------------------------------------------------------------
t(
    rnai("86B01", library = "ahringer96")
)

## ------------------------------------------------------------------------
t(
    rnai("11010G06", library = "orfeome96")
)

## ------------------------------------------------------------------------
t(
    rnai("tf_all-1E1", library = "cherrypick")
)

