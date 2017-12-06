context("prettyClone")

test_that("prettyClone", {
    expect_identical(
        prettyClone(c("11010G6", "III6C1")),
        c("11010-G06", "III-6-C01")
    )
})
