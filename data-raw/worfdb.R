# Functions ====
worfdbHtml <- function(sequence) {
    sequence <- sequence %>% na.omit %>% unique
    pbmcapply::pbmclapply(seq_along(sequence), function(a) {
        GET(paste0("http://worfdb.dfci.harvard.edu/searchallwormorfs.pl?by=name&sid=",
                   sequence[a]),
            user_agent = user_agent(ua)) %>%
            content("text")
    }) %>% set_names(sequence)
}

worfdbData <- function(worfdbHtml) {
    pbmcapply::pbmclapply(seq_along(worfdbHtml), function(a) {
        clone <- worfdbHtml[[a]] %>%
            str_extract_all("[0-9]{5}@[A-H][0-9]+") %>%
            unlist %>%
            toStringUnique
        inFrame <- worfdbHtml[[a]] %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist %>%
            str_replace("&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            str_replace_all("Y$", TRUE) %>%
            str_replace_all("N$", FALSE) %>%
            toStringUnique
        sequence2 <- worfdbHtml[[a]] %>%
            str_match_all("<A HREF=http://www.wormbase.org/db/seq/sequence\\?name=([A-Z0-9]+\\.[0-9]+[a-z]?)>") %>%
            .[[1]] %>% .[, 2] %>%
            toStringUnique
        sequencingInformation <- worfdbHtml[[a]] %>%
            str_extract_all("OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist %>%
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
        list <- list(sequence = names(worfdbHtml)[a],
                     sequence2 = sequence2,
                     clone = clone,
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

if (!file.exists("data-raw/worfdb/worfdbHtml.rda")) {
    data(wormbaseGene)
    sequence <- wormbaseGene$sequence
    worfdbHtml <- worfdbHtml(sequence)
    save(worfdbHtml, file = "data-raw/worfdb/worfdbHtml.rda")
} else {
    load("data-raw/worfdb/worfdbHtml.rda")
}

worfdb <- worfdbData(worfdbHtml) %>%
    arrange(sequence) %>%
    filter(!is.na(clone)) %>%
    mutate(clone = gsub("@", "", clone),
           clone = gsub("([A-Z]{1})0", "\\1", clone)) %>%
    left_join(gene(.$sequence, format = "sequence", select = "gene"),
              by = "sequence")
use_data(worfdb, overwrite = TRUE)

# if (!file.exists("data-raw/worfdb/worfdbHtmlRemap.rda")) {
#     # Example: H15N14.1
#     sequenceRemap <- worfdb %>%
#         filter(!is.na(remap)) %>%
#         .$remap %>% toString %>%
#         str_split(", ") %>%
#         unlist
#     worfdbHtmlRemap <- worfdbHtml(sequenceRemap)
#     save(worfdbHtmlRemap, file = "data-raw/worfdb/worfdbHtmlRemap.rda")
# } else {
#     load("data-raw/worfdb/worfdbHtmlRemap.rda")
# }
#
# worfdbRemap <- worfdbData(worfdbHtmlRemap)
