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

test_that("NULL return", {
    genes <- "WBGene00000000"
    x <- geneOntology(genes)
    expect_named(x, unname(genes))
    expect_null(x[[1L]])
})
