worminfo 0.5.2 (2016-08-29)
================

*C. elegans* gene annotations dynamically assembled from [WormBase](http://www.wormbase.org), [Ensembl](http://www.ensembl.org/Caenorhabditis_elegans), and [PANTHER](http://pantherdb.org). Clone mapping support for [ORFeome](http://worfdb.dfci.harvard.edu) and [Ahringer](http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/) feeding RNAi libraries.

Installation
============

This is an [R](https://www.r-project.org) data package.

To install, run `devtools::install_github("seqcloud/worminfo")`

[![Build Status](https://travis-ci.org/seqcloud/worminfo.svg?branch=master)](https://travis-ci.org/seqcloud/worminfo)

Annotations
===========

Gene annotations were sourced from WormBase WS254, Ensembl Genes 85 and PANTHER 11.0 with R version 3.3.1 (2016-06-21) running on x86\_64-apple-darwin15.5.0.

-   [WormBase](http://www.wormbase.org) genes: 50970
-   [Ahringer](http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/) clones: 19763
-   [ORFeome](http://worfdb.dfci.harvard.edu) clones: 11559

`geneData`
----------

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
12. hsapiensEnsemblGeneId
13. wormpepId
14. ensemblPeptideId
15. hsapiensBlastpGeneId
16. hsapiensBlastpGeneName
17. hsapiensBlastpDescription
18. geneBiotype
19. chromosomeName
20. startPosition
21. endPosition
22. strand
23. ensemblDescription
24. entrezGeneId
25. keggEnzyme
26. refseqMrna
27. refseqNcrna
28. uniprotSptrembl
29. uniprotSwissprot
30. hsapiensHomologEnsemblGene
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

`ahringerData`
--------------

1.  plate
2.  well
3.  chrom
4.  genePair
5.  fwdPrimerSeq
6.  revPrimerSeq
7.  sourceBioscience384
8.  ahringer96
9.  oligo
10. rnaiHistorical

`orfeomeData`
-------------

1.  orfHistorical
2.  plate
3.  row
4.  col
5.  orfeomeHistorical
6.  orfeome
7.  historical
8.  wbrnai
9.  oligo
10. length
11. sequence
