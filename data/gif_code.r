

library(ggplot2)
library(dplyr)
library(animation)

setwd('C:/Users/garre/Dropbox/aa projects/choootooo/hex_sim/data/5.6.16')
df <- read.csv('hexsim_2016-05-08.csv')
if(!dir.exists("gifs")) {dir.create("gifs")}
setwd("gifs")

n_table <- with(df, tapply(pid, cond, FUN = function(x) length(unique(x))))

saveGIF({

 for (i in 1:59) {
    #title
    plot_title <- paste0('Taxonomic Responding on Trial: ', as.character(i))
    #data
    trial_data <- filter(df, trial < i + 1)
    trial_data <- aggregate(tax_sel ~ cond + pid, mean, data = trial_data)
    trial_data$binom_diff <- # diff from chance
      unlist(lapply(trial_data$tax_sel, function(x) {binom.test((x * i), i, .5)$p.value}))
    trial_data$binom_diff[trial_data$binom_diff < .0001] <- .0001
    trial_data$sig <- ifelse(trial_data$binom_diff < .05, 1, 2)


    cond_plot <- ggplot(trial_data, aes(x = as.factor(cond), y = tax_sel)) +
      geom_boxplot(outlier.shape = NA) +
      geom_point(position = position_jitter(width = .3, height = 0), aes(color = sig)) +
      stat_summary(fun.y = mean, geom = 'point', shape = 18, color = 'black', 
        size = 4, show.legend = FALSE) + ggtitle(plot_title) +
      theme(plot.title = element_text(size=26, vjust=2),
        axis.title.y = element_text(size=22, margin = margin(0,10,0,0)),
        axis.text.y = element_text(size=18, color = 'black'),
        axis.title.x = element_text(size=22, margin = margin(10,0,0,0)),
        axis.text.x = element_text(size = 18, color = 'black'), 
        legend.position = "none") + 
      scale_y_continuous(limits=c(0,1.001), breaks=seq(0, 1, 0.1), 
        name = 'Proportion Taxonomic') + 
      scale_x_discrete(name = 'Condition', 
        limits = c('sextet_base','sextet_rand',
          'triad_base','triad_rand', 'triad_goes'), 
        labels = c('Base\n5 Targets', 'No Base\n6 Targets',
          'Base\n2 Targets', 'No Base\n3 Targets', 'Goes\nWith')) + 
      coord_cartesian(ylim = c(0,1))

    print(cond_plot)
  }
}, movie.name = 'hex_sim_data_box.gif', interval = .3, ani.width = 700, ani.height = 600)


