# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # Hex_Sim Analysis  # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # packages 
library(ggplot2)
library(dplyr)

# # # dir for raw data CSVs
setwd('C:/Users/garre/Dropbox/aa projects/choootooo/hex_sim/data/5.6.16')

# # # raw data processing
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # combine all files
file_name <- 'hexsim_messy.csv'
shell(paste0('del ', file_name), wait = TRUE)
for(file in grep('hexsim_2016', dir())){shell(paste0('del ', dir()[[file]]), 
  wait = TRUE)}
copy_command <- paste0('copy *.csv ', file_name)
shell(copy_command, wait = TRUE)

# # # load/clean messy data
df <- read.csv(file_name, header = FALSE, stringsAsFactors = FALSE)
# # # set PID as int
df$V1 <- as.integer(df$V1)
# # # clean all non-participant data rows
df <- subset(df, subset = ((V1 > 4000) & (is.na(df$V3) != TRUE)))[,1:14]
df <- subset(df, !is.na(V14))
# # # set column names
colnames(df) <- c('pid', 'cond', 'trial', 'base', 'tax', 'the', 'unr1', 'unr2',
  'unr3', 'sel1', 'sel2', 'seltype1', 'seltype2', 'rt')

# # # create response selection vars
df$base[which(df$tax == 'BUFFALO')] <- 'COW_2'
# selections of interest
df$tax_sel <- ifelse(df$seltype1 == 'BASE' & df$seltype2 == 'TAXONOMIC', 1,  
  ifelse(df$seltype1 == 'TAXONOMIC' & df$seltype2 == 'BASE', 1, 0))
df$the_sel <- ifelse(df$seltype1 == 'BASE' & df$seltype2 == 'THEMATIC', 1,  
  ifelse(df$seltype1 == 'THEMATIC' & df$seltype2 == 'BASE', 1, 0))
# tax and them target selection
df$tax_the_sel <- ifelse(df$seltype1 == 'TAXONOMIC' & df$seltype2 == 'THEMATIC', 1,  
  ifelse(df$seltype1 == 'THEMATIC' & df$seltype2 == 'TAXONOMIC', 1, 0))
# different types of unrelated selections
df$unr_tax_sel <- ifelse(df$seltype1 == 'TAXONOMIC' & df$seltype2 == 'UNRELATED', 1,  
  ifelse(df$seltype1 == 'UNRELATED' & df$seltype2 == 'TAXONOMIC', 1, 0))
df$unr_the_sel <- ifelse(df$seltype1 == 'THEMATIC' & df$seltype2 == 'UNRELATED', 1,  
  ifelse(df$seltype1 == 'UNRELATED' & df$seltype2 == 'THEMATIC', 1, 0))
df$unr_bas_sel <- ifelse(df$seltype1 == 'BASE' & df$seltype2 == 'UNRELATED', 1,  
  ifelse(df$seltype1 == 'UNRELATED' & df$seltype2 == 'BASE', 1, 0))
df$unr_unr_sel <- ifelse(df$seltype1 == 'UNRELATED' & df$seltype2 == 'UNRELATED', 1,  
  ifelse(df$seltype1 == 'UNRELATED' & df$seltype2 == 'UNRELATED', 1, 0))
df$unr_sel <- df$unr_tax_sel + df$unr_the_sel + df$unr_bas_sel + df$unr_unr_sel

# selection factor
df$trial_sel <- ifelse(df$tax_sel == 1, 'tax', 
                  ifelse(df$the_sel == 1, 'the', 
                    ifelse(df$unr_sel == 1, 'unr', 'otr')))

# condition factors
has_base <- rep('no_base', nrow(df)); has_base[grep('base', df$cond)]   <- 'base'
has_dist <- rep('no_dist', nrow(df)); has_dist[grep('sextet', df$cond)] <- 'dist'
has_sim  <- ifelse(df$cond == 'triad_goes', 'no_sim', 'sim')

df <- cbind(df, 
  has_base = factor(has_base, levels = c('no_base', 'base')), 
  has_dist = factor(has_dist, levels = c('no_dist', 'dist')), 
  has_sim = factor(has_sim, levels = c('no_sim', 'sim')))

# # # get native language data, split them out if you wish
#exclude_non_native <- TRUE
exclude_non_native <- FALSE

lang_data_path <- 'C://Users//garre//Dropbox//aa projects//choootooo//hex_sim//data'
lang_data <- read.csv(paste0(lang_data_path, '//exit_survs_hexsim.csv'))
df <- left_join(df, lang_data[,c(1,6)], by = 'pid')
if(exclude_non_native == TRUE) {df <- subset(df, native_eng == 'yes')}

