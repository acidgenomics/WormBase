context("ftp : peptides")

test_that("current", {
    x <- peptides(release = NULL)
    expect_s4_class(x, "SplitDataFrameList")
})

test_that("stable", {
    x <- peptides(release = release)
    expect_s4_class(x, "SplitDataFrameList")
    expect_identical(length(x), 20191L)
})
