#' Dynamically cache a URL into package or return local file
#'
#' @note Updated 2021-01-14.
#' @note R won't let you name the function `.cache`.
#' @noRd
#'
#' @return `character(1)`.
#' Local file path
#'
#' @examples
#' file <- pasteUrl(AcidGenomesTestsUrl, "ensembl.gtf")
#' tmpfile <- .cacheIt(file)
#' print(tmpfile)
.cacheIt <- function(file) {
    assert(isString(file))
    if (isAUrl(file)) {
        x <- cacheUrl(url = file, pkg = packageName())
    } else {
        x <- file
    }
    assert(isAFile(x))
    x
}
