msg("\nEstimating topic models...")

# library(slam)        # simple triplet matrix representation
library(tm)          # document term matrix representation
library(topicmodels)

verbose = TRUE
SEED = 9790

get_TM <- function(file) {
  
  load(paste0(file, ".rda"))
  print(DTM)
  
  for(k in c(25, 50, 75, 100)) { # number of topics to model
    
    cat("\nEstimating at k =", k, "\n\n")
    
    TM =
      list(
        VEM = LDA(DTM, k = k, control = list(seed = SEED, verbose = verbose)),
        VEM_fixed = LDA(DTM, k = k,
                        control = list(estimate.alpha = FALSE, seed = SEED, verbose = verbose)),
        Gibbs = LDA(DTM, k = k, method = "Gibbs",
                    control = list(seed = SEED, burnin = 1000, verbose = verbose,
                                   thin = 100, iter = 1000))
      )
    
    ## compare estimated and fixed VEM
    sapply(TM[1:2], slot, "alpha")
    
    ## mean entropy for each fitted model
    Entropy = sapply(TM, function(x)
      mean(apply(posterior(x)$topics,
                 1, function(z) - sum(z * log(z)))))
    # Entropy
    
    ## most likely topic for each document
    Topic = topics(TM[["VEM"]], 1)
    # table(Topic)[order(table(Topic), decreasing = TRUE)]
    
    ## 100 most frequent terms in each topic
    Terms = terms(TM[["VEM"]], 100)
    # Terms[, table(Topic) >= quantile(table(Topic), probs = .75)]
    
    save(TM, Entropy, Topic, Terms, SEED, k,
         file = paste0("tm", gsub("dtm", "", file), k, ".rda"))
    
  }
  
}

get_TM("dtm")      # full corpus
get_TM("dtm-proc") # procedure-specific corpus
get_TM("dtm-deba") # other debates corpus

# kthxbye
