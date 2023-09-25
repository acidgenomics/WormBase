test_that("current", {
    x <- externalIDs(genes)
    expect_s4_class(x, "List")
    expect_s4_class(x[[1L]], "CharacterList")
})

test_that("Invalid gene", {
    expect_error(
        object = externalIDs("WBGene00000000"),
        regex = "isAnExistingURL"
    )
})
