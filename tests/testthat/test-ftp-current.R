context("FTP files (current release)")

test_that("blastp", {
    x <- blastp(version = NULL)
    expect_is(x, "tbl_df")
})

## Currently failing for WS270, WS271.
test_that("description", {
    x <- tryCatch(
        expr = {
            description(version = NULL)
        },
        error = function(e) e
    )
    skip_if(
        is(x, "error") &&
        grepl("Invalid FTP file detected.", x)
    )
    expect_is(x, "tbl_df")
})

test_that("geneIDs", {
    x <- geneIDs(version = NULL)
    expect_is(x, "tbl_df")
})

test_that("geneOtherIDs", {
    x <- geneOtherIDs(version = NULL)
    expect_is(x, "tbl_df")
})

test_that("oligos", {
    x <- oligos(version = NULL)
    expect_is(x, "tbl_df")
})

test_that("orthologs", {
    x <- orthologs(version = NULL)
    expect_is(x, "tbl_df")
})

test_that("peptides", {
    x <- peptides(version = NULL)
    expect_is(x, "tbl_df")
})

test_that("rnaiPhenotypes", {
    x <- rnaiPhenotypes(version = NULL)
    expect_is(x, "tbl_df")
})
