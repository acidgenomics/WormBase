context("REST API Functions")

# externalIDs =================================================================
test_that("externalIDs", {
    x <- externalIDs(genes)
    expect_identical(x[["gene"]], as.character(genes))
    extonly <- x
    extonly[["gene"]] <- NULL
    expect_true(all(vapply(
        X = extonly,
        FUN = is.list,
        FUN.VALUE = logical(1L)
    )))
})

test_that("externalIDs : NULL return", {
    expect_identical(
        externalIDs("WBGene00000000"),
        NULL
    )
})



# geneOntology =================================================================
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

test_that("geneOntology : NULL return", {
    expect_identical(
        geneOntology("WBGene00000000"),
        NULL
    )
})
