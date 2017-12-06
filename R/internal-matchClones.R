#' @importFrom basejump grepString
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
.matchClones <- function(clones, cloneCol, data) {
    if (length(clones) == 0) {
        return(NULL)
    }
    mclapply(seq_along(clones), function(a) {
        grepString <- clones[[a]] %>%
            minimalClone() %>%
            grepString()
        data <- data %>%
            .[grepl(grepString, .[[cloneCol]]), , drop = FALSE]
        if (!nrow(data)) return(NULL)
        # Replace genePair
        if (cloneCol == "genePair") {
            data[["genePair"]] <- clones[[a]]
        }
        data[["clone"]] <- names(clones)[[a]]
        data
    }) %>%
        bind_rows()
}
