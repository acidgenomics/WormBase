context("geneReport")

test_that("geneReport", {
    data <- geneReport("skn-1", format = "name")
    expect_identical(
        lapply(data, class),
        list(
            "gene" = "character",
            "sequence" = "character",
            "name" = "character",
            "class" = "character",
            "ortholog" = "list",
            "descriptionConcise" = "character",
            "rnaiPhenotype" = "list",
            "pantherSubfamilyName" = "character",
            "pantherGoMF" = "character",  # TODO GO, list?
            "pantherGoBP" = "character",  # TODO GO, list?
            "pantherGoCC" = "character",  # TODO GO, list?
            "pantherClass" = "character", # TODO list?
            "pantherPathway" = "character",  # TODO list?
            "ensemblDescription" = "character",
            "biotype" = "character",
            "broadClass" = "character",
            "geneSeqStart" = "integer",
            "geneSeqEnd" = "integer",
            "seqName" = "character",
            "seqStrand" = "integer",
            "seqCoordSystem" = "character",
            "entrez" = "list",
            "biologicalProcess" = "character",  # TODO wormbase
            "cellularComponent" = "character",  # TODO wormbase
            "molecularFunction" = "character",  # TODO wormbase
            "eggnog" = "character",
            "uniprotExistence" = "character",
            "uniprotFamilies" = "character",
            "uniprotGeneOntology" = "character",
            "uniprotKeywords" = "character",
            "uniprotReviewed" = "character",
            "uniprotScore" = "character",
            "uniprotkb" = "character",  # rename to uniprotKb or uniprotKB?
            "consensusFunctionalDescription" = "character",  # eggnog
            "cogFunctionalCategory" = "character",  # eggnog
            "cogFunctionalDescription" = "character"
        )
    )
})

test_that("Invalid identifier", {
    expect_equal(
        geneReport("XXX"),
        NULL
    )
})
