#' Find JRC named entities in EU speeches
#' 
#' @references http://viksalgorithms.blogspot.fr/2012/06/tracking-us-sentiments-over-time-in.html
#' @source http://ipsc.jrc.ec.europa.eu/index.php?id=42
for(ii in 1:100) {

  if(file.exists("mentions.rda"))
    
    load("mentions.rda")
  
  else {
    
    load('dtm.rda')
    corpus = subset(speeches, proc != "Debates")
    
    url = "http://optima.jrc.it/entities.gzip"
    file = "jrc-list.txt"
    zip = "jrc-list.gzip"
    
    if(!file.exists(file)) {
      
      if(!file.exists(zip)) download(url, zip, mode = "wb")
      raw = readLines(gzfile(zip))
      write(raw, file)
      
    }
    
    jrc = read.delim(file, stringsAsFactors = FALSE)
    jrc = jrc[ jrc$u == "u" & jrc$O %in% c("O", "P"), ]
    jrc = jrc[ -grep("[^\\w+]", jrc$IGNORE, perl = TRUE), ]
    
    jrc$full = gsub("+", " ", jrc$IGNORE, fixed = TRUE)
    jrc$last = sapply(jrc$IGNORE, function(x) rev(unlist(strsplit(x, "+", fixed = TRUE)))[[1]])
    
    uu = unique(jrc[, c("X0", "last")])
    uu = unique(uu[ which(duplicated(uu$last)), "last" ])
    jrc$last[ jrc$O == "O" | jrc$last %in% uu ] = NA # discard homonyms from family names
    
    nrow(jrc[ !is.na(jrc$last), ]) # number of unique family names
    nrow(jrc[ !is.na(jrc$last), ]) / nrow(jrc[ jrc$O == "P", ])  # percentage of unique family names

    mentions = data.frame(entity = na.omit(unique(jrc$X0)), name = NA, n_mentions = NA, n_speakers = NA)

  }
  
  sample = 100
  j = sample
  
  t = Sys.time()
  for(i in sample(unique(mentions$entity[ is.na(mentions$n_mentions) ]), sample)) {
    
    j = j - 1
    u = na.omit(c(jrc$full[ jrc$X0 == i ], jrc$last[ jrc$X0 == i ]))

    cat(j, ":", u[1], ":", length(u), "variant(s)")
    mentions[ mentions$entity == i, "name" ] = u[1]

    mentioned = grepl(paste0(u, collapse = "|"), corpus$text)

    cat(" ... ", sum(mentioned), "mention(s)\n")
    mentions[ mentions$entity == i, "n_mentions" ] = sum(mentioned)
    mentions[ mentions$entity == i, "n_speakers" ] = length(unique(subset(corpus, mentioned)$id))

  }

  print(Sys.time() - t)
  print(mentions[ !is.na(mentions$n_mentions) & mentions$n_mentions > 0, ])
  
  save(corpus, jrc, mentions, file = "mentions.rda")
  
}

# kthxbye
