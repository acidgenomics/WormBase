#' RNAi Clone Mapping
#'
#' @importFrom dplyr bind_rows filter mutate mutate_at select
#' @importFrom magrittr set_names
#' @importFrom rlang !!! syms
#' @importFrom tibble as_tibble
#'
#' @param identifier Identifier.
#' @param format Identifier format (`clone`, `gene`, `genePair`, `name`, or
#'   `sequence`).
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' # WORFDB ORFeome clones
#' rnai("orfeome96-11010-G06", format = "clone") %>% glimpse()
#' rnai("GHR-11010@G06", format = "clone") %>% glimpse()
#'
#' # Ahringer clones
#' rnai("ahringer384-III-6-C01", format = "clone") %>% glimpse()
#' rnai("ahringer96-86-B01", format = "clone") %>% glimpse()
#'
#' # Mixed clone types (e.g. sbp-1 clones)
#' rnai(
#'     c("orfeome96-11010-G06",
#'       "ahringer384-III-6-C01",
#'       "ahringer96-86-B01"),
#'     format = "clone") %>%
#'     glimpse()
#'
#' # Clone retrieval by gene
#' rnai("WBGene00004735", format = "gene") %>% glimpse()
#' rnai("Y47D3B.7", format = "sequence") %>% glimpse()
#' rnai("sbp-1", format = "name") %>% glimpse()
#'
#' # Clone retrieval by genePair
#' rnai("Y53H1C.b", format = "genePair") %>% glimpse()
rnai <- function(
    identifier,
    format = "clone") {
    identifier <- .uniqueIdentifier(identifier)
    formatCols <- c("clone", "gene", "sequence", "genePair", "name")
    if (!format %in% formatCols) {
        stop(paste(
            "'format' must contain:", toString(formatCols)
        ), call. = FALSE)
    }

    if (format == "sequence") {
        query <- .removeIsoform(identifier)
    } else {
        query <- identifier
    }

    worminfo <- worminfo::worminfo
    data <- left_join(
        worminfo[["rnai"]],
        worminfo[["gene"]][, defaultCol],
        by = "gene") %>%
        select(c(defaultCol), everything())
    rm(worminfo)

    cloneCols <- setdiff(colnames(data), formatCols)

    if (format == "clone") {
        match <- list()

        # WORFDB ORFeome 96 well library
        orfeomeGrep <- "^(GHR|orfeome96)-"
        orfeomeQuery <- query[grepl(orfeomeGrep, query)]
        orfeomeClones <- orfeomeQuery %>%
            gsub(x = ., pattern = orfeomeGrep, replacement = "") %>%
            set_names(orfeomeQuery)
        match[["orfeome"]] <- .matchClones(
            clones = orfeomeClones,
            cloneCol = "orfeome96",
            data = data)

        # Ahringer 384 well library
        ahringer384Grep <- "^ahringer384-"
        ahringer384Query <- query[grepl(ahringer384Grep, query)]
        ahringer384Clones <- ahringer384Query %>%
            gsub(x = ., pattern = ahringer384Grep, replacement = "") %>%
            set_names(ahringer384Query)
        match[["ahringer384"]] <- .matchClones(
            clones = ahringer384Clones,
            cloneCol = "ahringer384",
            data = data)

        # Ahringer 96 well library
        ahringer96Grep <- "^ahringer96-"
        ahringer96Query <- query[grepl(ahringer96Grep, query)]
        ahringer96Clones <- ahringer96Query %>%
            gsub(x = ., pattern = ahringer96Grep, replacement = "") %>%
            set_names(ahringer96Query)
        match[["ahringer96"]] <- .matchClones(
            clones = ahringer96Clones,
            cloneCol = "ahringer96",
            data = data)

        # Cherrypick 96 well library
        cherrypickLibs <- c("bzip", "kinase", "tf")
        cherrypickGrep <- paste0(
            "^(",
            paste(cherrypickLibs, collapse = "|"),
            ")-"
        )
        cherrypickQuery <- query[grepl(cherrypickGrep, query)]
        cherrypickClones <- cherrypickQuery %>%
            set_names(cherrypickQuery)
        match[["cherrypick"]] <- .matchClones(
            clones = cherrypickClones,
            cloneCol = "cherrypick96",
            data = data)

        match <- bind_rows(match)
        if (!nrow(match)) return(NULL)
        match[, c(format, defaultCol)]
    } else if (format == "genePair") {
        match <- .matchClones(
            query,
            cloneCol = "genePair",
            data = data)

    } else {
        match <- data %>%
            .[.[[format]] %in% query, , drop = FALSE]
    }
    if (!nrow(match)) return(NULL)
    match %>%
        select(unique(c(format, defaultCol)), everything()) %>%
        distinct() %>%
        mutate_at(c(cloneCols), prettyClone) %>%
        mutate(cherrypick96 = NULL) %>%
        as_tibble()
}
