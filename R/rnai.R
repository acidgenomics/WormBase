#' RNAi Clone Mapping
#'
#' @importFrom dplyr bind_rows filter mutate mutate_at select
#' @importFrom magrittr set_names
#' @importFrom rlang !!! syms
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
#' rnai("orfeome96-11010-G06")
#' rnai("GHR-11010@G06")
#'
#' # Ahringer clones
#' rnai("ahringer384-III-6-C01")
#' rnai("ahringer96-86-B01")
#'
#' # Mixed clone types (e.g. sbp-1 clones)
#' rnai(c("orfeome96-11010-G06",
#'        "ahringer384-III-6-C01",
#'        "ahringer96-86-B01"))
#'
#' # Clone retrieval by gene
#' rnai("sbp-1", format = "name")
#' rnai("WBGene00004735", format = "gene")
#' rnai("Y47D3B.7", format = "sequence")
#' rnai("Y53H1C.b", format = "genePair")
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

    worminfo <- get("worminfo", envir = asNamespace("worminfo"))
    rnai <- worminfo[["rnai"]]
    gene <- worminfo[["gene"]][, defaultCol]
    annotation <- left_join(rnai, gene, by = "gene") %>%
        select(c(defaultCol), everything())
    rm(worminfo, rnai, gene)

    cloneCols <- setdiff(colnames(annotation), formatCols)

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
            annotation = annotation)

        # Ahringer 384 well library
        ahringer384Grep <- "^ahringer384-"
        ahringer384Query <- query[grepl(ahringer384Grep, query)]
        ahringer384Clones <- ahringer384Query %>%
            gsub(x = ., pattern = ahringer384Grep, replacement = "") %>%
            set_names(ahringer384Query)
        match[["ahringer384"]] <- .matchClones(
            clones = ahringer384Clones,
            cloneCol = "ahringer384",
            annotation = annotation)

        # Ahringer 96 well library
        ahringer96Grep <- "^ahringer96-"
        ahringer96Query <- query[grepl(ahringer96Grep, query)]
        ahringer96Clones <- ahringer96Query %>%
            gsub(x = ., pattern = ahringer96Grep, replacement = "") %>%
            set_names(ahringer96Query)
        match[["ahringer96"]] <- .matchClones(
            clones = ahringer96Clones,
            cloneCol = "ahringer96",
            annotation = annotation)

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
            annotation = annotation)

        match <- bind_rows(match)
        if (nrow(match) == 0) {
            return(NULL)
        }
        match[, c(format, defaultCol)]
    } else {
        match <- annotation %>%
            .[.[[format]] %in% query, ]
        if (nrow(match) == 0) {
            return(NULL)
        }
        match %>%
            select(unique(c(format, defaultCol)), everything()) %>%
            distinct() %>%
            mutate_at(c(cloneCols), prettyClone) %>%
            mutate(cherrypick96 = NULL)
    }
}



#' @importFrom basejump grepString
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
.matchClones <- function(clones, cloneCol, annotation) {
    if (length(clones) == 0) {
        return(NULL)
    }
    mclapply(seq_along(clones), function(a) {
        grepString <- clones[[a]] %>%
            minimalClone() %>%
            grepString()
        df <- annotation %>%
            .[grepl(grepString, .[[cloneCol]]), , drop = FALSE]
        df[["clone"]] <- names(clones)[[a]]
        df
    }) %>%
        bind_rows()
}
