library("ggplot2")
library("readr")
library("dplyr")
library("highcharter")
library("treemap")
library("modeest")
library("GGally")
library("tidyverse")
library("hrbrthemes")
library("tidyr")
library("VIM")
library("e1071")
library("mice")
library("mongolite")
#Carga de paquetes
library("SnowballC")
library("tm")
library("twitteR")
library("syuzhet")

## Datos numericos
tweets_hashes <- tweets$aggregate('[{"$project":{"quoted_verified":"$quoted_verified","retweet_verified":"$retweet_verified","is_retweet":"$is_retweet","is_quote":"$is_quote","favorite_count":"$favorite_count","quote_count":"$quote_count","retweet_count":"$retweet_count","reply_count":"$reply_count","quoted_favorite_count":"$quoted_favorite_count","quoted_retweet_count":"$quoted_retweet_count","quoted_statuses_count":"$quoted_statuses_count","retweet_favorite_count":"$retweet_favorite_count","retweet_retweet_count":"$retweet_retweet_count","retweet_statuses_count":"$retweet_statuses_count"}}]')
summary(tweets_hashes)

# Cantidad de cada tipo de tweets.
summary(tweets_hashes$is_quote)
summary(tweets_hashes$is_retweet)
nrow(tweets_hashes) #28907
nrow(tweets_hashes[tweets_hashes$is_quote,]) #5205
nrow(tweets_hashes[tweets_hashes$is_retweet,]) #21286
nrow(tweets_hashes[!tweets_hashes$is_retweet & tweets_hashes$is_quote,]) #1789
nrow(tweets_hashes[tweets_hashes$is_retweet & !tweets_hashes$is_quote,]) #17870
nrow(tweets_hashes[tweets_hashes$is_retweet & tweets_hashes$is_quote,]) #3416
nrow(tweets_hashes[!tweets_hashes$is_retweet & !tweets_hashes$is_quote,]) #5832

names(tweets_hashes)
# Quoted
cols <- c('quoted_favorite_count', 'quoted_retweet_count', 'quoted_statuses_count','quoted_verified')
tweets_hashes[tweets_hashes$is_retweet & tweets_hashes$is_quote,] %>% select(c(2:15))