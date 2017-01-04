#' Gene list report
#'
#' @export
#' @importFrom dplyr arrange_ bind_rows left_join select_
#' @param identifier Gene identifier
#' @return tibble
geneReport <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    lapply(seq_along(identifier), function(a) {
        message(identifier[a])
        gene <- gene(identifier[a],
                     select = c(simpleCol,
                                "class",
                                "biotype",
                                # Ortholog:
                                "blastpHsapiensGene",
                                "blastpHsapiensName",
                                "blastpHsapiensDescription",
                                "orthologHsapiens",
                                # Description:
                                "descriptionConcise",
                                "descriptionProvisional",
                                "descriptionAutomated",
                                "ensemblDescription",
                                # WormBase Additional:
                                "rnaiPhenotype",
                                # Gene Ontology:
                                "ensemblGeneOntology",
                                "interpro",
                                "pantherFamilyName",
                                "pantherSubfamilyName",
                                "pantherGeneOntologyMolecularFunction",
                                "pantherGeneOntologyBiologicalProcess",
                                "pantherGeneOntologyCellularComponent",
                                "pantherClass"))
        result <- gene
        geneOntology <- geneOntology(identifier[a])
        if (nrow(geneOntology)) {
            result <- dplyr::left_join(result, geneOntology, by = "gene")
        }
        uniprot <- uniprot(identifier[a])
        if (nrow(uniprot)) {
            result <- dplyr::left_join(result, uniprot, by = "gene")
            if (!is.na(uniprot$eggnog)) {
                eggnog <- uniprot$eggnog %>%
                    strsplit(", ") %>% .[[1]] %>%
                    eggnog %>%
                    collapse
                result <- dplyr::left_join(result, eggnog, by = "eggnog")
            }
        }
        result <- result %>%
            dplyr::select_(.dots = c("gene",
                                     setdiff(sort(names(.)), "gene"))) %>%
            dplyr::arrange_(.dots = c("gene"))
    }) %>% dplyr::bind_rows(.)
}
