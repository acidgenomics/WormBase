context("ftp : peptides")

test_that("current", {
    x <- peptides(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- peptides(version = version)
    expect_s4_class(x, "DataFrame")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            sequence = "character",
            wormpep = "character",
            status = "character",
            uniprot = "character",
            insdc = "character",
            locus = "character",
            product = "character"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 28420L
    )
})
