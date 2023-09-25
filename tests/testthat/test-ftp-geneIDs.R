test_that("current", {
    x <- geneIDs(release = NULL)
    expect_s4_class(x, "DFrame")
})

test_that("stable", {
    x <- geneIDs(release = release)
    expect_s4_class(x, "DFrame")
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
