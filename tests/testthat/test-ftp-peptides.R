context("ftp : peptides")

test_that("current", {
    x <- peptides(version = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- peptides(version = version)
    expect_s4_class(x, "DataFrame")
    expect_identical(nrow(x), 28420L)
})
