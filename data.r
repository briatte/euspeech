dir.create("data"  , showWarnings = FALSE)

meps = "meps.csv"
if(!file.exists(meps) | update) {
  
  html = "http://www.europarl.europa.eu/meps/en/directory.html?filter=all&leg="
  html = htmlParse(html, encoding = "UTF-8")
  
  # index page
  root = function(x) paste0("//div[@class='zone_info_mep']/div[@class='mep_details']/ul/li", x)
  link = xpathSApply(html, root("[@class='mep_name']/a/@href"))
  
  name = xpathSApply(html, root("[@class='mep_name']"))
  name = sapply(name, xmlValue)
  
  #   # MEPs currently in power (different page, ongoing legislature only)
  #   natl = xpathSApply(html, root("[contains(@class, 'nationality')]/@class"))
  #   natl = gsub("nationality ", "", natl)
  #   group = xpathSApply(html, root("[contains(@class, 'group')]/@class"))
  #   group = gsub("group ", "", group)
  #   party = xpathSApply(html, root("[contains(@class, 'nationality')]/span"))
  #   party = sapply(party, xmlValue)
  #   party = gsub("\\\"", "", party)
  
  #   # add memberships from individual MEP pages (ongoing legislature only)
  #   member = sapply(link, function(x) {
  #     print(x)
  #     html = htmlParse(paste0("http://www.europarl.europa.eu/", x))
  #     root = "//ul[@class='events_collection']"
  #     html = sapply(xpathSApply(html, paste0(root, "/*/acronym | ", root, "/*/*/acronym")), xmlValue)
  #     return(paste0(html, collapse = ";"))
  #   })
  
  write.csv(data.frame(link, name), meps) # , natl, party, group, member
  
}

meps = read.csv(meps, stringsAsFactors = FALSE)[, -1]

get_cre <- function(id, leg = 7, verbose = TRUE) {

  if(verbose)
    cat("\nFinding speeches in legislature", leg)

  rec = data.frame()
  idx = 0

  while(idx > -1) {

    if(verbose)
      cat(" ", idx, "...")

    x = paste0("http://www.europarl.europa.eu/meps/en/", id,
               "/see_more.html?type=CRE&leg=", leg, "&index=", idx)

    x = try(fromJSON(readLines(x, warn = FALSE), flatten = TRUE))

    if("try-error" %in% class(x)) {

      warning("Scraper error: MEP ", id)

    } else {

      idx = x$nextIndex

      if(class(x$documentList) == "data.frame")
        rec = rbind(rec, cbind(leg, x$documentList))

      if(!idx)
        idx = -1

    }

  }

  return(rec)

}

chain <- function(x) return(ifelse(length(x) < 1, NA, paste0(x, collapse = ";")))

# alternative to the qdap function (if need to coerce to ASCII first)
# scrubber <- function(x) gsub("\\\"|^\\s+|\\s+$", "", iconv(gsub("\\t|\\n|\\r", "", x), to = "ASCII//TRANSLIT"))

for(i in meps$link) {
  
  j = gsub("/meps/en/(\\d+)(.*)", "\\1", i)
  
  file = paste0("data/", j, "_nfo.csv")
  
  if(!file.exists(file) | update) {
    
    html = htmlParse(paste0("http://www.europarl.europa.eu/", gsub("home", "history", i)), encoding = "UTF-8")
    group = sapply(xpathApply(html, "//*/li[contains(@class, 'group')]"), xmlValue)
    group = scrubber(group)
    info = sapply(xpathSApply(html, "//ul[contains(@class, 'events_collection')]/li"), xmlValue)
    info = scrubber(info)
    
    if(nchar(group) > 0) {
      
      cat("\nParsing new MEP:", i, "\n")
      info = gsub("(\\w|-)+(Delegation|Committee|Subcommittee) (.*)", "\\2 \\3", info)
      started = ended = NA
      
    } else {
      
      cat("\nParsing old MEP:", i, "\n")
      started = substr(info, 1, 10)
      ended = substr(info, 14, 23)
      info = gsub("\\s+-\\s+Member\\s*$", "", substring(info, 25))
      group = info[1]
      info = info[-1]
      
    }
    
    # bind and drop national party affiliations on the way
    info = data.frame(org = c(group, info), started, ended, stringsAsFactors = FALSE)
    info = rbind(info[1, ], subset(info, grepl("Delegation|Committee|Subcommittee", org)))
    
    info$type = "group"
    info$type[ grepl("Delegation", info$org) ] = "delegation"
    info$type[ grepl("Committee", info$org) ] = "committee"
    info$type[ grepl("Subcommittee", info$org) ] = "subcommittee"
    
    write.csv(data.frame(id = j, info[, c(4, 1, 2:3) ]), file)
    
    file = paste0("data/", j, "_cre.csv")
    
    if(!file.exists(file) & update) {
      
      record = lapply(1:7, function(y) get_cre(j, y))
      record = rbind.fill(record)
      
      if(length(record) > 0) {
        
        record = data.frame(id = j, record)
        record$formatList = sapply(record$formatList, chain)
        record$committeeList = sapply(record$committeeList, chain)
        record$voteExplanationList = sapply(record$voteExplanationList, chain)
        record = lapply(record, unlist)
        
        write.csv(record, file)
        cat(" done: ", nrow(record), "speeches.\n")
        
      } else {
        
        cat(" done (empty, no file written).\n")
        
      }
      
    }
    
  }
  
}