# # # clean up, write data to file and load it
clean_data_filename <- paste0('hexsim_', Sys.Date(), '.csv') 
write.csv(df, clean_data_filename, row.names = FALSE)
rm(list = setdiff(ls(), "clean_data_filename"))
df <- read.csv(clean_data_filename)



# # # analysis
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # N and means by condition
n_table <- with(df, tapply(pid, cond, FUN = function(x) length(unique(x))))
cat(paste0('\nTotal Subjects = ', sum(n_table)),'\n')
print(cbind(n = n_table, aggregate(tax_sel ~ cond, mean, data = df))[-2])
cat('\n')





# # # visualization
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# taxonomic responding by condition
cond_plot <- ggplot(aggregate(tax_sel ~ cond + pid, mean, data = df), 
  aes(x = as.factor(cond), y = tax_sel)) + geom_boxplot(outlier.colour = NA) + 
  geom_jitter(alpha = .75, position = position_jitter(width = .3, height = 0)) +
  annotate('text', x = names(n_table), y = c(0,0,0,0,0), label = paste0('n = ', n_table)) +
  stat_summary(fun.y = mean, geom = 'point', shape = 18, color = 'black', 
    size = 4, show.legend = FALSE) + ggtitle('Taxonomic Responding by Condition') +
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22, margin = margin(0,10,0,0)),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22, margin = margin(10,0,0,0)),
    axis.text.x = element_text(size = 18, color = 'black')) + 
  scale_y_continuous(limits=c(0,1.001), breaks=seq(0, 1, 0.1), 
    name = 'Proportion Taxonomic') + 
  scale_x_discrete(name = 'Condition', 
    limits = c('sextet_base','sextet_rand','triad_base','triad_rand', 'triad_goes'), 
    labels = c('Base\n5 Targets', 'No Base\n6 Targets',
      'Base\n2 Targets', 'No Base\n3 Targets', 'Goes\nWith')) + 
  coord_cartesian(ylim = c(0,1))

#taxonomic responding over trials
trial_plot <- ggplot(aggregate(tax_sel ~ trial + cond, mean, data = df), 
  aes(x = trial, y = tax_sel, group = cond, color = cond)) +
  geom_point(shape = 1) + geom_smooth(aes()) +
  theme(plot.title = element_text(size = 26, vjust = 2),
    axis.title.y = element_text(size = 22,vjust = 1.5),
    axis.text.y = element_text(size = 18, color = 'black'),
    axis.title.x = element_text(size = 22,vjust = -.5),
    axis.text.x = element_text(size = 18, color = 'black')) +
  scale_y_continuous(limits = c(0,1.00), breaks = seq(0, 1, 0.1), 
    name = 'Proportion Taxonomic') + scale_x_continuous(name = 'Trial') +
  labs(color = 'Condition') + coord_cartesian(ylim = c(0,1)) +
  ggtitle('Taxonomic Responses across Trials')

# rt based on taxonomic responses to words
rt_word_plot <- ggplot(aggregate(rt ~ base, median, data = subset(df, tax_sel == 1)),
  aes(reorder(base, rt), rt)) + geom_point(shape = 1) + 
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22,vjust = 1.5),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22,vjust = -.5),
    axis.text.x = element_text(size = 8, color = 'black', 
      angle = 90, vjust = 0.5, hjust = 1)) +
  scale_y_continuous(breaks = seq(2.5, 6, 0.25), name = 'Median Response Time') +
  scale_x_discrete(name = 'Base Word') + ggtitle('Taxonomic Response Time by Item') +
  coord_cartesian(ylim = c(2.5,6))

# taxonomic response proportion by item
tax_word_plot <- ggplot(aggregate(tax_sel ~ base, mean, data = df),
  aes(reorder(base, tax_sel), tax_sel)) + geom_point(shape = 1) + 
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22,vjust = 1.5),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22,vjust = -.5),
    axis.text.x = element_text(size = 8, color = 'black', 
      angle = 90, vjust = 0.5, hjust = 1)) +
  scale_y_continuous(breaks = seq(0, 1, 0.1), name = 'Mean Taxonomic') +
  scale_x_discrete(name = 'Base Word') + ggtitle('Taxonomic Responding by Item') +
  coord_cartesian(ylim = c(0,1)) 

