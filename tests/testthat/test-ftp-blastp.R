context("ftp : blastp")

test_that("current", {
    x <- blastp(release = NULL)
    expect_s4_class(x, "SplitDataFrameList")
})

test_that("stable", {
    x <- blastp(release = release)
    expect_s4_class(x, "SplitDataFrameList")
    expect_identical(length(x), 14557L)
})
