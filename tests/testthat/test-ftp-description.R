test_that("current", {
    x <- description(release = NULL)
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- description(release = release)
    expect_s4_class(x, "DataFrame")
    expect_identical(nrow(x), ngene)
})
