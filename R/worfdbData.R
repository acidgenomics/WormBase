# try matching "No result found!"
worfdbData <- function(worfdbHtml) {
    pbmcapply::pbmclapply(seq_along(worfdbHtml), function(a) {
        clone <- worfdbHtml[[a]] %>%
            str_extract_all("GHR-[0-9]{5}@[A-H][0-9]+") %>%
            unlist %>%
            toStringUnique
        inFrame <- worfdbHtml[[a]] %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist %>%
            str_replace("&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            str_replace_all("Y$", TRUE) %>%
            str_replace_all("N$", FALSE) %>%
            toStringUnique
        sequence <- worfdbHtml[[a]] %>%
            str_match_all("<A HREF=http://www.wormbase.org/db/seq/sequence\\?name=([A-Z0-9]+\\.[0-9]+[a-z]?)>") %>%
            .[[1]] %>% .[, 2] %>%
            toStringUnique
        sequencingInformation <- worfdbHtml[[a]] %>%
            str_extract_all("OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist %>%
            toStringUnique
        originalPosition <- worfdbHtml[[a]] %>%
            str_match_all("Original Position: &nbsp;([0-9]{5}@[A-H][0-9]+)") %>%
            .[[1]] %>% .[, 2] %>%
            toStringUnique
        primer <- worfdbHtml[[a]] %>%
            str_match_all("<font color=red><B>([acgt]+)</B></font>") %>%
            .[[1]] %>% .[, 2] %>%
            toupper %>%
            toString
        size <- worfdbHtml[[a]] %>%
            str_match_all("size: &nbsp;([0-9]+)") %>%
            .[[1]] %>% .[, 2] %>%
            toString
        remap <- worfdbHtml[[a]] %>%
            str_match_all("<TR><TD><A HREF=searchallwormorfs.pl\\?sid=([A-Z0-9]+\\.[0-9]+[a-z]?)>[A-Z0-9]+\\.[0-9]+[a-z]?</A></TD><TD>([0-9]{5}@[A-H][0-9]+)</TD><TD>([0-9]{5}@[A-H][0-9]+)?</TD><TD>(N|Y)</TD><TD>([0-9]+)</TD></TR>") %>%
            .[[1]] %>% .[, 2] %>%
            toStringUnique
        list <- list(identifier = names(worfdbHtml)[a],
                     sequence = sequence,
                     clone = clone,
                     originalPosition = originalPosition,
                     sequencingInformation = sequencingInformation,
                     inFrame = inFrame,
                     primer = primer,
                     size = size,
                     remap = remap)
        lapply(list, function(b) {
            as_tibble(Filter(Negate(is.null), b))
        })
    }) %>% bind_rows %>% wash
}
