context("FTP File Functions")

# blastp =======================================================================
test_that("blastp : Current", {
    x <- blastp()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "wormpep" = "character",
            "peptide" = "character",
            "eValue" = "numeric"
        )
    )
})

test_that("blastp : Versioned", {
    x <- blastp(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(14511L, 3L))
})



# description ==================================================================
test_that("description : Current", {
    x <- description()
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
})

test_that("description : Versioned", {
    x <- description(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(nrow(x), ngene)
})



# geneIDs ======================================================================
test_that("geneIDs : Current", {
    x <- geneIDs()
    expect_is(x, "tbl_df")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
})

test_that("geneIDs : Versioned", {
    x <- geneIDs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(nrow(x), ngene)
})



# geneOtherIDs =================================================================
test_that("geneOtherIDs : Current", {
    x <- geneOtherIDs()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "otherIDs" = "list"
        )
    )
})

test_that("geneOtherIDs : Versioned", {
    x <- geneOtherIDs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(ngene, 2L))
})



# oligos =======================================================================
test_that("oligos : Current", {
    x <- oligos()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "oligo" = "list"
        )
    )
})

test_that("oligos : Versioned", {
    x <- oligos(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(18833L, 2L))
})



# orthologs ====================================================================
test_that("orthologs : Current", {
    x <- orthologs()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "homoSapiens" = "list",
            "musMusculus" = "list",
            "drosophilaMelanogaster" = "list",
            "danioRerio" = "list"
        )
    )
})

test_that("orthologs : Versioned", {
    x <- orthologs(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(18966L, 5L))
})



# peptides =====================================================================
test_that("peptides : Current", {
    x <- peptides()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "sequence" = "character",
            "wormpep" = "character",
            "status" = "character",
            "uniprot" = "character",
            "insdc" = "character",
            "locus" = "character",
            "product" = "character"
        )
    )
})

test_that("peptides : Versioned", {
    x <- peptides(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(28237L, 8L))
})



# rnaiPhenotypes ===============================================================
test_that("rnaiPhenotypes : Current", {
    x <- rnaiPhenotypes()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "rnaiPhenotypes" = "list"
        )
    )
})

test_that("rnaiPhenotypes : Versioned", {
    x <- rnaiPhenotypes(version = wbstable)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(8010L, 2L))
})
