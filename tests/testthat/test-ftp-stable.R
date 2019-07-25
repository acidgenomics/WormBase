context("FTP files (stable)")

test_that("blastp", {
    x <- blastp(version = version)
    expect_is(x, "tbl_df")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            wormpep = "character",
            peptide = "character",
            eValue = "numeric"
        )
    )
    expect_identical(
        object = dim(x),
        expected = c(14660L, 3L)
    )
})

test_that("description", {
    x <- description(version = version)
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(
        object = nrow(x),
        expected = ngene
    )
})

test_that("geneIDs", {
    x <- geneIDs(version = version)
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(
        object = nrow(x),
        expected = ngene
    )
})

test_that("geneOtherIDs", {
    x <- geneOtherIDs(version = version)
    expect_is(x, "tbl_df")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            geneOtherIDs = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = ngene
    )
})

test_that("oligos", {
    x <- oligos(version = version)
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            oligo = "list"
        )
    )
    expect_is(x, "tbl_df")
    expect_identical(
        object = nrow(x),
        expected = 18675L
    )
})

test_that("orthologs", {
    x <- orthologs(version = version)
    expect_is(x, "tbl_df")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            homoSapiens = "list",
            musMusculus = "list",
            drosophilaMelanogaster = "list",
            danioRerio = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 20205L
    )
})

test_that("peptides", {
    x <- peptides(version = version)
    expect_is(x, "tbl_df")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            sequence = "character",
            wormpep = "character",
            status = "character",
            uniprot = "character",
            insdc = "character",
            locus = "character",
            product = "character"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 28420L
    )
})

test_that("rnaiPhenotypes", {
    x <- rnaiPhenotypes(version = version)
    expect_is(x, "tbl_df")
    expect_identical(
        object = lapply(x, class),
        expected = list(
            geneID = "character",
            rnaiPhenotypes = "list"
        )
    )
    expect_identical(
        object = nrow(x),
        expected = 7900L
    )
})
