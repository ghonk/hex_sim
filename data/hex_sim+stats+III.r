
setwd('C:/Users/garre/Dropbox/aa projects/choootooo/hex_sim/data/5.6.16')

library(lmerTest)
library(ggplot2)

df <- read.csv('hexsim_2016-05-08.csv')

str(df)

### sample word sets as a demo

n_table <- with(df, tapply(pid, cond, FUN = function(x) length(unique(x))))
cat(paste0('\nTotal Subjects = ', sum(n_table)),'\n')
print(cbind(n = n_table, aggregate(tax_sel ~ cond, mean, data = df))[-2])
cat('\n')

qqnorm(aggregate(tax_sel ~ base, mean, data = df)$tax_sel, main = 'Taxonomic Responding by Word Set')
qqline(aggregate(tax_sel ~ base, mean, data = df)$tax_sel)

qqnorm(aggregate(rt ~ base, mean, data = df)$rt, main = 'RT by Word Set')
qqline(aggregate(rt ~ base, mean, data = df)$rt)

qqnorm(aggregate(tax_sel ~ pid, mean, data = df)$tax_sel, main = 'Taxonomic Responding by Participant')
qqline(aggregate(tax_sel ~ pid, mean, data = df)$tax_sel)

qqnorm(aggregate(rt ~ pid, mean, data = df)$rt, main = 'RT by Participant')
qqline(aggregate(rt ~ pid, mean, data = df)$rt)

df_neo <- subset(df, native_eng == 'yes') 

n_table_neo <- with(df_neo, tapply(pid, cond, FUN = function(x) length(unique(x))))
cat(paste0('\nTotal Subjects = ', sum(n_table_neo)),'\n')
print(cbind(n = n_table_neo, aggregate(tax_sel ~ cond, mean, data = df_neo))[-2])
cat('\n')

qqnorm(aggregate(tax_sel ~ base, mean, data = df_neo)$tax_sel, main = 'Taxonomic Responding by Word Set - NEO')
qqline(aggregate(tax_sel ~ base, mean, data = df_neo)$tax_sel)

qqnorm(aggregate(rt ~ base, mean, data = df_neo)$rt, main = 'RT by Word Set - NEO')
qqline(aggregate(rt ~ base, mean, data = df_neo)$rt)

qqnorm(aggregate(tax_sel ~ pid, mean, data = df_neo)$tax_sel, main = 'Taxonomic Responding by Participant - NEO')
qqline(aggregate(tax_sel ~ pid, mean, data = df_neo)$tax_sel)

plot(density(aggregate(tax_sel ~ pid, mean, data = df_neo)$tax_sel), main = 'Taxonomic Responding Density')

qqnorm(aggregate(rt ~ pid, median, data = df_neo)$rt, main = 'RT by Participant - NEO')
qqline(aggregate(rt ~ pid, median, data = df_neo)$rt)

df_temp <- aggregate(tax_sel ~ cond + base, mean, data = df_neo)
df_temp <- cbind(df_temp, rt_med = aggregate(rt ~ cond + base, median, data = df_neo)[,3])

par(mfrow = c(3, 2))
for (condition in levels(df_temp$cond)){
  qqnorm(df_temp[df_temp$cond == condition,]$tax_sel, main = paste0('Taxonomic Responding: ', condition))
  qqline(df_temp[df_temp$cond == condition,]$tax_sel)
}

par(mfrow = c(3, 2))
for (condition in levels(df_temp$cond)){
  plot(density(df_temp[df_temp$cond == condition,]$tax_sel), main = paste0('Taxonomic Density: ', condition))
}

par(mfrow = c(3, 2))
for (condition in levels(df_temp$cond)){
  qqnorm(df_temp[df_temp$cond == condition,]$rt, main = paste0('Response Time (sec.): ', condition))
  qqline(df_temp[df_temp$cond == condition,]$rt)
}

par(mfrow = c(3, 2))
for (condition in levels(df_temp$cond)){
   plot(density(df_temp[df_temp$cond == condition,]$rt), main = paste0('Taxonomic Density: ', condition))
}

(cont_mat <- contrasts(df_neo$cond))

model <- glm(tax_sel ~ cond, data = df_neo, family = binomial)
summary(model)

cont_mat <- t(matrix( c(0, 0, 1,-1, 0,  # tgoes vs tbase
                       0, 0,-1, 0, 1,   # tbase vs trand
                       1, 0,-1, 0, 0,   # tbase vs sbase
                      -1, 1, 0, 0, 0),  # sbase vs srand
                      dimnames = list(c('tgoes_tbase', 'tbase_trand', 'tbase_sbase', 'sbase_srand'), 
                                      rownames(contrasts(df_neo$cond))), ncol = 5))

(contrasts(df_neo$cond) <- cont_mat)

model <- glm(tax_sel ~ cond + trial, data = df_neo, family = binomial)
summary(model)

model_mer <- glmer(tax_sel ~ cond + trial + (1|pid) + (1|base), family = binomial, data = df_neo)
summary(model_mer)


