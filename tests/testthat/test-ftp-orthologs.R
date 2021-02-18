context("ftp : orthologs")

test_that("current", {
    x <- orthologs(release = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- orthologs(release = release)
    expect_s4_class(x, "DataFrame")
    expect_identical(nrow(x), 20205L)
})
