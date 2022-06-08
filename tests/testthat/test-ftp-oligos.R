test_that("current", {
    x <- oligos(release = NULL)
    expect_s4_class(x, "CharacterList")
})

test_that("stable", {
    x <- oligos(release = release)
    expect_s4_class(x, "CharacterList")
    expect_length(x, 18447L)
    expect_identical(
        object = x[[1L]],
        expected = c(
            "cenix:90-h3",
            "mv_Y110A7A.10",
            "sjj_Y110A7A.k"
        )
    )
})
