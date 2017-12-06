context("geneOntology")

test_that("geneOntology", {
    data <- geneOntology("WBGene00004804")
    expect_equal(
        colnames(data),
        c("gene",
          "biologicalProcess",
          "cellularComponent",
          "molecularFunction")
    )
})

test_that("bad identifier", {
    data <- suppressWarnings(
        geneOntology(c("XXX", "YYY"))
    )
    expect_equal(data, NULL)
})
