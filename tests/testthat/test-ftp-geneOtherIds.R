test_that("current", {
    x <- geneOtherIds(release = NULL)
    expect_s4_class(x, "CharacterList")
})

test_that("stable", {
    x <- geneOtherIds(release = release)
    expect_s4_class(x, "CharacterList")
    expect_length(x, ngene)
})
