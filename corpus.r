msg("\nWriting out corpus...")

# MEP names as stopwords

sw = tolower(unlist(strsplit(meps$name, " ")))
sw = unique(sw[ !grepl("\\.|\\(|\\)", sw) ])
sw = sw[ nchar(sw) > 3 ]

# corpus

get_DTM <- function(D, file) {
  
  if(!file.exists(file)) {
    
    D = Corpus(VectorSource(D, encoding = "UTF-8"))
    
    D = tm_map(D, tolower)
    D = tm_map(D, removeWords, stopwords("en"))
    D = tm_map(D, removePunctuation)
    D = tm_map(D, removeNumbers)
    
    # # polarity
    # 
    # q = which(with(speeches, corpus & !is.nan(polarity) & is.na(polarity)))
    # 
    # if(length(q)) {
    #   
    #   msg("Appending", length(q), "polarity estimates...")
    # 
    #   for(j in q)
    #     speeches$polarity[ j ] = polarity(D[ j ], polarity.frame = polarity_frame(afinn_pos, afinn_neg))$all$polarity
    #   
    #   write.csv(speeches, "speeches.csv", row.names = FALSE)
    # 
    # }
    
    # document-term matrix
    
    DTM = DocumentTermMatrix(D, control = list(stemming = TRUE, stopwords = sw, minWordLength = 4))
    
    dim(DTM) # first dimension is number of docs
    
    msg("\nDensity of initial corpus:")
    print(summary(col_sums(DTM)))
    
    # mean term frequency-inverse document frequency (tf-idf)
    
    term_tfidf =
      tapply(DTM$v/row_sums(DTM)[DTM$i], DTM$j, mean) *
      log2(nDocs(DTM) / col_sums(DTM > 0))
    
    # slightly above median to trim to most frequent words (Grün and Hornik 2011)
    msg("\nSummary of tf-idf (trimming at .13):")
    print(summary(term_tfidf))
    
    DTM = DTM[, term_tfidf >= .13 ] # value set after inspecting ~ 14,000 documents
    DTM = DTM[ row_sums(DTM) > 0, ]
    
    msg("\nDensity of reduced corpus:")
    print(summary(col_sums(DTM)))
    
    msg("\nPostprocessed matrix:")
    print(DTM) # document-term matrix with a reduced vocabulary
    
    # extract vocabulary
    
    D = lexicalize(D, vocab = Terms(DTM))
    
    # master copy

    if(file == "dtm.rda") {
      
      speeches$subj = gsub("^(\\.|\\s)+(.*)", "\\2", speeches$subj)
      speeches$subj = gsub("dot", ".", gsub("[[:punct:]]", "", gsub("\\.","dot", speeches$subj)))
      
      speeches$date = as.Date(speeches$date, "%d-%m-%Y")
      speeches$lang = substr(speeches$lang, 1, 2)
      
      speeches = speeches[, c("id", "leg", "date", "lang", "corpus", "title", "proc", "subj", "also", "oeil", "titleUrl", "referenceList", "text") ]
      
      # subject labels
      
      subjects = na.omit(unlist(strsplit(speeches$subj, " ")))
      subjects = as.data.frame(table(subjects))
      names(subjects) = c("code", "n")
      
      labels = read.csv("subjects.csv", stringsAsFactors = FALSE)
      subjects = merge(labels, subjects, by = "code", all = TRUE)
      subjects = subjects[ order(sort(subjects$code)), ]
      
      save(meps, speeches, subjects, D, DTM, term_tfidf, file = file)
      
      head(subjects)
      
      subj = na.omit(unlist(strsplit(speeches$subj, " ")))
      
      h0 = as.data.frame(table(subj))
      names(h0) = c("code", "n")
      
      h0 = merge(subjects[, c("code", "label") ], h0, by = "code", all.x = TRUE)
      h0[ order(h0$code), ]
      
      # add total counts
      h1 = gsub("^(\\d+)\\.(.*)", "\\1", subj)
      h0[ h0$code %in% as.character(1:8), "n" ] = table(h1)
      
      # cosmetics
      h0$label[ h0$label == "WTF?" ] = NA
      h0$label[ h0$code %in% 1:8 ] = toupper(h0$label[ h0$code %in% 1:8 ])
      
      # subjects
      head(h0)
      write(kable(h0[ !is.na(h0$n), ], output = FALSE, row.names = FALSE), file = "subjects.md")
      
      # subthemes
      h2 = as.data.frame(table(gsub("^(\\d+)\\.(\\d+)\\.(.*)", "\\1.\\2", subj)))
      names(h2) = c("code", "n")
      
      h2 = merge(subjects[, c("code", "label") ], h2, by = "code")
      h2 = rbind(h0[ h0$code %in% as.character(1:8), ], h2[ h2$label != "WTF?", ])
      
      write(kable(h2[ order(h2$code), ], output = FALSE, row.names = FALSE), file = "subthemes.md")
      
    } else {
      
      save(D, DTM, term_tfidf, file = file)

    }
    
  }
  
}

# master document-term matrix
get_DTM(with(speeches, text[ grepl("^en", lang) ]), "dtm.rda")

# corpus with procedure subject codes
get_DTM(with(speeches, text[ grepl("^en", lang) & proc != "Debates" ]), "dtm-proc.rda")

# corpus from unclassified debates
get_DTM(with(speeches, text[ grepl("^en", lang) & proc == "Debates" ]), "dtm-deba.rda")

# kthxbye