# merge raw files
build <- function(x) {
  x = dir("data", pattern = paste0("_", x, ".csv"))
  x = lapply(paste0("data/", x), read.csv, stringsAsFactors = FALSE)
  return(rbind.fill(x)[, -1])
}

# msg("Postprocessing MEPs data...")

if(!file.exists("nfo.csv") | update) {
  nfo = build("nfo")
  write.csv(nfo, file = "nfo.csv", row.names = FALSE)
}

nfo = read.csv("nfo.csv", stringsAsFactors = FALSE)

# party groups

x = unique(nfo[ nfo$type == "group", c("id", "org") ])
x$org = gsub(" -( )?(Chair|Treasurer|Vice-Chair|Member of the Bureau)?", "", x$org)

y = rep(NA, nrow(x))

# far left
y[ grepl("Communist and Allies|Left Unity|European United Left|Nordic Green Left", x$org) ] = "Left.COM,LU,EUL/NGL"
# Greens/regionalists
y[ grepl("Rainbow|Greens/European Free Alliance", x$org) ] = "Green.RBW,G/EFA"
# short-lived
y[ grepl("Green Group", x$org) ] = "Green"
# socialists
y[ grepl("Socialist", x$org) ] = "Soc-dem."
# radicals
y[ grepl("European Radical Alliance", x$org) ] = "Radic."
# Lib-Dems
y[ grepl("Liberal and Democratic|Liberals|Democrat and Reform", x$org) ] = "Lib-dem.ELDR,ALDE"
# conservatives: EPP family
y[ grepl("Christian(.*)Democrat", x$org) ] = "Christ-dem.EPP"
# more conservatives
y[ grepl("European (Conservative|Democratic) Group|Conservatives and Reformists", x$org) ] = "Conserv."
# euroskeptics
y[ grepl("(Independents for a )?Europe of Nations|Democracies and Diversities|Independence/Democracy|Europe of freedom and democracy", x$org) ] = "Euroskep.EoN,I/D,EfD"
# national-conservatives
y[ grepl("Democratic Union Group|Union for Europe( of the Nations)?|Progressive Democrats|Forza Europa|European Democratic Alliance", x$org) ] = "Natl-conserv.UDE,EPD,UFE,EDA,UEN"
# French extreme right and Italian neofascists
y[ grepl("Identity, Tradition and Sovereignty Group|European Right", x$org) ] = "Extr-Right.ER,ITS"
# # residuals
y[ grepl("Ind(e|i)pendent (Group|Member)|Non-attached", x$org) ] = "Indep."

# large families
y[ grepl("^Left", y) ] = "Far-left"
y[ grepl("^Green", y) ] = "Greens"
y[ grepl("^Soc", y) ] = "Socialists"
y[ grepl("^Lib|^Rad", y) ] = "Centrists"
y[ grepl("^Conserv|^Eurosk", y) ] = "Euroskeptics" # merged conservatives
y[ grepl("^Christ", y) ] = "Christian-Democrats" #
y[ grepl("^Extr|^Natl", y) ] = "Extreme-right" # merged natl-conservatives from legislatures 5-6
y[ grepl("^Indep", y) ] = "Independents"

# debug here
if(any(is.na(y)))
  print(table(y, exclude = NULL))
x$org = factor(y, levels = c("Far-left", "Greens", "Socialists", "Centrists", "Christian-Democrats", "Euroskeptics", "Extreme-right", "Independents"))

# add party to MP name and link
meps$id = as.integer(gsub("/meps/en/(\\d+)(.*)", "\\1", meps$link))
meps = left_join(meps, x, by = "id")
names(meps)[ names(meps) == "org" ] = "group"

if(!file.exists("cre.csv") | update) {
  speeches = build("cre")
  write.csv(speeches, file = "cre.csv", row.names = FALSE)
}

# kthxbye
