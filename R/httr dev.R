# dev <- function() {
#   query <- "WBRNAi00009236"
#   rest <- httr::GET(paste0("http://api.wormbase.org/rest/field/rnai/", query, "/targets"),
#                     config = httr::content_type_json())
#   content <- httr::content(rest)
#   data <- content$targets$data
#   list <- lapply(seq_along(data), function(i) {
#     c(data[[i]]$target_type, data[[i]]$gene$id)
#   })
#   df <- data.frame(do.call(rbind, list))
#   colnames(df) <- c("target_type", "id")
#   df$target_type <- seqcloudr::camel(df$target_type)
#
#   data <- df %>% group_by(target_type) %>%
#     summarize(id = paste(sort(unique(id)),collapse = ", ")) %>%
#     gather(data, key, 2:ncol(df)) %>%
#     spread(target_type, key)
#   data[1] <- NULL
# }


# RNAi clone information
# CHANGE THIS TO NOT QUERY SEQUENCE?
rest <- httr::GET(paste0("http://api.wormbase.org/rest/field/rnai/", wbrnai, "/sequence"),
                  config = httr::content_type_json())
content <- httr::content(rest)

oligo <- content$sequence$data[[1]]$header
length <- content$sequence$data[[1]]$length
# sequence <- content$sequence$data[[1]]$sequence
