load("data/wormbaseGeneId.rda")
df <- df[rownames(wormbaseGeneId), ]
rownames(df) <- rownames(wormbaseGeneId)
