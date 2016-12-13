worfdbHtml <- function(sequence) {
    sequence <- sequence %>% na.omit %>% unique
    # `pbmclapply` runs `parallel::mclapply` with `txtProgressBar` enabled.
    pbmcapply::pbmclapply(seq_along(sequence), function(a) {
        httr::GET(paste0("http://worfdb.dfci.harvard.edu/searchallwormorfs.pl?by=name&sid=",
                         sequence[a]),
                  user_agent = httr::user_agent(ua)) %>%
            content("text")
    }) %>% magrittr::set_names(sequence)
}
