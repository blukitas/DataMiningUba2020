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
library(SnowballC)
library(tm)
library(twitteR)
library(syuzhet)

tweets <- mongo(collection = "tweets_lower", db = "DMUBA")
users <- mongo(collection = "users_mongo_covid19", db = "DMUBA")


#----------------------------------------------------------------------------------
#  Numericos
#----------------------------------------------------------------------------------
js<-'[{"$project":{"_id":"$_id","text":"$text","display_text_width":"$display_text_width","is_quote":"$is_quote","is_retweet":"$is_retweet","favorite_count":"$favorite_count","retweet_count":"$retweet_count","followers_count":"$followers_count","friends_count":"$friends_count","listed_count":"$listed_count","statuses_count":"$statuses_count","favourites_count":"$favourites_count","account_created_at":"$account_created_at","verified":"$verified","reply_count":"$reply_count"}}]'
jsonlite::fromJSON(js)
numericos <- tweets$aggregate(js)
summary(numericos)

boxplot(numericos$display_text_width) # Distinto de la longitud de caracteres de text

barplot(table(numericos$verified)) #Muy pocos verificados
barplot(table(numericos$is_quote)) #Pocas citas
barplot(table(numericos$is_retweet)) #Muchos retweets
## Estaría bueno hacer este gráfico de actividad por fecha
## Por fecha suavizada tambien es una opcion
barplot(table(sort(numericos$account_created_at)))

# Todos leyes de potencia, aplicar logaritmo y ver q tul.
# Hacer con bins
# Como encontrar casos interesantes?
plot(sort(numericos$friends_count)) #Ley de potencias
plot(numericos$followers_count)
plot(numericos$friends_count)
plot(numericos$listed_count)
plot(numericos$statuses_count)
plot(numericos$favourites_count)

## Coordenadas paralelas con verificado/no
## eSTÁ PIOla para ver popularidad, influencia
ggparcoord(numericos, columns = 8:12, groupColumn = 14) 
# columns = c("friends_count", "favourites_count", "statuses_count", "followers_count", "listed_count"), 
# columns = c(9, 12, 11, 8, 10), 
numericos$verificado <- ifelse(numericos$verified, "Verificados", "Sin verificar")
numericos$verificado <- as.factor(numericos$verificado)

numericos_2 <- numericos[,c(8:12,14)]
numericos_2$verified <- as.factor(numericos_2$verified)
numericos_2$verificado <- ifelse(numericos$verified, "Verificados", "Sin verificar")
summary(numericos_2)

library('viridis')

png(filename="parallelCoords.png", width=1000, bg="white")
ggparcoord(numericos_2,
           columns = 1:4, groupColumn = 6, order = "anyClass",
           scale="center",
           showPoints = TRUE, 
           title = "Standardize and center variables",
           alphaLines = 0.3
) + 
  scale_color_viridis(discrete=TRUE) +
  theme_ipsum()+
  theme(
    legend.position="none",
    plot.title = element_text(size=13)
  ) +
  xlab("")
dev.off()


## Tweets por usuario
tweets_user <- tweets$aggregate('[{ "$group": { "_id": "$name","count": {"$sum": 1}}}]')
plot(sort(tweets_user$count))

## TODO: Calcular influencia?

#-----------------------------------------------------------------------------
# Usuarios del tweet
#-----------------------------------------------------------------------------
user_estadisticas <- mongo(db="DMUBA", collection="user_estadisticas")
info_user <- user_estadisticas$find()

data_log <- as.data.frame(apply(info_user[,1:5], 2, log))
info_user[info_user == 0] <- 0.00001
data_log_1 <- as.data.frame(apply(info_user[,1:5], 2, log))

png(filename="ppais_nums_log.png", width=1000, bg="white")
ggpairs(data_log)
dev.off()
png(filename="ppais_nums.png", width=1000, bg="white")
ggpairs(info_user[,1:5])
dev.off()

summary(info_user)
# Con 0's
boxplot(data_log)
# Con 0.0000001's
boxplot(data_log_1)


info_user$verificado <- ifelse(info_user$verified, "Verificados", "Sin verificar")
info_user$verificado <- as.factor(info_user$verificado)

png(filename="parcoord-user-basico.png", width=1000, bg="white")
ggparcoord(info_user, columns = 1:5, groupColumn = 7) 
dev.off()

png(filename="parcoord-user.png", width=1000, bg="white")
ggparcoord(info_user,
           columns = 1:4, groupColumn = 7, order = "anyClass",
           scale="center",
           showPoints = TRUE, 
           title = "Standardize and center variables",
           alphaLines = 0.3
)
+ 
  scale_color_viridis(discrete=TRUE) +
  theme_ipsum()+
  theme(
    legend.position="none",
    plot.title = element_text(size=13)
  ) +
  xlab("")
dev.off()



#-----------------------------------------------------------------------------
# Usuarios del tweet original
#-----------------------------------------------------------------------------
user_estadisticas <- mongo(db="DMUBA", collection="tweet_users_original")
info_user <- user_estadisticas$find()
summary(info_user)
summary(info_user[!is.na(info_user$retweet_verified),2:5])
summary(info_user[!is.na(info_user$quoted_verified),7:10])

user_retweets <- info_user[!is.na(info_user$retweet_verified),2:5]
summary(user_retweets)
boxplot(user_retweets)
data_log_1 <- user_retweets
data_log_1[data_log_1 == 0] <- 0.00001
data_log_1 <- as.data.frame(apply(data_log_1[,1:3], 2, log))
boxplot(data_log_1)

# png(filename="ppais_nums_log.png", width=1000, bg="white")
ggpairs(data_log_1)
# dev.off()
# png(filename="ppais_nums.png", width=1000, bg="white")
ggpairs(user_retweets[,1:3])
# dev.off()

user_retweets$verificado <- ifelse(user_retweets$retweet_verified, "Verificados", "Sin verificar")
user_retweets$verificado <- as.factor(user_retweets$verificado)

png(filename="parcoord-user-rt-basico.png", width=1000, bg="white")
ggparcoord(user_retweets, columns = 1:3, groupColumn = 5) 
dev.off()

png(filename="parcoord-user.png", width=1000, bg="white")
ggparcoord(user_retweets,
           columns = 1:3, groupColumn = 5, order = "anyClass",
           scale="center",
           showPoints = TRUE, 
           title = "Standardize and center variables",
           alphaLines = 0.3
)
+ 
  scale_color_viridis(discrete=TRUE) +
  theme_ipsum()+
  theme(
    legend.position="none",
    plot.title = element_text(size=13)
  ) +
  xlab("")
dev.off()