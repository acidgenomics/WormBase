## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(results = "asis", render = pander::pander)
pander::panderOptions("table.style", "rmarkdown")
pander::panderOptions("table.alignment.default", "left")
pander::panderOptions("table.alignment.rownames", "right")
devtools::load_all()

## ------------------------------------------------------------------------
identifier <- c("WBGene00000898", "WBGene00000912", "WBGene00004804")
gene(identifier, format = "gene")

## ------------------------------------------------------------------------
identifier <- c("Y55D5A.5", "R13H8.1", "T19E7.2")
gene(identifier, format = "sequence")

## ------------------------------------------------------------------------
identifier <- c("daf-2", "daf-16", "skn-1")
gene(identifier, format = "name")

## ------------------------------------------------------------------------
head(
    gene("daf", format = "class")
)

## ------------------------------------------------------------------------
head(
    gene("lifespan", format = "keyword",
         select = c("gene", "sequence", "name"))
)

## ---- echo = FALSE, results = "asis"-------------------------------------
seqcloudr::markdownList(names(
    gene(identifier, select = NULL)
))

## ---- echo = FALSE, results = "asis"-------------------------------------
seqcloudr::markdownList(names(
    gene(identifier)
))

## ------------------------------------------------------------------------
t(
    gene("daf-2", format = "name", select = "identifiers")
)

## ------------------------------------------------------------------------
t(
    gene("daf-16", format = "name", select = "report")
)

## ------------------------------------------------------------------------
t(
    gene("sbp-1", format = "name",
     select = c("descriptionConcise",
                "descriptionProvisional",
                "descriptionEnsembl"))
)

## ------------------------------------------------------------------------
t(
    gene("skn-1", format = "name", select = NULL)
)

