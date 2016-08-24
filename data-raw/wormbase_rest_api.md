REST API reference
http://www.wormbase.org/about/userguide/for_developers/api-rest

https://github.com/WormBase/website/tree/master/lib/WormBase/API/Object

Ahringer mapping (not current, don't use):
ftp://caltech.wormbase.org/pub/annots/rnai/ahringer_mapping_WS239

Example:
http://www.wormbase.org/rest/widget/gene/WBGene00006763/overview

RNAi Perl module:
https://github.com/WormBase/website/blob/master/lib/WormBase/API/Object/Rnai.pm

Oligo URL:
http://www.wormbase.org/species/c_elegans/pcr_oligo/sjj_K10E9.1
http://www.wormbase.org/rest/widget/pcr_oligo/sjj_K10E9.1

CDS (Coding Sequence) DON'T USE:
http://www.wormbase.org/species/c_elegans/cds/F32D8.6
http://www.wormbase.org/species/c_elegans/cds/K10E9.1

RNAi search:
JA:F56C11.3
http://www.wormbase.org/search/rnai/JA:F56C11.3
http://www.wormbase.org/search/rnai/MV_SV:mv_F32D8.6


ID-based RNAi (WBRNAi):
http://www.wormbase.org/species/c_elegans/rnai/WBRNAi00003810

Use RCurl?

Hadley's example
https://github.com/hadley/crantastic/blob/cran-indexing/curr.R

WormBase REST Gist:
https://gist.github.com/danielecook/d1d6819f6396b70ddba7

curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_pseudogene
curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_pseudogene

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/historical_name


Use the URL redirect from search to get the WBRNAi identifier?
