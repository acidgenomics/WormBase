test_that("current", {
    x <- orthologs(release = NULL)
    expect_s4_class(x, "SimpleList")
})

test_that("stable", {
    x <- orthologs(release = release)
    expect_s4_class(x, "SimpleList")
    expect_length(x, 20121L)
    expect_identical(
        object = x[[1L]],
        expected = list(
            "danioRerio" = NA_character_,
            "drosophilaMelanogaster" = "FBgn0020622",
            "homoSapiens" = NA_character_,
            "musMusculus" = NA_character_
        )
    )
})
