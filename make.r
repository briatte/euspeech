
# Download speech acts in the European Parliament, 1999-2014
setwd("~/Documents/Code/R/euspeech")

library(XML)       # parser for HTML web pages
library(jsonlite)  # parser for JSON results
library(plyr)      # data manipulation
library(dplyr)     # fast data manipulation
library(slam)      # simple triplet matrix representation
library(tm)        # document-term matrix representation
library(SnowballC) # stemmer
library(qdap)      # polarity

sample = 5       # number of speeches to sample on every iteration
update = FALSE   # refresh all data objects

msg <- function(...) message(paste(...))

for(ii in 1:2) try(source("data.r"))    # get the static (MEP/CRE) datasets
for(ii in 1:2) try(source("scraper.r")) # get a large full text sample
source("corpus.r")                      # get a huge document-term matrix
source("entities.r")                    # find JRC entities in the corpus

# have a nice day
