## Optional progress bar.
.pblapply <- function(progress) {
    assert(isFlag(progress))
    if (isTRUE(progress)) {
        requireNamespace("pbapply", quietly = TRUE)
        pbapply::pblapply
    } else {
        lapply
    }
}
