context("FTP File Functions")



## blastp ======================================================================
test_that("blastp : Versioned", {
    x <- blastp(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            wormpep = "character",
            peptide = "character",
            eValue = "numeric"
        )
    )
    expect_identical(dim(x), c(14511L, 3L))
})

test_that("blastp : Current", {
    x <- blastp(version = NULL)
    expect_is(x, "tbl_df")
})



## description =================================================================
test_that("description : Versioned", {
    x <- description(version = wbstable)
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(nrow(x), ngene)
})

test_that("description : Current", {
    x <- description(version = NULL)
    expect_is(x, "tbl_df")
})



## geneIDs =====================================================================
test_that("geneIDs : Versioned", {
    x <- geneIDs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(nrow(x), ngene)
})

test_that("geneIDs : Current", {
    x <- geneIDs(version = NULL)
    expect_is(x, "tbl_df")
})



## geneOtherIDs ================================================================
test_that("geneOtherIDs : Versioned", {
    x <- geneOtherIDs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            geneID = "character",
            geneOtherIDs = "list"
        )
    )
    expect_identical(dim(x), c(ngene, 2L))
})

test_that("geneOtherIDs : Current", {
    x <- geneOtherIDs(version = NULL)
    expect_is(x, "tbl_df")
})



## oligos ======================================================================
test_that("oligos : Versioned", {
    x <- oligos(version = wbstable)
    expect_identical(
        lapply(x, class),
        list(
            geneID = "character",
            oligo = "list"
        )
    )
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(18833L, 2L))
})

test_that("oligos : Current", {
    x <- oligos(version = NULL)
    expect_is(x, "tbl_df")
})



## orthologs ===================================================================
test_that("orthologs : Versioned", {
    x <- orthologs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            geneID = "character",
            homoSapiens = "list",
            musMusculus = "list",
            drosophilaMelanogaster = "list",
            danioRerio = "list"
        )
    )
    expect_identical(dim(x), c(18966L, 5L))
})

test_that("orthologs : Current", {
    x <- orthologs(version = NULL)
    expect_is(x, "tbl_df")
})



## peptides ====================================================================
test_that("peptides : Versioned", {
    x <- peptides(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
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
    expect_identical(dim(x), c(28237L, 8L))
})

test_that("peptides : Current", {
    x <- peptides(version = NULL)
    expect_is(x, "tbl_df")
})



## rnaiPhenotypes ==============================================================
test_that("rnaiPhenotypes : Versioned", {
    x <- rnaiPhenotypes(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            geneID = "character",
            rnaiPhenotypes = "list"
        )
    )
    expect_identical(dim(x), c(8010L, 2L))
})

test_that("rnaiPhenotypes : Current", {
    x <- rnaiPhenotypes(version = NULL)
    expect_is(x, "tbl_df")
})
