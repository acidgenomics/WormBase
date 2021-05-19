context("rest : externalIDs")

test_that("current", {
    x <- externalIDs(genes)
    expect_s4_class(x, "List")
    expect_s4_class(x[[1L]], "CharacterList")
})

test_that("NULL return", {
    x <- externalIDs("WBGene00000000")
    expect_s4_class(x, "List")
    expect_identical(x[[1L]], NULL)
})
