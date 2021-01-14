context("ftp : geneOtherIDs")

test_that("current", {
    x <- geneOtherIDs(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- geneOtherIDs(version = version)
    expect_s4_class(x, "DataFrame")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            "geneId" = "character",
            "geneOtherIds" = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = ngene
    )
})
