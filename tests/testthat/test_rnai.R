context("rnai")

test_that("ORFeome library", {
    expect_equal(
        rnai("orfeome96-11010-G06", format = "clone"),
        tibble(
            clone = "orfeome96-11010-G06",
            gene = "WBGene00004735",
            sequence = "Y47D3B.7",
            name = "sbp-1"
        )
    )
    expect_equal(
        rnai("GHR-11010@G06", format = "clone"),
        tibble(
            clone = "GHR-11010@G06",
            gene = "WBGene00004735",
            sequence = "Y47D3B.7",
            name = "sbp-1"
        )
    )
})

test_that("Ahringer library", {
    expect_equal(
        rnai("ahringer384-III-6-C01", format = "clone"),
        tibble(
            clone = "ahringer384-III-6-C01",
            gene = "WBGene00004735",
            sequence = "Y47D3B.7",
            name = "sbp-1"
        )
    )
    expect_equal(
        rnai("ahringer96-86-B01", format = "clone"),
        tibble(
            clone = "ahringer96-86-B01",
            gene = "WBGene00004735",
            sequence = "Y47D3B.7",
            name = "sbp-1"
        )
    )
})

test_that("Mixed clone types", {
    data <- rnai(
        c("orfeome96-11010-G06",
          "ahringer384-III-6-C01",
          "ahringer96-86-B01"),
        format = "clone")
    expect_equal(
        dim(data),
        c(3L, 4L)
    )
    expect_true(all(data[["gene"]] == "WBGene00004735"))
})

test_that("Clone retrieval by gene", {
    data <- rnai("WBGene00004735", format = "gene")
    expect_identical(
        data,
        tibble(
            gene = "WBGene00004735",
            sequence = "Y47D3B.7",
            name = "sbp-1",
            genePair = "Y47D3B.7",
            orfeome96 = "10059-H06, 11010-G06",
            ahringer384 = "III-6-C01",
            ahringer96 = "86-B01"
        )
    )
    expect_identical(
        rnai("Y47D3B.7", format = "sequence") %>%
            .[, colnames(data)],
        data
    )
    expect_identical(
        rnai("sbp-1", format = "name") %>%
            .[, colnames(data)],
        data
    )
})

test_that("Clone retrieval by genePair", {
    expect_identical(
        rnai("Y53H1C.b", format = "genePair"),
        tibble(
            genePair = "Y53H1C.b",
            gene = "WBGene00000010",
            sequence = "Y53H1C.1",
            name = "aat-9",
            orfeome96 = "10187-B10, 11067-F04",
            ahringer384 = "I-5-P07",
            ahringer96 = "19-H04"
        )
    )
})

test_that("bad identifier", {
    expect_equal(
        rnai("XXX", format = "clone"),
        NULL
    )
})
