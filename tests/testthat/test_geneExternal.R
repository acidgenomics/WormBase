context("geneExternal")

test_that("geneExternal", {
    x <- geneExternal(genes)
    expect_identical(
        x[["gene"]],
        as.character(genes)
    )
    extonly <- x
    extonly[["gene"]] <- NULL
    expect_true(all(vapply(
        X = extonly,
        FUN = is.list,
        FUN.VALUE = logical(1L)
    )))
})
