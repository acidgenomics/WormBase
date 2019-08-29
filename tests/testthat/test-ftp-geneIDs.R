context("ftp : geneIDs")

test_that("current", {
    x <- geneIDs(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- geneIDs(version = version)
    expect_s4_class(x, "DataFrame")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(
        object = nrow(x),
        expected = ngene
    )
})
