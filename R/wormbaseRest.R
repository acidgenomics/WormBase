# https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
# https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
user_agent <- httr::user_agent("http://github.com/steinbaugh/worminfo")


# @import httr
wormbaseRest <- function(query, class, instance) {
    request <- httr::GET(paste0("http://api.wormbase.org/rest/field/", class, "/", query, "/", instance),
                         config = httr::content_type_json(),
                         user_agent = user_agent)
    httr::content(request)
}


# @import dplyr
# @import httr
# @import tibble
wormbaseRestGeneExternal <- function(gene) {
    gene <- sort(unique(gene))
    list <- lapply(seq_along(gene), function(a) {
        request <- httr::GET(paste0("http://api.wormbase.org/rest/widget/gene/", gene[a], "/external_links"),
                             config = httr::content_type_json(),
                             user_agent = user_agent)
        content <- httr::content(request)
        list(gene = gene[a],
             aceview = content$fields$xrefs$data$AceView$gene$ids[[1]],
             ncbi = content$fields$xrefs$data$NCBI$gene$ids[[1]],
             refseqMrna = content$fields$xrefs$data$RefSeq$mRNA$ids[[1]],
             refseqProtein = content$fields$xrefs$data$RefSeq$protein$ids[[1]],
             treefam = content$fields$xrefs$data$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = content$fields$xrefs$data$UniProt$UniProtAcc$ids[[1]])
    })
    dplyr::bind_rows(lapply(list, function(a) {
        tibble::as_tibble(Filter(Negate(is.null), a))
    }))
}


# @import dplyr
# @import httr
wormbaseRestGeneMerge <- function(sequence) {
    sequence <- sort(unique(sequence))
    list <- lapply(seq_along(sequence), function(a) {
        query <- sequence[a]
        request <- httr::GET(paste0("http://www.wormbase.org/search/gene/", query, "?species=c_elegans"),
                             config = httr::content_type_json(),
                             user_agent = user_agent)
        status <- httr::status_code(request)
        content <- httr::content(request)
        # WormBase seems to use the last entry for matching
        results <- rev(content$results)
        if (length(results)) {
            deadGene <- results[[1]]$name$id
            mergeGene <- results[[1]]$merged_into[[1]]$id
        }
        if (exists("mergeGene") && !is.null(mergeGene)) {
            gene <- mergeGene
        } else if (exists("deadGene") && !is.null(deadGene)) {
            gene <- deadGene
        } else {
            gene <- NA
        }
        list(genePair = query, gene = gene)
    })
    data <- dplyr::bind_rows(list)
    data[!is.na(data$gene), ]
}


# @import dplyr
# @import httr
# @import stringr
wormbaseRestHistoricalToRnai <- function(historical) {
    historical <- sort(unique(historical))
    list <- lapply(seq_along(historical), function(a) {
        request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical[a]),
                             user_agent = user_agent)
        # Server is now returning 400, need to set error method here?
        rnai <- tryCatch(request$headers$location) %>%
            stringr::str_extract(., "WBRNAi[0-9]{8}")
        if (!length(rnai)) {
            rnai <- NA
        }
        list(historical = historical[a],
             rnai = rnai)
    })
    dplyr::bind_rows(list)
}


# @import dplyr
wormbaseRestRnaiSequence <- function(rnai) {
    rnai <- sort(unique(rnai))
    list <- lapply(seq_along(rnai), function(a) {
        data <- wormbaseRest(rnai[a], class = "rnai", instance = "sequence") %>%
            .[["sequence"]] %>%
            .[["data"]] %>%
            .[[1]]
        if (length(data)) {
            oligo <- data$header
            length <- data$length
            sequence <- data$sequence
        } else {
            oligo <- NA
            length <- NA
            sequence <- NA
        }
        list(rnai = rnai[a],
             oligo = oligo,
             length = length,
             sequence = sequence)
    })
    dplyr::bind_rows(list)
}


# @import dplyr
# @import seqcloudr
# @importFrom stats setNames
wormbaseRestRnaiTargets <- function(rnai) {
    rnai <- sort(unique(rnai))
    list <- lapply(seq_along(rnai), function(a) {
        data <- wormbaseRest(rnai[a], class = "rnai", instance = "targets") %>%
            .[["targets"]] %>%
            .[["data"]]
        if (length(data)) {
            list <- lapply(seq_along(data), function(b) {
                type <- data[[b]]$target_type %>%
                    tolower %>%
                    stringr::str_replace(., " target", "")
                id <- data[[b]]$gene$id
                list(type = type, id = id)
            })
            tbl <- dplyr::bind_rows(list)
            tbl <- tbl[grepl("WBGene", tbl$id), ]
            dots <- list(~seqcloudr::toStringUnique(id))
            tbl <- tbl %>%
                dplyr::group_by_(.dots = "type") %>%
                dplyr::summarise_(.dots = stats::setNames(dots, c("id")))
            primary <- tbl[tbl$type == "primary", "id"] %>%
                as.character
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- tbl[tbl$type == "secondary", "id"] %>%
                as.character
            if (secondary == "character(0)") {
                secondary <- NA
            }
        } else {
            primary <- NA
            secondary <- NA
        }
        list(rnai = rnai[a],
             targetPrimary = primary,
             targetSecondary = secondary)
    })
    dplyr::bind_rows(list)
}
