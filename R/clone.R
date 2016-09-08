#' Feeding RNAi Library clone matching
#' @param id Clone identifier
#' @param library Library type ("orfeome" or "ahringer")
#' @param wells Library plate format (96, 384)
#' @param output Output format (report, simple)
#' @return tibble with \code{gene()} metadata
#' @examples
#' clone("11010@G06", library = "orfeome")
#' clone("III-86B01", library = "ahringer", wells = 96)
#' clone("III-6C01", library = "ahringer", wells = 384)
#' @export
clone <- function(id = NULL,
                  library = "orfeome",
                  wells = NULL,
                  output = "simple") {
    if (!is.null(id)) {
        id <- gsub("^(ahringer|GHR|orfeome)", "", id)
        id <- gsub("([A-Z]{1})([0-9]{1})$", "\\10\\2", id) # pad zeros
    }
    if (library == "ahringer") {
        if (!is.null(id)) {
            if (wells == 96) {
                data <- dplyr::filter(cloneData$ahringer, ahringer96 %in% id)
            } else if (wells == 384) {
                data <- dplyr::filter(cloneData$ahringer, sourceBioscience384 %in% id)
            }
        }
    } else if (library == "orfeome") {
        if (!is.null(id)) {
            data <- dplyr::filter(cloneData$orfeome, orfeome96 %in% id)
        }
    }
    tbl <- dplyr::left_join(data, gene(data$geneId, format = "geneId", output = output))
    return(tbl)
}
