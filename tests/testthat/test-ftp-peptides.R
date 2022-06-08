test_that("current", {
    x <- peptides(release = NULL)
    expect_s4_class(x, "SplitDataFrameList")
})

test_that("stable", {
    x <- peptides(release = release)
    expect_s4_class(x, "SplitDataFrameList")
    expect_identical(length(x), 19997L)
    expect_identical(
        object = x[[1L]],
        expected = DataFrame(
            "geneId" = "WBGene00000001",
            "wormpep" = "CE23248",
            "status" = "Confirmed",
            "uniprot" = "G5EDP9",
            "insdc" = "CCD66201.1",
            "sequence" = "Y110A7A.10",
            "locus" = "aap-1",
            "product" = NA_character_
        )
    )
})
