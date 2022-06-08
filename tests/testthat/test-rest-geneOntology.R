test_that("current", {
    x <- geneOntology(genes)
    expect_s4_class(x, "SimpleList")
    expect_identical(names(x), unname(genes))
    expect_identical(
        object = names(x[[1L]]),
        expected = c(
            "biologicalProcess",
            "cellularComponent",
            "molecularFunction"
        )
    )
})

test_that("NULL return", {
    genes <- "WBGene00000000"
    x <- geneOntology(genes)
    expect_identical(names(x), unname(genes))
    expect_identical(
        object = x[[1L]],
        expected = NULL
    )
})
