library(testthat)
library(wormbase)

## WormBase server must be online to run unit tests.
if (
    !is.null(curl::nslookup("wormbase.org")) &&
    !is.null(curl::nslookup("ftp.wormbase.org"))
) {
    test_check("wormbase")
}
