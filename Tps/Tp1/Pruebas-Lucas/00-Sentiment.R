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

# tweets <- mongo(collection = "tweets_mongo_covid19", db = "DMUBA")
tweets <- mongo(collection = "tweets_lower", db = "DMUBA")
users <- mongo(collection = "users_mongo_covid19", db = "DMUBA")


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#  Alguna info y gráficos con texto, longitud y sentimientos
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#Instalación de paquetes que se utilizarán
# install.packages("SnowballC")
# install.packages("tm")
# install.packages("twitteR")
# install.packages("syuzhet")

#Carga de paquetes
library(SnowballC)
library(tm)
library(twitteR)
library(syuzhet)

tweets_text <- tweets$aggregate('[{
            "$project": { 
                "_id": "$_id",
                "text": "$text"
            }
        }
    ]')
summary(tweets_text)
tweets_text$cantChars <- nchar(tweets_text$text)
summary(tweets_text)
# Por hay un tweet de 900 char? será por url o cosas así?
boxplot(tweets_text$cantChars)

ggplot(tweets_text, aes(x=cantChars)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8) +
  ggtitle("Night price distribution of Airbnb appartements") +
  theme_ipsum()


tweets_text.df2 <- tweets_text
tweets_text.df2$text <- gsub("http.*","",tweets_text.df2$text)
tweets_text.df2$text <- gsub("https.*","",tweets_text.df2$text)

#Quitando los hashtags y usuarios en los tweets_text
tweets_text.df2$text <- gsub("#\\w+","",tweets_text.df2$text)
tweets_text.df2$text <- gsub("@\\w+","",tweets_text.df2$text)

tweets_text.df2$cantChars <- nchar(tweets_text.df2$text)
ggplot(tweets_text.df2, aes(x=cantChars)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8) +
  ggtitle("Night price distribution of Airbnb appartements") +
  theme_ipsum()


tweets_text.df2$text <- gsub("[[:punct:]]","",tweets_text.df2$text)
tweets_text.df2$text <- gsub("\\w*[0-9]+\\w*\\s*", "",tweets_text.df2$text)
tweets_text.df2$cantChars <- nchar(tweets_text.df2$text)
ggplot(tweets_text.df2, aes(x=cantChars)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8) +
  ggtitle("Night price distribution of Airbnb appartements") +
  theme_ipsum()


#Verificando cantidad de tweets_text importados
n.tweet <- length(tweets_text)
n.tweet

#Convirtiendo los tweets_text en un data frame
# tweets_text.df <- twListToDF(tweets_text) 
# head(tweets_text.df)

#Quitando los links en los tweets_text
tweets_text.df2 <- gsub("http.*","",tweets_text$text)
tweets_text.df2 <- gsub("https.*","",tweets_text.df2)

#Quitando los hashtags y usuarios en los tweets_text
tweets_text.df2 <- gsub("#\\w+","",tweets_text.df2)
tweets_text.df2 <- gsub("@\\w+","",tweets_text.df2)

#Quitando los signos de puntuación, números y textos con números
tweets_text.df2 <- gsub("[[:punct:]]","",tweets_text.df2)
tweets_text.df2 <- gsub("\\w*[0-9]+\\w*\\s*", "",tweets_text.df2)

#Transformamos la base de textos importados en un vector para
#poder utilizar la función get_nrc_sentiment
palabra.df <- as.vector(tweets_text.df2)

#Aplicamos la función indicando el vector y el idioma y creamos
#un nuevo data frame llamado emocion.df
emocion.df <- get_nrc_sentiment(char_v = palabra.df, language = "spanish")

#Unimos emocion.df con el vector tweets.df para ver como
#trabajó la función get_nrc_sentiment cada uno de los tweets
emocion.df2 <- cbind(tweets_text.df2, emocion.df)
head(emocion.df2)

#Creamos un data frame en el cual las filas serán las emociones
#y las columnas los puntajes totales

#Empezamos transponiendo emocion.df
emocion.df3 <- data.frame(t(emocion.df))

#Sumamos los puntajes de cada uno de los tweets para cada emocion
emocion.df3 <- data.frame(rowSums(emocion.df3))

#Nombramos la columna de puntajes como cuenta
names(emocion.df3)[1] <- "cuenta"

#Dado que las emociones son los nombres de las filas y no una variable
#transformamos el data frame para incluirlas dentro
emocion.df3 <- cbind("sentimiento" = rownames(emocion.df3), emocion.df3)

#Quitamos el nombre de las filas
rownames(emocion.df3) <- NULL

#Verificamos el data frame
print(emocion.df3)
sentimientos1 <- ggplot(emocion.df3[1:8,],
                        aes(x = sentimiento,
                            y = cuenta, fill = sentimiento)) + 
  geom_bar(stat = "identity") +
  labs(title = "Análisis de sentimiento \n Ocho emociones",
       x = "Sentimiento", y = "Frecuencia") +
  geom_text(aes(label = cuenta),
            vjust = 1.5, color = "black",
            size = 5) +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text = element_text(size=12),
        axis.title = element_text(size=14,face = "bold"),
        title = element_text(size=20,face = "bold"),
        legend.position = "none")
print(sentimientos1)

# Primer grafico de sentiments usando este link:
# https://www.linkedin.com/pulse/an%C3%A1lisis-de-sentimiento-en-r-carlos-j%C3%A1uregui-fern%C3%A1ndez/

#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#  FIN . Alguna info y gráficos con texto, longitud y sentimientos
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
