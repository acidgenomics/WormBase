context("REST API Functions")

# geneExternal =================================================================
test_that("geneExternal", {
    x <- geneExternal(genes)
    expect_identical(x[["gene"]], as.character(genes))
    extonly <- x
    extonly[["gene"]] <- NULL
    expect_true(all(vapply(
        X = extonly,
        FUN = is.list,
        FUN.VALUE = logical(1L)
    )))
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
