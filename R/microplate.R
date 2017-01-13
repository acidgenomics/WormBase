#' Generate well identifiers for a microplate
#' @export
#' @importFrom stringr str_pad
#' @param plate Number of plates
#' @param well Number of wells (\code{96}, \code{384})
microplate <- function(plate = 1, well = 96) {
    if (well == 96) {
        col <- 12
        row <- 8
    } else if (well == 384) {
        col <- 24
        row <- 16
    } else {
        stop("Invalid plate format.")
    }
    col <- 1:col %>% stringr::str_pad(., max(stringr::str_length(.)), pad = "0")
    row <- LETTERS[1:row]
    plate <- 1:plate %>% stringr::str_pad(., max(stringr::str_length(.)), pad = "0")
    well <- expand.grid(plate, row, col)
    well <- paste0(well$Var1, well$Var2, well$Var3) %>% sort
    well
}
