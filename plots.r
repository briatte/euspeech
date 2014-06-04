library(ggplot2)

load('dtm.rda')
load('dtm-proc.rda')

for(k in c(25, 30, 40)) {
  
  plot = paste0("plots/heatmap-proc", k, ".pdf")
  if(!file.exists(plot)) {
    
    load(paste0("models/tm-proc", k, ".rda"))
    
    s = with(speeches, subj[ grepl("^en", lang) & proc != "Debates" ])
    s = s[ as.numeric(Docs(DTM)) ]
    
    r = lapply(subjects$code, function(x) {
      t = table(Topic[ grepl(x, s) ])
      if(length(t))
        data.frame(x, t, stringsAsFactors = FALSE)
    })
    r = rbind.fill(r)
    names(r) = c("code", "topic", "n")
    
    t = subset(r, grepl("\\.\\d+\\.", code))
    size = tapply(t$n, t$code, sum)
    
    t = t[ t$code %in% names(size)[ size > 100 ], ]
    t$totl = size[ t$code ]
    t$frac = t$n / t$totl
    t$perc = cut(t$frac, 0:10/10, include.lowest = TRUE)
    t$h1 = gsub("(\\d)\\.(.*)", "\\1", t$code)
    
    g = qplot(data = t[ t$frac > quantile(t$frac, .75), ],
              y = sort(code), x = topic, alpha = frac,
              color = I("white"),
              size = totl, geom = "jitter") +
      scale_alpha_continuous("P") +
      scale_size_area("N", max_size = 9) +
      facet_grid(h1 ~ ., scales = "free_y") +
      guides(alpha = guide_legend(override.aes = list(size = 6))) +
      labs(y = "Subject\n", x = "\nTopic") +
      theme_linedraw(16) +
      theme(panel.background = element_rect(fill = "grey30"),
            strip.background = element_rect(fill = "grey30"),
            legend.key = element_rect(fill = "grey30"),
            strip.text = element_text(color = "white"),
            axis.text.y = element_blank(),
            panel.grid = element_blank(),
            axis.ticks.y = element_blank())
    
    ggsave(plot, g, width = 9, height = 12)
    
    data = speeches[ speeches$corpus & speeches$proc != "Debates", ]
    data = data[ as.numeric(Docs(DTM)), ]
    data = left_join(data, meps, by = "id")
    data$topic = Topic
    data$yr = substr(data$date, 1, 4)
   
    eup = c(
      "Far-left" = "#E41A1C",
      "Greens" = "#4DAF4A",
      "Socialists" = "#F781BF",
      "Centrists" = "#FF7F00",
      "Christian-Democrats" = "#377EB8",
      "Euroskeptics" = "#984EA3",
      "Extreme-right" = "#A65628",
      "Independents" = "#999999")
    
    g = qplot(data = summarise(group_by(data, yr, group, topic), n = n()),
          group = topic, x = yr, y = n, color = group, fill = group,
          alpha = I(1/2), position = "stack", geom = "area") +
      scale_color_manual("", values = eup, breaks = names(eup)) +
      scale_fill_manual("", values = eup, breaks = names(eup)) +
      scale_x_discrete(breaks = c(2004, 2009, 2014)) +
      facet_wrap(~ group) +
      labs(y = "N\n", x = NULL) +
      theme(legend.justification=c(1,0), legend.position=c(1,0))
    
    ggsave(gsub("heatmap", "counts", plot), g, width = 9, height = 9)
    
  }
}

