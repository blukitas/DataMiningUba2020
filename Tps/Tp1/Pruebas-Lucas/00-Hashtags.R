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

# tweets <- mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
tweets <- mongo(collection = "tweets_lower", db = "DMUBA")
users <- mongo(collection = "users_mongo_covid19", db = "DMUBA")

## Hashtags

tweets_hashes_null <- tweets$find('{"hashtags":{"$elemMatch":{"$in":[null], "$exists":true}}}')
# Hay mucho retweet y no suelen tener hashtags. Es solo una segunda exposicion del mismo texto.

tweets_hashes <- tweets$aggregate('[{"$project":{"_id":"$_id","user_id":"$user_id","hashtag":"$hashtags"}},{"$unwind":"$hashtag"},{"$match":{"hashtag":{"$ne":null}}}]')
head(tweets_hashes)
head(table(tweets_hashes$hashtag))

tweets_hashes$hashtag_2 <- gsub("[[:punct:]]","",tweets_hashes$hashtag)
tweets_hashes$hashtag_2 <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", tweets_hashes$hashtag_2)
tweets_hashes$hashtag_2 <- iconv(tweets_hashes$hashtag_2,from="UTF-8",to="ASCII//TRANSLIT")
head(tweets_hashes)

nrow(tweets_hashes) #2963
length(unique(tweets_hashes$hashtag)) #2779
length(unique(tweets_hashes$hashtag_2)) #2769
cuarentena_words <- c('covid', 'cuarentena', 'casa', 'corona', 'virus') #Riesgo con virus machismo
tweets_hashes$is_cuarentena_related <- F
for (i in cuarentena_words) {
  tweets_hashes$is_cuarentena_related <- ifelse(grepl(i, tweets_hashes$hashtag_2, fixed= T), T, tweets_hashes$is_cuarentena_related)
}

# Hay varios hashtags dudosos
# [897] "gordosgay" # [898] "chubbygaycdmx" # [899] "chasergay"# [900] "gorditosgay"# [901] "gordoslgbt"                                                                                
# [902] "chubbylgbt" # [529] "swingtrading"# [530] "swingers"# [531] "swingerfriends"# [532] "swingerlifestyle"                                                                          
# [533] "couple"  # "viernesdetransexuales"# "squirt"# [363] "viernescogelon"# [364] "sexyunicornio"                                                                       
# [219] "hotwife"# [220] "corneador"# [221] "cornudo"# [41] "cruising"# [42] "cruisingmadrid"                                                                            
# [43] "gaymadrid"# [44] "madridcruising"# [45] "gloryhole"       sexmex   
sex_words <- c('sex', 'boobs', 'nudismo', 'cachonda', 'bultogrande', 'bulto', 'tanga', 'swingers', 'squirt', 'gloryhole', 'hotwife')
tweets_hashes$is_sex_related <- F
for (i in sex_words) {
  tweets_hashes$is_sex_related <- ifelse(grepl(i, tweets_hashes$hashtag_2, fixed= T), T, tweets_hashes$is_sex_related)
}

length(unique(tweets_hashes[!tweets_hashes$is_cuarentena_related,]$hashtag_2)) # 2551
length(unique(tweets_hashes[!tweets_hashes$is_sex_related,]$hashtag_2)) # 2691
length(unique(tweets_hashes[!tweets_hashes$is_sex_related & !tweets_hashes$is_cuarentena_related,]$hashtag_2)) # 2525


tweets_count <- mongo(db='DMUBA', collection='tweet_count_hashtags')
tweets_count <- tweets_count$find()
tweets_count$hashtag_2 <- gsub("[[:punct:]]","",tweets_count$hashtag)
tweets_count$hashtag_2 <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", tweets_count$hashtag_2)
tweets_count$hashtag_2 <- iconv(tweets_count$hashtag_2,from="UTF-8",to="ASCII//TRANSLIT")
tweets_count$is_cuarentena_related <- F
for (i in cuarentena_words) {
  tweets_count$is_cuarentena_related <- ifelse(grepl(i, tweets_count$hashtag_2, fixed= T), T, tweets_count$is_cuarentena_related)
}
tweets_count$is_sex_related <- F
for (i in sex_words) {
  tweets_count$is_sex_related <- ifelse(grepl(i, tweets_count$hashtag_2, fixed= T), T, tweets_count$is_sex_related)
}
# Hastags de fechas

head(tweets_count[!tweets_count$is_cuarentena_related & !tweets_count$is_sex_related,] %>% select(2:3), n=20)
head(tweets_count[tweets_count$is_cuarentena_related,] %>% select(2:3), n=20)
head(tweets_count %>% select(2:3), n=20)

# 36 afp - En chile fondo pensiones. | Agence France-Presse es la agencia de noticias más antigua en el mundo y una de las mayores junto con Reuters, Associated Press y EFE. 
# 33 bartlett - Ministro mexicano (SNTEUnidoyfuerte, IMSS tambien mexicanos)
# 32 proteccionyaccion - Venezuela

# carpincho?
# Tweets politicos, hablando bien o mal de alberto.
# Hashtags de paises
# Feminismo/Feminicidio
# Cuba

# Despues con esos hashtags, podrían buscarse los tweets y hacer nubes de palabras, o sentimental.
