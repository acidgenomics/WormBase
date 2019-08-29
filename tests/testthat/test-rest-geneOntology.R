context("rest : geneOntology")

test_that("current", {
    x <- geneOntology(genes)
    expect_s4_class(x, "DataFrame")
    expect_identical(x[["geneID"]], as.character(genes))
    expect_identical(
        lapply(x, class),
        list(
            geneID = "character",
            biologicalProcess = "list",
            cellularComponent = "list",
            molecularFunction = "list"
        )
    )
})

test_that("NULL return", {
    expect_identical(
        geneOntology("WBGene00000000"),
        NULL
    )
})
