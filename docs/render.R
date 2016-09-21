library(rmarkdown)
rmarkdown::render("docs/README.Rmd",
                  output_dir = ".",
                  output_format = "github_document")
rmarkdown::render("docs/data.Rmd",
                  output_format = "md_document")