# tax/them selections by item
tax_the_word_plot <- ggplot(aggregate(tax_the_sel ~ base, mean, data = df),
  aes(reorder(base, tax_the_sel), tax_the_sel)) + geom_point(shape = 1) + 
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22,vjust = 1.5),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22,vjust = -.5),
    axis.text.x = element_text(size = 8, color = 'black', 
      angle = 90, vjust = 0.5, hjust = 1)) +
  scale_y_continuous(breaks = seq(0, .1, 0.01), name = 'Mean Taxonomic/Thematic') +
  scale_x_discrete(name = 'Base Word') + ggtitle('Taxonomic/Thematic Responding') +
  coord_cartesian(ylim = c(0,.06)) 

# unrelated selcetions by item
unr_word_plot <- ggplot(aggregate(unr_sel ~ base, mean, data = df),
  aes(reorder(base, unr_sel), unr_sel)) + geom_point(shape = 1) + 
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22,vjust = 1.5),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22,vjust = -.5),
    axis.text.x = element_text(size = 8, color = 'black', 
      angle = 90, vjust = 0.5, hjust = 1)) +
  scale_y_continuous(breaks = seq(0, .1, 0.01), name = 'Mean Unrelated') +
  scale_x_discrete(name = 'Base Word') + ggtitle('Unrelated Responding by Item') +
  coord_cartesian(ylim = c(0,.06)) 

# response time by selection
trial_sel_table <- table(df$trial_sel)
rt_cond_plot <- ggplot(aggregate(rt ~ trial_sel + pid, median, data = df),
  aes(x = trial_sel, y = rt)) + geom_boxplot(outlier.colour = NA) + 
  geom_jitter(alpha=.7, position = position_jitter(width = .3, height = 0)) + scale_alpha_discrete() +
  annotate('text', x = names(trial_sel_table), y = c(45,45,45,45), 
    label = paste0('n = ', trial_sel_table)) +
  #geom_text(aes(label = ifelse(rt > 22, as.character(pid),'')), hjust = 0, just = 0) +
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22,vjust = 1.5),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22,vjust = -.5),
    axis.text.x = element_text(size = 12, color = 'black')) +
  scale_y_continuous(breaks = seq(0, 45, 5), name = 'Median Response Time') +
  scale_x_discrete(name = 'Word Relation Type', 
    breaks = c('tax','the','unr', 'otr'),
    limits = c('tax','the','unr', 'otr'),
    labels = c('Taxonomic','Thematic', 'Unrelated', 'Other')) +
  coord_cartesian(ylim = c(0, 46)) + ggtitle('RT by Relation Type Selection')    

# # # cincinnati plot for taxonomic responding by condition
# # # unrelated selections by class of unr
# get labels on word graphs
# line graphs across time

# unrelated selections by condition
df_unr <- subset(df, cond %in% c('sextet_base','sextet_rand'))
df_unr$cond <- factor(df_unr$cond)

cond_plot_unr <- ggplot(aggregate(unr_sel ~ cond + pid, mean, data = df_unr), 
  aes(x = as.factor(cond), y = unr_sel)) + geom_boxplot(outlier.colour = NA) + 
  geom_jitter(alpha = .75, position = position_jitter(width = .3, height = 0)) +
  annotate('text', x = names(n_table)[1:2], y = c(.15,.15), label = paste0('n = ', n_table[1:2])) +
  stat_summary(fun.y = mean, geom = 'point', shape = 18, color = 'black', 
    size = 4, show.legend = FALSE) + ggtitle('Unrelated Responding') +
  theme(plot.title = element_text(size=26, vjust=2),
    axis.title.y = element_text(size=22, margin = margin(0,10,0,0)),
    axis.text.y = element_text(size=18, color = 'black'),
    axis.title.x = element_text(size=22, margin = margin(10,0,0,0)),
    axis.text.x = element_text(size = 18, color = 'black')) + 
  scale_y_continuous(limits = c(0,1.001), breaks = seq(0, 1, 0.05), 
    name = 'Proportion Unrelated') + 
  scale_x_discrete(name = 'Condition', 
    limits = c('sextet_base','sextet_rand'), 
    labels = c('Base\n5 Targets', 'No Base\n6 Targets')) + 
  coord_cartesian(ylim = c(0,.2))    

# # # # PRINT ALL PLOTS TO PDF
if(any(grepl("Acrobat",
  readLines(textConnection(system('tasklist', 
    intern=TRUE))))) == TRUE) {
  system('taskkill /f /im acrobat.exe')
}

pdf('hexsim_results plot.pdf')
print(cond_plot)
print(rt_cond_plot)
print(cond_plot_unr)
print(rt_word_plot)
print(tax_word_plot)
print(tax_the_word_plot)
print(unr_word_plot)
print(trial_plot)
dev.off()
#warnings()
system('open "hexsim_results plot.pdf"')
