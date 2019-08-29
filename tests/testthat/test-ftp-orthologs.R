context("ftp : orthologs")

test_that("current", {
    x <- orthologs(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- orthologs(version = version)
    expect_s4_class(x, "DataFrame")
    expect_identical(nrow(x), 20205L)
})
