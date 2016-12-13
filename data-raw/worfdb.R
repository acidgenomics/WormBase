# Functions ====
worfdbHtml <- function(sequence) {
    sequence <- sequence %>% na.omit %>% unique
    pbmcapply::pbmclapply(seq_along(sequence), function(a) {
        httr::GET(paste0("http://worfdb.dfci.harvard.edu/searchallwormorfs.pl?by=name&sid=",
                         sequence[a]),
                  user_agent = httr::user_agent(ua)) %>%
            content("text")
    }) %>% magrittr::set_names(sequence)
}

worfdbData <- function(worfdbHtml) {
    pbmcapply::pbmclapply(seq_along(worfdbHtml), function(a) {
        clone <- worfdbHtml[[a]] %>%
            stringr::str_extract_all(., "GHR-[0-9]{5}@[A-H][0-9]+") %>%
            unlist %>%
            seqcloudr::toStringUnique(.)
        inFrame <- worfdbHtml[[a]] %>%
            stringr::str_extract_all(., "In Frame.+<font color=black>([NY])</font>") %>%
            unlist %>%
            stringr::str_replace(., "&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            stringr::str_replace_all(., "Y$", TRUE) %>%
            stringr::str_replace_all(., "N$", FALSE) %>%
            seqcloudr::toStringUnique(.)
        sequence <- worfdbHtml[[a]] %>%
            stringr::str_match_all(., "<A HREF=http://www.wormbase.org/db/seq/sequence\\?name=([A-Z0-9]+\\.[0-9]+[a-z]?)>") %>%
            .[[1]] %>% .[, 2] %>%
            seqcloudr::toStringUnique(.)
        sequencingInformation <- worfdbHtml[[a]] %>%
            stringr::str_extract_all(., "OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist %>%
            seqcloudr::toStringUnique(.)
        originalPosition <- worfdbHtml[[a]] %>%
            stringr::str_match_all(., "Original Position: &nbsp;([0-9]{5}@[A-H][0-9]+)") %>%
            .[[1]] %>% .[, 2] %>%
            seqcloudr::toStringUnique(.)
        primer <- worfdbHtml[[a]] %>%
            stringr::str_match_all(., "<font color=red><B>([acgt]+)</B></font>") %>%
            .[[1]] %>% .[, 2] %>%
            toupper %>%
            toString
        size <- worfdbHtml[[a]] %>%
            stringr::str_match_all(., "size: &nbsp;([0-9]+)") %>%
            .[[1]] %>% .[, 2] %>%
            toString
        remap <- worfdbHtml[[a]] %>%
            stringr::str_match_all(., "<TR><TD><A HREF=searchallwormorfs.pl\\?sid=([A-Z0-9]+\\.[0-9]+[a-z]?)>[A-Z0-9]+\\.[0-9]+[a-z]?</A></TD><TD>([0-9]{5}@[A-H][0-9]+)</TD><TD>([0-9]{5}@[A-H][0-9]+)?</TD><TD>(N|Y)</TD><TD>([0-9]+)</TD></TR>") %>%
            .[[1]] %>% .[, 2] %>%
            seqcloudr::toStringUnique(.)
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
            tibble::as_tibble(Filter(Negate(is.null), b))
        })
    }) %>%
        dplyr::bind_rows(.) %>%
        seqcloudr::wash(.)
}


# Scrape by WormBase identifier ====
if (!file.exists("data/worfdbHtml1.rda")) {
    data(wormbaseGene)
    sequence <- wormbaseGene$sequence
    worfdbHtml1 <- worfdbHtml(sequence)
    use_data(worfdbHtml1, overwrite = TRUE)
} else {
    data(worfdb1Html1)
}

worfdb1 <- worfdbData(worfdbHtml1)

if (!file.exists("data/worfdbHtml2.rda")) {
    # Download and analyze sequence remaps
    # Example: H15N14.1
    sequenceRemap <- worfdb1 %>%
        filter(!is.na(remap)) %>%
        .$remap %>% toString %>%
        str_split(", ") %>%
        unlist
    worfdbHtml2 <- worfdbHtml(sequenceRemap)
    use_data(worfdbHtml2, overwrite = TRUE)
} else {
    data(worfdbHtml2)
}

worfdb2 <- worfdbData(worfdbHtml2)

# Merge worfdb1 and worfdb2
worfdb <- bind_rows(worfdb1, worfdb2) %>%
    arrange(identifier, sequence)
use_data(worfdb, overwrite = TRUE)
rm(worfdb1, worfdb2)


# Match to gene identifier with `gene()` function
worfdb <- worfdb %>%
    select(-identifier) %>%
    filter(!is.na(sequence)) %>%
    left_join(gene(.$sequence, format = "sequence", select = "gene"),
              by = "sequence")

flag <- worfdb %>% filter(grepl("does not confirm", sequencingInformation))
