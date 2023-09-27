test_that("current", {
    x <- externalIds(genes)
    expect_s4_class(x, "List")
    expect_s4_class(x[[1L]], "CharacterList")
})

test_that("Invalid gene", {
    expect_error(
        object = externalIds("WBGene00000000"),
        regex = "isAnExistingUrl"
    )
})
