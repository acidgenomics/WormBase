context("geneOntology")

test_that("geneOntology", {
    x <- geneOntology(genes)
    expect_identical(x[["gene"]], as.character(genes))
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "biologicalProcess" = "list",
            "cellularComponent" = "list",
            "molecularFunction" = "list"
        )
    )
})
