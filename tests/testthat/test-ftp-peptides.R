context("ftp : peptides")

test_that("current", {
    x <- peptides(version = NULL)
    expect_s4_class(x, "SplitDataFrameList")
})

test_that("stable", {
    x <- peptides(version = version)
    expect_s4_class(x, "SplitDataFrameList")
    expect_identical(length(x), 20191L)
})
