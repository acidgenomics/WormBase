context("ftp : description")

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
    expect_s4_class(x, "DataFrame")
})

test_that("stable", {
    x <- description(version = version)
    expect_s4_class(x, "DataFrame")
    expect_true(all(vapply(
        X = x,
        FUN = is.character,
        FUN.VALUE = logical(1L)
    )))
    expect_identical(nrow(x), ngene)
})
