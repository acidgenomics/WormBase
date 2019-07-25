#' Current WormBase release
#'
#' @export
#' @return `character(1)`.
#'   WormBase release version (e.g. WS271).
#' @examples
#' currentRelease()
currentRelease <- function() {
    suppressMessages(
        file <- transmit(
            remoteDir = pasteURL(
                "ftp.wormbase.org",
                "pub",
                "wormbase",
                "releases",
                "current-production-release",
                protocol = "ftp"
            ),
            localDir = tempdir(),
            pattern = "^letter"
        )
    )
    sub(pattern = "^letter\\.", replacement = "", x = basename(file))
}
