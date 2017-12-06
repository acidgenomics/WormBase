context("uniprot")

test_that("uniprot", {
    data <- suppressMessages(
        uniprot("WBGene00000898")
    )
    expect_is(data, "tbl_df")
    expect_identical(
        colnames(data),
        c("gene",
          "eggnog",
          "uniprotExistence",
          "uniprotFamilies",
          "uniprotGeneOntology",
          "uniprotKeywords",
          "uniprotReviewed",
          "uniprotScore",
          "uniprotkb",
          "consensusFunctionalDescription",
          "cogFunctionalCategory",
          "cogFunctionalDescription")
    )
})
