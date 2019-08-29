context("ftp : orthologs")

test_that("current", {
    x <- orthologs(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- orthologs(version = version)
    expect_s4_class(x, "DataFrame")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            homoSapiens = "list",
            musMusculus = "list",
            drosophilaMelanogaster = "list",
            danioRerio = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 20205L
    )
})
