#' Current WormBase release
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @return `character(1)`.
#'   WormBase release version (e.g. WS271).
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = currentRelease(),
#'     error = function(e) e
#' )
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
