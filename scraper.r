# this loop scrapes speeches with between a half-second sleep before each GET; 
# there's around 270,000 speeches, so you will need several days to run it in
# full (the loop can be run by small chunks to also try fixing parser errors).

if(!file.exists("speeches.csv")) {

  msg("\nInitializing main dataset...")
  speeches = read.csv("cre.csv", stringsAsFactors = FALSE)
  
  speeches$lang = NA # language
  speeches$text = NA # full text
  speeches$proc = NA # procedure code
  speeches$subj = NA # subjects
  speeches$also = NA # related procedures
  speeches$oeil = NA # official selection
  speeches$polarity = NA # polarity

  } else {

  msg("\nPre-loading main dataset...")
  speeches = read.csv("speeches.csv", stringsAsFactors = FALSE)

}

msg("Missing:", sum(is.na(speeches$text)), "full text items,",
    round(100 * sum(is.na(speeches$text)) / nrow(speeches), 1), "% of total")

j = unique(speeches$titleUrl[ is.na(speeches$text) ])
z = 60 # sleep time for occasional HTTP errors (secs)

# AFINN

file = "afinn-list.txt"
if(!file.exists(file)) {

  zip = "afinn-list.zip"

  if(!file.exists(zip))
    download("http://www2.imm.dtu.dk/pubdb/views/edoc_download.php/6010/zip/imm6010.zip", zip, mode = "wb")
  
  raw = readLines(unz(zip, "AFINN/AFINN-111.txt"))
  write(raw, file)

}

afinn = read.delim(file, header = FALSE, stringsAsFactors = FALSE)
names(afinn) = c("word", "score")

afinn$word = tolower(afinn$word)
afinn_pos = with(afinn, word[ score >  1 ])
afinn_neg = with(afinn, word[ score < -1 ])

timer = Sys.time()
for(i in sample(j, ifelse(is.numeric(sample), sample, length(j)))) {
  
  if(any(is.na(speeches$text[ speeches$titleUrl == i ]))) {
    
    h = try(htmlParse(i, encoding = "UTF-8"))
    
    if("try-error" %in% class(h)) {
      
      warning("Scraper error (speech):\n", i)
      Sys.sleep(z)
      
    } else {
      
      l = as.character(xpathApply(h, "//li[contains(@class, 'selected')]/@title"))
      
      t = sapply(xpathSApply(h, "//p[@class='contents']"), xmlValue)
      t = paste0(t, collapse = " ")
      t = gsub("\\s+", " ", t)
      t = gsub("^\\s+|\\s+$", "", t)
      
      p = as.character(xpathApply(h, "//a[contains(@href, 'ficheprocedure')]/@href"))
      if(!length(p)) {        

        p = "Debates"
        p1 = NA
        p2 = NA
        p3 = NA

        } else {
        
          q = try(htmlParse(paste0("http://www.europarl.europa.eu/", p[1]), encoding = "UTF-8"))
          
          if("try-error" %in% class(q)) {
            
            warning("Scraper error (procedure):\n", i)
            Sys.sleep(z)
            
          } else {
            
            p = gsub("(.*)reference=(.*)", "\\2", p[1])
            
            p1 = sapply(xpathSApply(q, "//p[@class='basic_content']"), xmlValue)
            p1 = scrubber(gsub("[[:alpha:]]|,", "", p1))
            p1 = unlist(strsplit(p1, " "))
            p1 = paste0(p1[ grepl("\\.", p1) ], collapse = " ")
            
            p2 = xpathSApply(q, "//p[@class='basic_content']/a[contains(@href, 'ficheprocedure')]/@href")
            p2 = paste0(gsub("(.*)reference=(.*)", "\\2", p2), collapse = " ")
            if(p2 == "") p2 = NA
            
            p3 = xpathSApply(q, "//p[@class='basic_content']/a[contains(@href, 'thematicnote')]")
            p3 = paste0(scrubber(sapply(p3, xmlValue)), collapse = ";")
            if(p3 == "") p3 = NA
            
          }
                    
        }

      speeches$proc[ speeches$titleUrl == i ] = p
      speeches$subj[ speeches$titleUrl == i ] = ifelse(is.null(p1), NA, p1)
      speeches$also[ speeches$titleUrl == i ] = ifelse(is.null(p2), NA, p2)
      speeches$oeil[ speeches$titleUrl == i ] = ifelse(is.null(p3), NA, p3)
      
      speeches$lang[ speeches$titleUrl == i ] = l[1]
      speeches$text[ speeches$titleUrl == i ] = t
      
      n = nrow(speeches) - sum(!is.na(speeches$text))

      if(!n %% 100)
        cat(sum(!is.na(speeches$proc)), "completed,", n, "items left...\n")
      
    }
    
  }
  
}
timer = difftime(Sys.time(), timer)

# mark sample rows

q = speeches$id %in% unique(meps$id)
if(sum(q) != nrow(speeches))
  msg("Sampled:", sum(q), "items",
      round(100 * sum(q) / nrow(speeches), 1), "% of total")

speeches$sample = q

msg("Found:", nrow(speeches[ speeches$sample, ]), "items from",
    n_distinct(speeches$referenceList), "debates")

speeches$corpus = with(speeches, !is.na(text) & grepl("^en", lang))

msg("Found:", sum(speeches$corpus), "items in English",
    round(100 * sum(speeches$corpus) / sum(!is.na(speeches$text)), 1), "% of",
    sum(!is.na(speeches$text)), "scraped items")

msg("Timer:", round(timer, 2), units(timer), "for", sample, "items")

q = meps$id %in% unique(speeches$id)
if(sum(q) != nrow(meps))
  msg("Sample:", sum(q), "MEPs",
      round(100 * sum(q) / nrow(meps), 1), "% of total")

meps$sample = q

msg("Total MEPs in sample:", n_distinct(speeches[ speeches$corpus, "id" ]))
rownames(meps) = meps$id
print(table(meps[ unique(as.character(speeches[ speeches$corpus, "id" ])), "group" ]))

write.csv(speeches, "speeches.csv", row.names = FALSE)

# kthxbye
