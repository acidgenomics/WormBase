metadata <- data.frame()
datasets <- c("GeneID",
              "description",
              "rnai_phenotypes",
              "orthologs",
              "blastp",
              "biomart",
              "panther")
metadata <- do.call(cbind, mget(datasets))
colnames(metadata) <- gsub("^GeneID\\.", "", colnames(metadata))
metadata <- data.frame(apply(metadata, 2, function(x) gsub("^(,|\\s//)\\s(.*)", "\\2", x, perl = TRUE)))
metadata <- data.frame(apply(metadata, 2, function(x) gsub("(.*)(,|\\s//)\\s$", "\\1", x, perl = TRUE)))
#! Add step here to change any blank cells to NA

lapply(metadata, class)
colnames(metadata)

# Readable report version
metadata_report <- data.frame()
x <- metadata
x$biomart.chromosome.name <- NULL
x$biomart.end.position <- NULL
x$biomart.ensembl.go.id <- NULL
x$biomart.entrezgene <- NULL
x$biomart.hsapiens.homolog.ensembl.gene <- NULL
x$biomart.interpro <- NULL
x$biomart.interpro.short.description <- NULL
x$biomart.refseq.mrna <- NULL
x$biomart.refseq.ncrna <- NULL
x$biomart.start.position <- NULL
x$biomart.strand <- NULL
x$biomart.uniprot.sptrembl <- NULL
x$biomart.uniprot.swissprot <- NULL
x$blastp.e.val <- NULL
x$blastp.ensembl.gene.id <- NULL
x$blastp.ensembl.peptide.id <- NULL
x$blastp.wormbase.peptide.id <- NULL
x$orthologs.hsapiens.homolog.wormbase.id <- NULL
x$panther.sf.id <- NULL
x$panther.uniprot.kb <- NULL
x$wormbase.status <- NULL
metadata_report <- x
rm(x)

# Simple version
metadata_simple <- metadata[, c("GeneID",
                                "ORF",
                                "public.name",
                                "gene.other.ids")]

# Rownames by ORF instead of GeneID (Wormbase ID)
metadata_ORF <- metadata_simple
metadata_ORF <- subset(metadata_ORF, !is.na(metadata_ORF$ORF))
metadata_ORF <- subset(metadata_ORF, !duplicated(metadata_ORF$ORF))
rownames(metadata_ORF) <- metadata_ORF$ORF

devtools::use_data(metadata,
                   metadata_ORF,
                   metadata_report,
                   metadata_simple,
                   overwrite = TRUE)
warnings()
