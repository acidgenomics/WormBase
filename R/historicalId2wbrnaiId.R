#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API
#'
#' @param vec Vector of WormBase historical RNAi clones
#'
#' @return data.frame
#' @export
#'
#' @examples
#' historical2wbrnai("JA:K10E9.1", "JA:F56C11.1")
historical2wbrnai <- function(vec) {
  list <- parallel::mclapply(vec, function(historical) {
    request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical))
    status <- httr::status_code(request)
    if (status == 200) {
      wbrnai <- NA
      oligo <- NA
      length <- NA
      sequence <- NA
    } else {
      wbrnai <- tryCatch(request$headers$location)
      #! wbrnai <- request$headers$location
      wbrnai <- gsub("http://www.wormbase.org/species/c_elegans/rnai/", "", wbrnai)
      wbrnai

      # RNAi clone information
      # CHANGE THIS TO NOT QUERY SEQUENCE?
      rest <- httr::GET(paste0("http://api.wormbase.org/rest/field/rnai/", wbrnai, "/sequence"),
                        config = httr::content_type_json())
      content <- httr::content(rest)

      oligo <- content$sequence$data[[1]]$header
      length <- content$sequence$data[[1]]$length
      sequence <- content$sequence$data[[1]]$sequence
    }
    data.frame(historical, wbrnai, oligo, length, sequence)
  })
  do.call(rbind, list)
}


dev <- function() {
  query <- "WBRNAi00009236"
  rest <- httr::GET(paste0("http://api.wormbase.org/rest/field/rnai/", query, "/targets"),
                    config = httr::content_type_json())
  content <- httr::content(rest)
  data <- content$targets$data
  list <- lapply(seq_along(data), function(i) {
    c(data[[i]]$target_type, data[[i]]$gene$id)
  })
  df <- data.frame(do.call(rbind, list))
  colnames(df) <- c("target_type", "id")
  df$target_type <- seqcloudr::camel(df$target_type)

  data <- df %>% group_by(target_type) %>%
    summarize(id = paste(sort(unique(id)),collapse = ", ")) %>%
    gather(data, key, 2:ncol(df)) %>%
    spread(target_type, key)
  data[1] <- NULL
}
