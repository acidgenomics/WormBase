context("geneExternal")

test_that("geneExternal", {
    data <- geneExternal("WBGene00004804")
    expect_equal(
        data,
        tibble(
            gene = "WBGene00004804",
            aceview = "4G416",
            ncbi = "177343",
            ndb = "CELE_T19E7.2",
            panther = "CAEEL|WormBase=WBGene00004804|UniProtKB=P34707",
            refseq = "NP_001293683.1, NP_741405.1, NP_741404.1, NP_741406.1",
            signalink = "WBGene00004804",
            swissprot = "P34707",
            treefam = "TF317782",
            trembl = "V6CLA3",
            wormflux = "WBGene00004804",
            wormqtl = "WBGene00004804"
        )
    )
})

test_that("bad identifier", {
    data <- suppressWarnings(
        geneExternal(c("XXX", "YYY"))
    )
    expect_equal(data, NULL)
})
