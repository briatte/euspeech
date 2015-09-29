
# Download speech acts in the European Parliament, 1999-2014

library(XML)         # parser for HTML web pages
library(jsonlite)    # parser for JSON results
library(plyr)        # data manipulation
library(dplyr)       # fast data manipulation
library(slam)        # simple triplet matrix representation
library(tm)          # document-term matrix representation
library(SnowballC)   # stemmer
library(lda)         # lexicalizer
library(qdap)        # polarity
library(topicmodels) # as it says on the box
library(knitr)       # export Markdown table

sample = FALSE   # number of speeches to sample on every iteration
update = FALSE   # refresh all data objects

msg <- function(...) message(paste(...))

source("data.r")    # get the static (MEP/CRE) datasets
source("scraper.r") # get a large full text sample
source("corpus.r")  # get three huge document-term matrices
source("models.r")  # get topics models at k = 25, 50, 75, 100
source("plots.r") # TODO: plot results and diagnostics

# have a nice day
