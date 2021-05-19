#' Current WormBase release
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @return `character(1)`.
#'   WormBase release release (e.g. WS271).
#'
#' @examples
#' currentRelease()
currentRelease <- function() {
    suppressMessages({
        file <- transmit(
            remoteDir = pasteURL(
                "ftp.wormbase.org",
                "pub",
                "wormbase",
                "releases",
                "current-production-release",
                protocol = "ftp"
            ),
            pattern = "^letter",
            download = FALSE
        )
    })
    x <- sub(pattern = "^letter\\.", replacement = "", x = basename(file))
    assert(
        isString(x),
        isMatchingRegex(x, pattern = "^WS\\d{3}$")
    )
    x
}
