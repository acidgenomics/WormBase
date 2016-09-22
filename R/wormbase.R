#' WormBase FTP server file download.
#'
#' @import utils
#'
#' @param request WormBase FTP server file request.
#'
#' @return Local file path of downloaded file.
#' @export
wormbaseFile <- function(request) {
    annotation <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"
    if (request == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(request, ".txt.gz")
    }
    fileUrl <- paste0(annotation, request, "/c_elegans.", version, ".", fileName)
    filePath <- file.path("data-raw", "wormbase", fileName)
    if (!file.exists(filePath)) {
        utils::download.file(fileUrl, filePath)
    }
    return(filePath)
}


#' Map a dead sequence to current WormBase gene identifier.
#'
#' @import dplyr
#' @import httr
#' @import seqcloudr
#'
#' @param sequence Sequence (ORF).
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseGeneMerge("M01E10.2")
wormbaseGeneMerge <- function(sequence) {
    sequence <- seqcloudr::sortUnique(sequence)
    list <- lapply(seq_along(sequence), function(a) {
        query <- sequence[a]
        request <- httr::GET(paste0("http://www.wormbase.org/search/gene/", query, "?species=c_elegans"),
                             config = httr::content_type_json())
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
    dplyr::bind_rows(list) %>%
        dplyr::filter(!is.na(gene))
}


#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API.
#'
#' @import httr
#' @import dplyr
#' @import seqcloudr
#' @import stringr
#'
#' @param historical WormBase historical RNAi experiment vector.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseHistorical2rnai("JA:K10E9.1")
wormbaseHistorical2rnai <- function(historical) {
    historical <- seqcloudr::sortUnique(historical)
    list <- lapply(seq_along(historical), function(a) {
        request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical[a]))
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


#' WormBase RESTful API query.
#'
#' @import httr
#'
#' @param query A WormBase gene identifier (e.g. WBGene00000001).
#' @param class A class (e.g. gene).
#' @param instance An instance (e.g. concise_description).
#'
#' @description
#' \url{http://www.wormbase.org/about/userguide/for_developers/API-REST}
#'
#' @export
wormbaseRest <- function(query, class, instance) {
    httr::GET(paste0("http://api.wormbase.org/rest/field/", class, "/", query, "/", instance),
              config = httr::content_type_json()) %>%
        httr::content(.)
}


#' WormBase RESTful gene identifier query.
#'
#' @import httr
#' @import dplyr
#' @import seqcloudr
#' @import stringr
#' @import tibble
#' @import xml2
#'
#' @param gene WormBase gene identifier.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestGeneExternal("WBGene00000001")
wormbaseRestGeneExternal <- function(gene) {
    gene <- seqcloudr::sortUnique(gene)
    list <- lapply(seq_along(gene), function(a) {
        rest <- httr::GET(paste0("http://api.wormbase.org/rest/widget/gene/", gene[a], "/external_links"),
                          config = httr::content_type_json()) %>%
            httr::content(.)
        list(gene = gene[a],
             aceview = rest$fields$xrefs$data$AceView$gene$ids[[1]],
             ncbi = rest$fields$xrefs$data$NCBI$gene$ids[[1]],
             refseqMrna = rest$fields$xrefs$data$RefSeq$mRNA$ids[[1]],
             refseqProtein = rest$fields$xrefs$data$RefSeq$protein$ids[[1]],
             treefam = rest$fields$xrefs$data$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = rest$fields$xrefs$data$UniProt$UniProtAcc$ids[[1]])
    })
    dplyr::bind_rows(lapply(list, function(x) {
        tibble::as_tibble(Filter(Negate(is.null), x))
    }))
}


#' WormBase RESTful RNAi sequence query.
#'
#' @import dplyr
#' @import seqcloudr
#'
#' @param rnai WormBase RNAi identifier.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestRnaiSequence("WBRNAi00003982")
wormbaseRestRnaiSequence <- function(rnai) {
    rnai <- seqcloudr::sortUnique(rnai)
    list <- lapply(seq_along(rnai), function(a) {
        data <- wormbaseRest(rnai[a], class = "rnai", instance = "sequence") %>%
            .[["sequence"]] %>%
            .[["data"]] %>%
            .[[1]]
        if (length(data)) {
            oligo <- data$header
            length <- data$length
            #! sequence <- data$sequence
        } else {
            oligo <- NA
            length <- NA
            # sequence <- NA
        }
        list(rnai = rnai[a],
             oligo = oligo,
             length = length)
    })
    dplyr::bind_rows(list)
}


#' WormBase RESTful RNAi targets query.
#'
#' @import dplyr
#' @import seqcloudr
#' @import stringr
#'
#' @param rnai WormBase RNAi identifier vector.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestRnaiTargets("WBRNAi00031683")
wormbaseRestRnaiTargets <- function(rnai) {
    rnai <- seqcloudr::sortUnique(rnai)
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
            tbl <- dplyr::bind_rows(list) %>%
                dplyr::filter(grepl("WBGene", id)) %>%
                dplyr::group_by(type) %>%
                dplyr::summarize(id = seqcloudr::toString(id))
            primary <- tbl %>%
                dplyr::filter(type == "primary") %>%
                dplyr::select(id) %>%
                as.character(.)
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- tbl %>%
                dplyr::filter(type == "secondary") %>%
                dplyr::select(id) %>%
                as.character(.)
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
