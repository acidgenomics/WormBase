context("rest : externalIDs")

test_that("current", {
    x <- externalIDs(genes)
    expect_s4_class(x, "DataFrame")
    expect_identical(x[["geneID"]], as.character(genes))
    extonly <- x
    extonly[["geneID"]] <- NULL
    expect_true(all(vapply(
        X = extonly,
        FUN = is.list,
        FUN.VALUE = logical(1L)
    )))
})

test_that("NULL return", {
    expect_identical(
        externalIDs("WBGene00000000"),
        NULL
    )
})
