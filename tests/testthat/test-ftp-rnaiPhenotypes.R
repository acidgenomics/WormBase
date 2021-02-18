context("ftp : rnaiPhenotypes")

test_that("current", {
    x <- rnaiPhenotypes(release = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- rnaiPhenotypes(release = release)
    expect_s4_class(x, "DataFrame")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            "geneId" = "character",
            "rnaiPhenotypes" = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 7900L
    )
})
