#' Generate Well Identifiers for a Microtiter Plate
#'
#' @importFrom rlang is_string
#' @importFrom stringr str_length str_pad
#'
#' @param plate Number of plates.
#' @param well Number of wells (`96`, `384`).
#' @param control Number of control wells.
#' @param prefix *Optional*. Plate name prefix.
#'
#' @return [data.frame].
#' @export
microplate <- function(
    plate = 1L,
    well = 96L,
    control = 0L,
    prefix) {
    if (!is.numeric(plate) | plate < 1L) {
        stop("Invalid plate identifier")
    }
    if (well == 96L) {
        col <- 12L
        row <- 8L
    } else if (well == 384L) {
        col <- 24L
        row <- 16L
    } else {
        stop("Invalid plate format")
    }
    col <- 1L:col %>%
        str_pad(max(str_length(.)), pad = "0")
    row <- LETTERS[1L:row]
    plate <- 1L:plate %>%
        str_pad(max(str_length(.)), pad = "0")
    df <- expand.grid(plate, row, col)
    vector <- paste0(df[["Var1"]], "-", df[["Var2"]], df[["Var3"]]) %>%
        sort()
    # Remove control wells from vector:
    if (!is.numeric(control) | !control %in% 0L:12L) {
        stop("Please specify 0:12 control wells")
    }
    if (control > 0L) {
        # Create a grep string matching the control wells:
        grep <- 1L:control %>%
            str_pad(max(str_length(col)), pad = "0") %>%
            paste(collapse = "|") %>%
            paste0("A(", ., ")$")
        # Remove the control wells using `grepl()`:
        vector <- vector[!grepl(grep, vector)]
    }
    # Add a prefix, if desired:
    if (!missing(prefix)) {
        if (!is_string(prefix)) {
            stop("Prefix must be a string")
        }
        vector <- paste0(prefix, "-", vector)
    }
    return(vector)
}
