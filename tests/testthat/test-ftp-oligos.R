context("ftp : oligos")

test_that("current", {
    x <- oligos(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- oligos(version = version)
    expect_identical(
        object = lapply(x, class),
        expected = list(
            "geneId" = "character",
            "oligo" = "list"
        )
    )
    expect_s4_class(x, "DataFrame")
    expect_identical(
        object = nrow(x),
        expected = 18675L
    )
})
