#' Query WORFDB Website for RNAi Clone Annotations
#'
#' @keywords internal
#'
#' @importFrom basejump wash
#' @importFrom pbmcapply pbmclapply
#'
#' @rdname worfdb
#' @name worfdb
NULL



#' @rdname worfdb
#' @importFrom httr content GET user_agent
#' @importFrom stats na.omit
#' @param sequence Sequence identifier.
#' @export
worfdbHTML <- function(sequence) {
    sequence <- sequence %>%
        na.omit() %>%
        unique()
    list <- pbmclapply(seq_along(sequence), function(a) {
        file.path("http://worfdb.dfci.harvard.edu",
                  "searchallwormorfs.pl?by=name&sid=",
                  sequence[a]) %>%
            GET(user_agent = user_agent(userAgent)) %>%
            content(as = "text")
    })
    names(list) <- sequence
    list
}



#' @rdname worfdb
#' @importFrom stringr str_extract_all str_match_all
#' @param worfdbHTML List of WORFDB HTML pages.
#' @export
worfdbList <- function(worfdbHTML) {
    pbmclapply(seq_along(worfdbHTML), function(a) {
        html <- worfdbHTML[[a]] %>%
            # Remove `<map>` that has other clone information
            # This messes up well identifier matching otherwise
            gsub(x = ., pattern = "<map.+</map>", replacement = "")
        clone <- html %>%
            str_extract_all("[0-9]{5}@[A-H][0-9]+") %>%
            unlist() %>%
            unique()
        inFrame <- html %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist() %>%
            gsub(x = .,
                 pattern = "&nbsp;<font color=black>([NY])</font>",
                 replacement = "\\1") %>%
            gsub(x = ., pattern = "Y$", replacement = TRUE) %>%
            gsub(x = ., pattern = "N$", replacement = FALSE)
        sequence <- html %>%
            # FIXME E_BE45912.2 ?
            str_match_all("<A HREF=.+/sequence\\?name=([A-Za-z0-9_\\.]+)>") %>%
            .[[1L]] %>%
            .[, 2L] %>%
            # Strip isoform
            gsub(x = ., pattern = "[a-z]$", replacement = "")
        sequencingInformation <- html %>%
            str_extract_all("OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist()
        primer <- html %>%
            str_match_all("<font color=red><B>([acgt]+)[\n]?</B></font>") %>%
            .[[1L]] %>%
            .[, 2L] %>%
            toupper()
        size <- html %>%
            str_match_all("size: &nbsp;([0-9]+)") %>%
            .[[1L]] %>%
            .[, 2L]
        remap <- html %>%
            str_match_all(paste0(
                "<TR>",
                    "<TD>",
                        "<A HREF=searchallwormorfs.pl\\?",
                            "sid=([A-Z0-9]+\\.[0-9]+[a-z]?)>",
                            "[A-Z0-9]+\\.[0-9]+[a-z]?",
                        "</A>",
                    "</TD>",
                    "<TD>",
                        "([0-9]{5}@[A-H][0-9]+)",
                    "</TD>",
                    "<TD>",
                        "([0-9]{5}@[A-H][0-9]+)?",
                    "</TD>",
                    "<TD>",
                        "(N|Y)",
                    "</TD>",
                    "<TD>",
                        "([0-9]+)",
                    "</TD>",
                "</TR>"
            )) %>%
            .[[1L]] %>%
            .[, 2L]
        list(
            query = names(worfdbHTML)[a],
            sequence = sequence,
            clone = clone,
            sequencingInformation = sequencingInformation,
            inFrame = inFrame,
            primer = primer,
            remap = remap,
            size = size)
    })
}



#' @rdname worfdb
#' @importFrom dplyr arrange bind_rows filter mutate
#' @importFrom rlang !! sym
#' @param worfdbList WORFDB list returned by [worfdbList()].
#' @export
worfdbData <- function(worfdbList) {
    lapply(worfdbList, function(x) {
        x %>%
            t() %>%
            as_tibble()
    }) %>%
        bind_rows() %>%
        mutate(query = unlist(.data[["query"]]))
}
