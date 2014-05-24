# MEP names as stopwords

sw = tolower(unlist(strsplit(meps$name, " ")))
sw = unique(sw[ !grepl("\\.|\\(|\\)", sw) ])
sw = sw[ nchar(sw) > 3 ]

# corpus

D = with(speeches, text[ grepl("^en", lang) ])
D = Corpus(VectorSource(D, encoding = "UTF-8"))

D = tm_map(D, tolower)
D = tm_map(D, removeWords, stopwords("en"))
D = tm_map(D, removePunctuation)
D = tm_map(D, removeNumbers)

# polarity

q = which(with(speeches, corpus & !is.nan(polarity) & is.na(polarity)))

if(length(q)) {
  
  msg("Appending", length(q), "polarity estimates...")

  for(j in q)
    speeches$polarity[ j ] = polarity(D[ j ], polarity.frame = polarity_frame(afinn_pos, afinn_neg))$all$polarity
  
  write.csv(speeches, "speeches.csv", row.names = FALSE)

}

# document-term matrix

D = DocumentTermMatrix(D, control = list(stemming = TRUE, stopwords = sw, minWordLength = 4))

dim(D) # first dimension is number of docs
print(summary(col_sums(D)))

# mean term frequency-inverse document frequency (tf-idf)

term_tfidf =
  tapply(D$v/row_sums(D)[D$i], D$j, mean) *
  log2(nDocs(D) / col_sums(D > 0))

summary(term_tfidf) # use median to trim most frequent words

D = D[, term_tfidf >= 0.1 ]
D = D[ row_sums(D) > 0, ]

summary(col_sums(D))
print(D) # document-term matrix with a reduced vocabulary

# finalize

speeches$subj = gsub("^(\\.|\\s)+(.*)", "\\2", speeches$subj)
speeches$subj = gsub("dot", ".", gsub("[[:punct:]]", "", gsub("\\.","dot", speeches$subj)))

speeches$date = as.Date(speeches$date, "%d-%m-%Y")
speeches$lang = substr(speeches$lang, 1, 2)

speeches = speeches[, c("id", "leg", "date", "lang", "corpus", "title", "proc", "subj", "also", "oeil", "polarity", "titleUrl", "referenceList", "text") ]

# subject labels

subjects = na.omit(unlist(strsplit(speeches$subj, " ")))
subjects = as.data.frame(table(subjects))
names(subjects) = c("code", "n")

labels = read.csv("subjects.csv", stringsAsFactors = FALSE)
subjects = merge(labels, subjects, by = "code")
subjects = subjects[ order(sort(subjects$code)), ]

save(D, speeches, meps, subjects, file = "dtm.rda")

# kthxbye
