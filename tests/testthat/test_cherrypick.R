context("cherrypick")

test_that("keyword", {
    data <- cherrypick("unfolded protein response", format = "keyword")
    expect_equal(
        dim(data),
        c(62L, 7L)
    )
})

test_that("gene", {
    data <- cherrypick("WBGene00000898", format = "gene")
    expect_equal(
        data,
        tibble(
            gene = "WBGene00000898",
            sequence = "Y55D5A.5",
            name = "daf-2",
            orfeome96 = "30001-B12, 10023-H06",
            ahringer384 = "III-7-G12",
            ahringer96 = "91-D06"
        )
    )
})

test_that("name", {
    data <- cherrypick("daf-2", format = "name")
    expect_equal(
        data,
        tibble(
            name = "daf-2",
            gene = "WBGene00000898",
            sequence = "Y55D5A.5",
            orfeome96 = "30001-B12, 10023-H06",
            ahringer384 = "III-7-G12",
            ahringer96 = "91-D06"
        )
    )
})

test_that("bad identifier", {
    expect_equal(
        cherrypick("XXX"),
        NULL
    )
})
