context("minimalClone")

test_that("minimalClone", {
    expect_identical(
        minimalClone(c("11010-G06", "11010@G06", "III-6-C01")),
        c("11010G6", "11010G6", "III6C1")
    )
})
