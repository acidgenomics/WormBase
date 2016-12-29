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
        html <- worfdbHtml[[a]] %>%
            # Remove map that has other clones
            # This messes up well identifier matching otherwise
            gsub("<map.+</map>", "", .)
        clone <- html %>%
            str_extract_all("[0-9]{5}@[A-H][0-9]+") %>%
            unlist %>%
            toStringUnique
        inFrame <- html %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist %>%
            str_replace("&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            str_replace_all("Y$", TRUE) %>%
            str_replace_all("N$", FALSE) %>%
            toStringUnique
        sequence <- html %>%
            str_match_all("<A HREF=http://www.wormbase.org/db/seq/sequence\\?name=([A-Za-z0-9\\.]+)>") %>%
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
        list <- list(query = names(worfdbHtml)[a],
                     sequence = sequence,
                     clone = clone,
                     sequencingInformation = sequencingInformation,
                     inFrame = inFrame,
                     primer = primer,
                     remap = remap,
                     size = size)
        lapply(list, function(b) {
            as_tibble(Filter(Negate(is.null), b))
        })
    }) %>%
        bind_rows %>%
        wash %>%
        arrange(sequence) %>%
        filter(!is.na(clone)) %>%
        mutate(clone = gsub("@", "", clone),
               clone = gsub("([A-Z]{1})0", "\\1", clone)) %>%
        left_join(gene(.$sequence, format = "sequence", select = "gene"),
                  by = "sequence")
}

if (!file.exists("data-raw/worfdb/worfdbHtml.rda")) {
    data(wormbaseGene)
    sequence <- wormbaseGene$sequence
    worfdbHtml <- worfdbHtml(sequence)
    save(worfdbHtml, file = "data-raw/worfdb/worfdbHtml.rda")
} else {
    load("data-raw/worfdb/worfdbHtml.rda")
}
worfdb <- worfdbData(worfdbHtml)

if (!file.exists("data-raw/worfdb/worfdbHtmlRemap.rda")) {
    # Example: H15N14.1
    sequenceRemap <- worfdb %>%
        filter(!is.na(remap)) %>%
        .$remap %>% toString %>%
        str_split(", ") %>%
        unlist
    worfdbHtmlRemap <- worfdbHtml(sequenceRemap)
    save(worfdbHtmlRemap, file = "data-raw/worfdb/worfdbHtmlRemap.rda")
} else {
    load("data-raw/worfdb/worfdbHtmlRemap.rda")
}
worfdbRemap <- worfdbData(worfdbHtmlRemap)

worfdb <- bind_rows(worfdb, worfdbRemap) %>%
    filter(is.na(remap)) %>%
    select(-c(query, remap)) %>%
    #! group_by(clone) %>%
    #! collapse %>%
    arrange(clone)
use_data(worfdb, overwrite = TRUE)

# Check for duplicates
dupes <- worfdb %>%
    filter(clone %in% unique(.[["clone"]][duplicated(.[["clone"]])]))
