context("eggnog")

test_that("success", {
    eggnog <- eggnog(c("KOG4258", "COG0515"))
    expect_equal(
        eggnog,
        tibble(
            eggnog = c("KOG4258", "COG0515"),
            consensusFunctionalDescription = c(
                "Tyrosine-protein kinase receptor",
                "Serine Threonine protein kinase"
            ),
            cogFunctionalCategory = c("T", "T"),
            cogFunctionalDescription = c(
                "Signal transduction mechanisms",
                "Signal transduction mechanisms"
            )
        )
    )
})

test_that("bad identifier", {
    expect_equal(
        eggnog("XXX"),
        NULL
    )
})
