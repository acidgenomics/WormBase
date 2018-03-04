context("Annotation File Functions")

# blastp =======================================================================
test_that("blastp : Current", {
    x <- blastp()
})

test_that("blastp : Versioned", {
    x <- blastp(version = version)
})



# description ==================================================================
test_that("description : Current", {
    x <- description()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "conciseDescription" = "character",
            "provisionalDescription" = "character",
            "automatedDescription" = "character",
            "geneClassDescription" = "character"
        )
    )
})

test_that("description : Versioned", {
    x <- description(version = version)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(ngene, 5L))
})



# geneIDs ======================================================================
test_that("geneIDs : Current", {
    x <- geneIDs()
    expect_is(x, "tbl_df")
    expect_identical(
        lapply(x, class),
        list(
            "gene" = "character",
            "symbol" = "character",
            "sequence" = "character",
            "status" = "character"
        )
    )
})

test_that("geneIDs : Versioned", {
    x <- geneIDs(version = version)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(ngene, 4L))
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
    x <- geneOtherIDs(version = version)
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
    x <- oligos(version = version)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(18833L, 2L))
})



# peptides =====================================================================
test_that("peptides : Current", {

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
    x <- rnaiPhenotypes(version = version)
    expect_is(x, "tbl_df")
    expect_identical(dim(x), c(8010L, 2L))
})
