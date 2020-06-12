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

# tweets <- mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
tweets <- mongo(collection = "tweets_lower", db = "DMUBA")
users <- mongo(collection = "users_mongo_covid19", db = "DMUBA")

## Tweets por fecha
tweets_fecha <- tweets$aggregate('[{ "$project": { "_id": "$_it","fecha": "$created_at"}}]')
summary(tweets_fecha)

boxplot(tweets_fecha$fecha)
plot(tweets_fecha$fecha)
barplot(table(as.Date(tweets_fecha$fecha)))
# Contrastar esto con los anuncios de prorroga
#https://www.infobae.com/tag/1-de-mayo/
#https://www.infobae.com/tag/2-de-mayo/
# Igual dada la cantidad de tweets es medio arbitrario

# Seguramente estuvo más tiempo capturando -> Grafico para demostrar

library(tidyverse)
library(lubridate)

tweets_fecha$t <- ymd_hms(tweets_fecha$fecha)
tweets_fecha$tc <- cut(tweets_fecha$t, breaks = "5 min")  
cant_5_min <- count(tweets_fecha, tc)
barplot(cant_5_min$n, legend.text=cant_5_min$tc)
## Tweets por fecha

# Por minuto está más equilibrado
tweets_fecha$t <- ymd_hms(tweets_fecha$fecha)
tweets_fecha$tc <- cut(tweets_fecha$t, breaks = "1 min")  
cant_5_min <- count(tweets_fecha, tc)
barplot(cant_5_min$n)
