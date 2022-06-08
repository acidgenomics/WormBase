test_that("current", {
    x <- rnaiPhenotypes(release = NULL)
    expect_s4_class(x, "CharacterList")
})

test_that("stable", {
    x <- rnaiPhenotypes(release = release)
    expect_s4_class(x, "CharacterList")
    expect_length(x, 7756L)
    expect_identical(
        object = x[[1L]],
        expected = c(
            "dauer induction variant",
            "hermaphrodite sterile"
        )
    )
})
