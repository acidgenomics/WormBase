context("gene")

# Possibly rename to `ensgene` in future update
test_that("gene", {
    data <- gene("WBGene00004804", format = "gene")
    expect_equal(
        data,
        tibble(
            gene = "WBGene00004804",
            sequence = "T19E7.2",
            name = "skn-1"
        )
    )

})

# Possibly rename to `orf` in future update
test_that("sequence", {
    data <- gene("T19E7.2", format = "sequence")
    expect_equal(
        data,
        tibble(
            sequence = "T19E7.2",
            gene = "WBGene00004804",
            name = "skn-1"
        )
    )
})

# Possibly rename to `symbol` in future update
test_that("name", {
    data <- gene("skn-1", format = "name")
    expect_equal(
        data,
        tibble(
            name = "skn-1",
            gene = "WBGene00004804",
            sequence = "T19E7.2"
        )
    )
})

test_that("class", {
    data <- gene("skn", format = "class")
    expect_equal(
        data,
        tibble(
            class = c("skn", "skn"),
            gene = c("WBGene00004804", "WBGene00004805"),
            sequence = c("T19E7.2", NA),
            name = c("skn-1", "skn-4")
        )
    )
})

test_that("keyword", {
    data <- gene("bzip", format = "keyword")
    expect_equal(
        dim(data),
        c(75L, 4L)
    )
    expect_equal(
        colnames(data),
        c("keyword", "gene", "sequence", "name")
    )
})

test_that("select parameter", {
    data <- gene(
        "WBGene00004804",
        format = "gene",
        select = "class")
    expect_equal(
        data,
        tibble(
            gene = "WBGene00004804",
            sequence = "T19E7.2",
            name = "skn-1",
            class = "SKiNhead"
        )
    )
})

test_that("bad identifier", {
    expect_equal(
        gene("XXX", format = "gene"),
        NULL
    )
    expect_equal(
        gene("XXX", format = "name"),
        NULL
    )
    # sequence
    # class

    # `XXX` will match here since that's a cell type
    expect_equal(
        gene("XXXXXX", format = "keyword"),
        NULL
    )
})
