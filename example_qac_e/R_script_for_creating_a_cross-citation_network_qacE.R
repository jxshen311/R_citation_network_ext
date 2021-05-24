# RCitation-Ext-Quick Citation Network 
# 2021.5.22
# Jiaxian Shen (jiaxianshen2022@u.northwestern.edu)
# Adapted from the work of A.R. Siders (siders@alumni.stanford.edu) posted on https://www.researchgate.net/publication/327790285_R_script_for_creating_a_cross-citation_network


# Creates a network of the citations among a set of academic papers. 
# Rationale: If full title of Article 2 is present in text of Article 1, Article 1 cites Article 2. (source: Article 2, target: Article 1, arrow points from Article 2 to Article 1)
# NOTE: Will only work in fields where full, unabbreviated titles are used in reference/bibliography citation format. 
# NOTE: Will have high error rate if titles are very short or comprised of common words (e.g., paper "Vulnerability" produced many false positives). Some errors result from authors using a shortened version of a title (e.g., only text before a colon) or incorrect citations or typos. Citation networks produced are therefore approximate and to be used primarily for exploration of the data.
# Use only reference sections of the articles of interest, rather than full texts.

# LOAD PACKAGES ----
library(tm)
library(dplyr)


# FUNCTIONS TO LOAD ---- 
CreateCitationNetwork<-function(papers,titles){
  # prep papers corpus
  papers<-tm_map(papers, content_transformer(tolower))
  papers<-tm_map(papers, removePunctuation)
  papers<-tm_map(papers, removeNumbers)
  papers<-tm_map(papers, stripWhitespace)
  # prep titles 
  titles<-removePunctuation(titles)
  titles<-stripWhitespace(titles)
  titles<-tolower(titles)
  # create citation true/false matrix
  Cites.TF<-CiteMatrix(titles, papers)
  # format matrix into edges file 
  CitationEdges<-EdgesFormat(Cites.TF, titles)
  return(CitationEdges)
}  


# format true/false matrix into edges file
EdgesFormat<-function(Cites.TF, titles){
  #create an empty object to put information in
  edges<-data.frame(matrix(NA, nrow=1, ncol=4))
  colnames(edges)<- c("Source","Target","Weight", "Type")
  for (i in 1:length(Cites.TF)){
    #for each document, run through all titles accross columns
    for (j in 1:ncol(Cites.TF)){
      # for each title, see if document [row] cited that title [column]
      if (Cites.TF[i,j]==TRUE){  #if document is cited
        temp<-data.frame(matrix(NA, nrow=1, ncol=4))
        colnames(temp)<- c("Source","Target","Weight", "Type")
        # first column <- document being cited
        temp[1,1]<-titles[j]
        # second column <- document doing the citing 
        temp[1,2]<-titles[i]
        # third column the yes/no [weight]
        temp[1,3]<-1  
        temp[1,4]<-"Directed"
        edges<-rbind(edges,temp)    
      } 
    }
  }  
  return(edges[-1,]) #-1 removes initial row of null values
}


# Citation true/false matrix 
CiteMatrix<-function(search.vector, Ref.corpus){
  # Creates a csv matrix with True/False for citation patterns 
  citations<-data.frame(matrix(NA, nrow = length(Ref.corpus), ncol=length(search.vector)))
  #Columns are the document being cited
  colnames(citations)<-search.vector
  #Rows are the document doing the citing 
  rownames(citations)<-search.vector
  for (i in 1:length(search.vector)){
    searchi<-search.vector[i]
    papercite<-grepl(searchi, Ref.corpus$content, fixed=TRUE)
    citations[,i]<-papercite
  }
  return(citations)
}


# STEP 1: prepare data and format input ----------
# a. Papers: Folder of papers in txt format (UTF-8) organized *in SAME ORDER* as Titles, containing only the reference section
# b. Titles: Column of paper titles in csv spreadsheet (Column #1) *in SAME ORDER* as documents in Papers folder. Need a header cell or top title will be removed. Could add other columns with attributes.
# Organize Titles using same order.

setwd("<directory where this R script is located>")
# load csv files downloaded from scopus
df_delta_e <- read.csv("scopus_delta_e.csv")[,c(3,15)]
df_e_delta <- read.csv("scopus_e_delta.csv")[,c(3,15)]

# add attributes column
df_delta_e <- mutate(df_delta_e, gene = c("qac_delta_e"))
df_e_delta <- mutate(df_e_delta, gene = c("qac_e_delta"))

df <- rbind(df_delta_e, df_e_delta)

which(duplicated(df$Title))  # check duplication to make sure that Titles are unique

# create a folder of text files containing references 
for (ii in 1:nrow(df)){
  cat(df$References[ii], file = paste("papers/",ii,"_paper.txt"))
}

# prepare node file (.csv)
node_title <- select(df, Title, gene)  #make sure column has a header
colnames(node_title) <- c("ID", "gene") 

node_title$ID<-removePunctuation(node_title$ID)
node_title$ID<-stripWhitespace(node_title$ID)
node_title$ID<-tolower(node_title$ID)

write.csv(node_title, file="node_title.csv", row.names = FALSE) 


# STEP 2: Load inputs ----
# a. Papers 
papers<-Corpus(DirSource("<directory where this R script is located>/papers"))

# b. Titles
titles<-as.vector(node_title[,1])

# check to make sure the lengths of papers and titles are the same
length(papers)
length(titles)

# STEP 3:  Run function ----
CitationNetwork<-CreateCitationNetwork(papers,titles)
# add date
currentDate <- Sys.Date()
csvFileName <- paste("CitationEdges",currentDate,".csv",sep="")
# save results
write.csv(CitationNetwork, file=csvFileName, row.names = FALSE) 

  
# STEP 4. VIisualize network

# Use Gephi or other network visualization software
# Gephi available at https://gephi.org/
# example: nodes table - node_title.csv; edges table - CitationEdges2021-05-22.csv



