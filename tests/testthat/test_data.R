context("data")

data <- worminfo::worminfo
tibble <- c("tbl_df", "tbl", "data.frame")

test_that("data", {
    expect_equal(
        names(data),
        c("gene",
          "rnai",
          "eggnog",
          "blastp",
          "peptide",
          "build")
    )
    expect_equal(
        lapply(data, class),
        list(gene = tibble,
             rnai = tibble,
             eggnog = "list",
             blastp = tibble,
             peptide = c("grouped_df", tibble),
             build = "list")
    )
    expect_equal(
        names(data[["build"]]),
        c("date",
          "wormbase",
          "panther",
          "rVersion",
          "sessionInfo")
    )
})
