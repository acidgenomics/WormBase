context("geneReport")

test_that("geneReport", {
    data <- geneReport("skn-1", format = "name")
    expect_equal(
        colnames(data),
        c("gene",
          "sequence",
          "name",
          "class",
          "ortholog",
          "descriptionConcise",
          "rnaiPhenotype",
          "pantherSubfamilyName",
          "pantherGoMF",
          "pantherGoBP",
          "pantherGoCC",
          "pantherClass",
          "pantherPathway",
          "ensemblDescription",
          "biotype",
          "broadClass",
          "geneSeqStart",
          "geneSeqEnd",
          "seqName",
          "seqStrand",
          "seqCoordSystem",
          "entrez",
          "biologicalProcess",  # prefix with wormbase
          "cellularComponent",  # prefix with wormbase
          "molecularFunction",  # prefix with wormbase
          "eggnog",
          "uniprotExistence",
          "uniprotFamilies",
          "uniprotGeneOntology",
          "uniprotKeywords",
          "uniprotReviewed",
          "uniprotScore",
          "uniprotkb",  # rename to uniprotKb or uniprotKB?
          "consensusFunctionalDescription",  # prefix with eggnog
          "cogFunctionalCategory",  # prefix with eggnog
          "cogFunctionalDescription")
    )

})

test_that("bad identifier", {
    expect_equal(
        geneReport("XXX"),
        NULL
    )
})
