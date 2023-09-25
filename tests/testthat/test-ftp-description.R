test_that("current", {
    x <- description(release = NULL)
    expect_s4_class(x, "DFrame")
})

test_that("stable", {
    x <- description(release = release)
    expect_s4_class(x, "DFrame")
    expect_identical(nrow(x), ngene)
})
