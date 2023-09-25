test_that("current", {
    x <- geneOntology(genes)
    expect_s4_class(x, "SimpleList")
    expect_named(x, unname(genes))
    expect_named(
        object = x[[1L]],
        expected = c(
            "biologicalProcess",
            "cellularComponent",
            "molecularFunction"
        )
    )
})

test_that("Invalid gene", {
    expect_error(
        object = geneOntology("WBGene00000000"),
        regex = "isAnExistingURL"
    )
})
