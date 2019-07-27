## WormBase server must be online to run unit tests.
release <- tryCatch(
    expr = suppressMessages(currentRelease()),
    error = function(e) e
)
skip_if(
    condition = is(release, "error"),
    message = "Connection to WormBase FTP server failed."
)
