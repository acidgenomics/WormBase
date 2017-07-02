## ----setup, include = FALSE----------------------------------------------
library(worminfo)

## ---- eval = FALSE-------------------------------------------------------
#  gene("WBGene00004804", format = "gene")
#  gene("T19E7.2", format = "sequence")
#  gene("skn-1", format = "name")

## ---- echo = FALSE-------------------------------------------------------
gene("WBGene00004804") %>% t

## ------------------------------------------------------------------------
gene("daf", format = "class")

## ------------------------------------------------------------------------
gene("unfolded protein response", format = "keyword")

## ---- echo = FALSE, results = "asis"-------------------------------------
get("annotation", envir = asNamespace("worminfo"))$gene %>%
    names %>%
    markdownList

## ---- echo = FALSE, results = "asis"-------------------------------------
gene("WBGene00004804") %>%
    names %>%
    markdownList

## ------------------------------------------------------------------------
gene("sbp-1",
     format = "name",
     select = c("biotype", "ensemblDescription")) %>% t

## ------------------------------------------------------------------------
rnai("sbp-1", format = "name") %>% t

## ---- eval = FALSE-------------------------------------------------------
#  rnai("WBGene00004735", format = "gene")
#  rnai("Y47D3B.7", format = "sequence")
#  rnai("Y47D3B.7", format = "genePair")

## ------------------------------------------------------------------------
c("ahringer384-III-6C01",
  "ahringer96-86-B01") %>% rnai %>% t

## ------------------------------------------------------------------------
c("GHR-11010@G06",
  "orfeome96-11010-G06") %>% rnai %>% t

## ------------------------------------------------------------------------
cherrypick("unfolded protein response",
           ahringer96 = FALSE,
           ahringer384 = FALSE,
           orfeome96 = TRUE)

## ------------------------------------------------------------------------
get("build", envir = asNamespace("worminfo"))

