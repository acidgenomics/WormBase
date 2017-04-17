#' Generate well identifiers for a microplate
#'
#' @param plate Number of plates
#' @param well Number of wells (\code{96}, \code{384})
#' @param control Number of control wells
#' @param prefix Plate name prefix
#'
#' @return Data frame
#' @export
microplate <- function(
    plate = 1,
    well = 96,
    control = 0,
    prefix = NULL) {
    if (!is.numeric(plate) | plate < 1) {
        stop("Invalid plate identifier")
    }
    if (well == 96) {
        col <- 12
        row <- 8
    } else if (well == 384) {
        col <- 24
        row <- 16
    } else {
        stop("Invalid plate format")
    }
    col <- 1:col %>% str_pad(max(str_length(.)), pad = "0")
    row <- LETTERS[1:row]
    plate <- 1:plate %>% str_pad(max(str_length(.)), pad = "0")
    df <- expand.grid(plate, row, col)
    vector <- paste0(df$Var1, "-", df$Var2, df$Var3) %>% sort
    # Remove control wells from vector:
    if (!is.numeric(control) | !control %in% 0:12) {
        stop("Please specify 0:12 control wells")
    }
    if (control > 0) {
        # Create a grep string matching the control wells:
        grep <- 1:control %>%
            str_pad(max(str_length(col)), pad = "0") %>%
            paste(collapse = "|") %>%
            paste0("A(", ., ")$")
        # Remove the control wells using `grepl()`:
        vector <- vector[!grepl(grep, vector)]
    }
    # Add a prefix, if desired:
    if (length(prefix) != 1) {
        stop("Only a single character prefix is allowed")
    }
    if (!is.null(prefix) & is.character(prefix)) {
        vector <- paste0(prefix, "-", vector)
    }
    return(vector)
}
