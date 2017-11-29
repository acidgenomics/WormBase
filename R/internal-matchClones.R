#' @importFrom basejump grepString
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
.matchClones <- function(clones, cloneCol, worminfo) {
    if (length(clones) == 0) {
        return(NULL)
    }
    mclapply(seq_along(clones), function(a) {
        grepString <- clones[[a]] %>%
            minimalClone() %>%
            grepString()
        df <- worminfo %>%
            .[grepl(grepString, .[[cloneCol]]), , drop = FALSE]
        df[["clone"]] <- names(clones)[[a]]
        df
    }) %>%
        bind_rows()
}
