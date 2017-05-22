#' Query WORFDB website for RNAi clone annotations
#'
#' @rdname worfdb
#' @keywords internal
#'
#' @param sequence Sequence identifier.
#' @param worfdbHTML List of WORFDB HTML pages.
#'
#' @export
worfdbHTML <- function(sequence) {
    sequence <- sequence %>% na.omit %>% unique
    pbmclapply(seq_along(sequence), function(a) {
        GET(paste0("http://worfdb.dfci.harvard.edu/searchallwormorfs.pl?by=name&sid=",
                   sequence[a]),
            user_agent = user_agent(userAgent)) %>%
            content("text")
    }) %>% set_names(sequence)
}



#' @rdname worfdb
#' @export
worfdbData <- function(worfdbHTML) {
    pbmclapply(seq_along(worfdbHTML), function(a) {
        html <- worfdbHTML[[a]] %>%
            # Remove `<map>` that has other clone information
            # This messes up well identifier matching otherwise
            str_replace("<map.+</map>", "")
        clone <- html %>%
            str_extract_all("[0-9]{5}@[A-H][0-9]+") %>%
            unlist %>%
            toStringUnique
        inFrame <- html %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist %>%
            str_replace("&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            gsub("Y$", TRUE, .) %>%
            gsub("N$", FALSE, .) %>%
            toStringUnique
        sequence <- html %>%
            # [fix] E_BE45912.2
            str_match_all("<A HREF=http://www.wormbase.org/db/seq/sequence\\?name=([A-Za-z0-9_\\.]+)>") %>%
            .[[1]] %>% .[, 2] %>%
            # Strip isoform
            gsub("[a-z]$", "", .) %>%
            toStringUnique
        sequencingInformation <- html %>%
            str_extract_all("OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist %>%
            toStringUnique
        primer <- html %>%
            str_match_all("<font color=red><B>([acgt]+)[\n]?</B></font>") %>%
            .[[1]] %>% .[, 2] %>%
            toupper %>%
            toString
        size <- html %>%
            str_match_all("size: &nbsp;([0-9]+)") %>%
            .[[1]] %>% .[, 2] %>%
            toString
        remap <- html %>%
            str_match_all("<TR><TD><A HREF=searchallwormorfs.pl\\?sid=([A-Z0-9]+\\.[0-9]+[a-z]?)>[A-Z0-9]+\\.[0-9]+[a-z]?</A></TD><TD>([0-9]{5}@[A-H][0-9]+)</TD><TD>([0-9]{5}@[A-H][0-9]+)?</TD><TD>(N|Y)</TD><TD>([0-9]+)</TD></TR>") %>%
            .[[1]] %>% .[, 2] %>%
            toStringUnique
        list <- list(query = names(worfdbHTML)[a],
                     sequence = sequence,
                     clone = clone,
                     sequencingInformation = sequencingInformation,
                     inFrame = inFrame,
                     primer = primer,
                     remap = remap,
                     size = size)
        lapply(list, function(b) {
            as.character(Filter(Negate(is.null), b))
        })
    }) %>%
        bind_rows %>%
        arrange(!!sym("sequence")) %>%
        filter(!is.na(.data$clone)) %>%
        mutate(clone = str_replace(.data$clone, "@", ""),
               clone = str_replace(.data$clone, "([A-Z]{1})0", "\\1")) %>%
        # Set `""` columns to `NA`. Improve upstream code to avoid this?
        wash
}
