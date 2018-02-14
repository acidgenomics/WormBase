markdown <- list.files(pattern = "*.Rmd")
markdown <- markdown[grepl("^[0-9]{2}_", markdown)]
print(markdown)
lapply(
    X = markdown,
    FUN = function(file) {
        rmarkdown::render(file, envir = new.env())
    }
)
