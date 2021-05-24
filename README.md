# R Citation Network based on Text Analysis
This is an extension of A.R. Siders' R Script from [this ResearchGate question](https://www.researchgate.net/post/Is-there-any-recommended-software-to-visualise-articles-papers-references-when-conducting-a-systematic-review-or-meta-analysis).

The major differences lie in:
- Using only the reference section of the articles of interest, rather than full texts.
- Including automatic data preparation based on medatada downloaded from [Scopus](https://www.scopus.com/)

## Step
1. Export metadata from Scopus in csv, selecting at least "Doculement title" and "Include references"
![image](https://user-images.githubusercontent.com/46509480/119409198-8bc0d780-bcac-11eb-94f6-4539f209a732.png)

2. run `R_citation_network_Ext.R`

3. Use Gephi to generate the network graph by loading the following files with "Import Spreadsheet".
- nodes table: node_title.csv; 
- edges table: CitationEdges2021-05-22.csv



