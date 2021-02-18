context("ftp : oligos")

test_that("current", {
    x <- oligos(release = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- oligos(release = release)
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
