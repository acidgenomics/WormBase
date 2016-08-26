worminfo
================

*C. elegans* genome and RNAi library annotations. Metadata dynamically assembled from [WormBase](http://www.wormbase.org), [Ensembl](http://www.ensembl.org/Caenorhabditis_elegans), and [PANTHER](http://pantherdb.org). Support for ORFeome and Ahringer feeding RNAi libraries.

[![Build Status](https://travis-ci.org/seqcloud/worminfo.svg?branch=master)](https://travis-ci.org/seqcloud/worminfo)

Installation
------------

This is an [R](https://www.r-project.org) data package. Current version is 0.5.1 (2016-08-26).

To install, run `devtools::install_github("seqcloud/worminfo")`.

Annotations
-----------

-   Genes: 50970
-   Ahringer clones: 19763
-   ORFeome clones: 11559

### Data Columns

1.  geneId
2.  publicName
3.  orf
4.  status
5.  geneOtherIds
6.  conciseDescription
7.  provisionalDescription
8.  detailedDescription
9.  automatedDescription
10. geneClassDescription
11. rnaiPhenotypes
12. hsapiensEnsemblGeneName
13. hsapiensEnsemblGeneId
14. wormpepId
15. hsapiensBlastpEnsemblPeptideId
16. hsapiensBlastpEnsemblGeneId
17. hsapiensBlastpEnsemblGeneName
18. hsapiensBlastpEnsemblDescription
19. geneBiotype
20. chromosomeName
21. startPosition
22. endPosition
23. strand
24. ensemblDescription
25. entrezGeneId
26. keggEnzyme
27. refseqMrna
28. refseqNcrna
29. uniprotSptrembl
30. uniprotSwissprot
31. geneOntologyName
32. geneOntologyId
33. interproId
34. interproDescription
35. uniprotKb
36. pantherFamilyName
37. pantherSubfamilyName
38. pantherGeneOntologyMolecularFunction
39. pantherGeneOntologyBiologicalProcess
40. pantherGeneOntologyCellularComponent
41. pantherClass
42. pantherPathway

Built with R version 3.3.1 (2016-06-21) running on x86\_64-apple-darwin15.5.0.
