## Optional progress bar.
## Updated 2019-07-24.
.pblapply <- function(progress) {
    assert(isFlag(progress))
    if (isTRUE(progress)) {
        requireNamespace("pbapply", quietly = TRUE)
        pbapply::pblapply
    } else {
        lapply
    }
}
