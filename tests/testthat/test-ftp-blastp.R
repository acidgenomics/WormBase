test_that("current", {
    x <- blastp(release = NULL)
    expect_s4_class(x, "SplitDataFrameList")
})

test_that("stable", {
    x <- blastp(release = release)
    expect_s4_class(x, "SplitDataFrameList")
    expect_identical(length(x), 14620L)
    expect_identical(
        object = x[[1L]],
        expected = DataFrame(
            "wormpep" = "CE00004",
            "peptide" = "ENSP00000308897",
            "eValue" = 1e-46
        )
    )
})
