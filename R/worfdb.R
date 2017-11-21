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
            content("text")
    })
    names(list) <- sequence
    list
}



#' @rdname worfdb
#' @importFrom basejump toStringUnique
#' @importFrom dplyr arrange bind_rows filter mutate
#' @importFrom stringr str_extract_all str_match_all str_replace
#' @param worfdbHTML List of WORFDB HTML pages.
#' @export
worfdbData <- function(worfdbHTML) {
    pbmclapply(seq_along(worfdbHTML), function(a) {
        html <- worfdbHTML[[a]] %>%
            # Remove `<map>` that has other clone information
            # This messes up well identifier matching otherwise
            str_replace("<map.+</map>", "")
        clone <- html %>%
            str_extract_all("[0-9]{5}@[A-H][0-9]+") %>%
            unlist() %>%
            toStringUnique()
        inFrame <- html %>%
            str_extract_all("In Frame.+<font color=black>([NY])</font>") %>%
            unlist() %>%
            str_replace("&nbsp;<font color=black>([NY])</font>", "\\1") %>%
            gsub("Y$", TRUE, .) %>%
            gsub("N$", FALSE, .) %>%
            toStringUnique()
        sequence <- html %>%
            # FIXME E_BE45912.2
            str_match_all("<A HREF=.+/sequence\\?name=([A-Za-z0-9_\\.]+)>") %>%
            .[[1L]] %>%
            .[, 2L] %>%
            # Strip isoform
            gsub("[a-z]$", "", .) %>%
            toStringUnique
        sequencingInformation <- html %>%
            str_extract_all("OST in ORFeome version.+\\(WS[0-9]+\\)") %>%
            unlist() %>%
            toStringUnique()
        primer <- html %>%
            str_match_all("<font color=red><B>([acgt]+)[\n]?</B></font>") %>%
            .[[1L]] %>%
            .[, 2L] %>%
            toupper %>%
            toString
        size <- html %>%
            str_match_all("size: &nbsp;([0-9]+)") %>%
            .[[1L]] %>%
            .[, 2L] %>%
            toString()
        remap <- html %>%
            str_match_all("<TR><TD><A HREF=searchallwormorfs.pl\\?sid=([A-Z0-9]+\\.[0-9]+[a-z]?)>[A-Z0-9]+\\.[0-9]+[a-z]?</A></TD><TD>([0-9]{5}@[A-H][0-9]+)</TD><TD>([0-9]{5}@[A-H][0-9]+)?</TD><TD>(N|Y)</TD><TD>([0-9]+)</TD></TR>") %>%  # nolint
            .[[1L]] %>%
            .[, 2L] %>%
            toStringUnique()
        list <- list(
            query = names(worfdbHTML)[a],
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
        bind_rows() %>%
        arrange(!!sym("sequence")) %>%
        filter(!is.na(.data[["clone"]])) %>%
        mutate(clone = str_replace(.data[["clone"]], "@", ""),
               clone = str_replace(.data[["clone"]], "([A-Z]{1})0", "\\1")) %>%
        # FIXME Set `""` columns to `NA`. Possible to avoid this?
        wash()
}
