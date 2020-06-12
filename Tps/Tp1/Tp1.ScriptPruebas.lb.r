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

names(tweets$find())
names(users$find())

df_source = tweets$aggregate('[{ "$group": {"_id": "$source", "total": { "$sum": 1} } },
                               { "$sort": { "total" : -1}}
                             ]')
                             
names(df_source) <- c("source", "count")

ggplot(data=head(df_source, 10), aes(x=reorder(source, -count), y=count)) +
  geom_bar(stat="identity", fill="steelblue") +
  xlab("Source") + ylab("Cantidad de tweets") +
  labs(title = "Cantidad de tweets en los principales clientes")


df_fechas$color <- ifelse(df_fechas$is_retweet, "red", "yellow")
plot(df_fechas$created_at, color=df_fechas$color)

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


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#  Alguna info y gráficos con location
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------

df_location <- tweets$aggregate('[{
            "$project": { 
                "_id": "$_id",
                "location": "$location",
                "retweet_location": "$retweet_location",
                "quoted_location": "$quoted_location",
                "country_code": "$country_code",
                "country": "$country",
                "lat": "$lat",
                "lng": "$lng"
            }
        }
    ]')

summary(df_location)
nombre_location <- c("location", "retweet", "quoted", "country_code", "country", "lat", "lng")
cant_unique <- c( length(unique(df_location$location))
                 ,length(unique(df_location$retweet_location))
                 ,length(unique(df_location$quoted_location))
                 ,length(unique(df_location$country_code))
                 ,length(unique(df_location$country))
                 ,length(unique(df_location$lat))
                 ,length(unique(df_location$lng)))
cant_na <- c( nrow(df_location[is.na(df_location$location),])
            , nrow(df_location[is.na(df_location$retweet_location),])
            , nrow(df_location[is.na(df_location$quoted_location),])
            , nrow(df_location[is.na(df_location$country_code),])
            , nrow(df_location[is.na(df_location$country),])
            , nrow(df_location[is.na(df_location$lat),])
            , nrow(df_location[is.na(df_location$lng),])
            )
df <- do.call(rbind, Map(data.frame, A=nombre_location, B=cant_unique, C=cant_na))
names(df)[1] <- "Atributo"
names(df)[2] <- "Unique"
names(df)[3] <- "Na"

barplot(sort(df$Unique, decreasing = T))
barplot(df$Na)


#----------------------------------------------------------------------------------
#  Tratar nulls en location
#----------------------------------------------------------------------------------
# Es el más acotado, usarlo como referencia, 
table(df_location$country)
# Si en location está alguna de estos, asignarlo?
unique_country_name <- unique(df_location[!is.na(df_location$country),]$country)
df_location$country_2 <- df_location$country
df_location$country_code_2 <- df_location$country_code_2
for(i in unique_country_name){
  print(i)
  # ifelse(grepl("Argentina", df_location$location, fixed= T), "Argentina", "")
  df_location$country_2 <- ifelse(grepl(tolower(i), tolower(df_location$location), fixed= T), i, df_location$country_2)
}
nrow(df_location[is.na(df_location$country_2),]) 
## Con to_lower paso de 19709 -> 19123
nrow(df_location[is.na(df_location$country),]) 
nrow(df_location[is.na(df_location$location),]) 
nrow(df_location)

# 66% de nulls
print(nrow(df_location[is.na(df_location$country_2),])  / nrow(df_location))
unique(df_location$country_2)

paises_en <- read.csv("C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Tp1\\countries.en.csv", header = T, sep = ';')
paises_es <- read.csv("C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Tp1\\countries.es.csv", header = T, sep = ';')

head(paises_en)
head(paises_es)
paises_es$Pais <- trimws(paises_es$Pais, which = "both")
paises_es$Codigo <- trimws(paises_es$Codigo, which = "both")
paises_es$Region <- trimws(paises_es$Region, which = "both")
paises_es$Continente <- trimws(paises_es$Continente, which = "both")

# df_location[grepl(tolower('españa'), tolower(df_location$location), fixed= T),]
# df_location[grepl(tolower('espana'), tolower(df_location$location), fixed= T),]
# df_location[grepl(tolower('spain'), tolower(df_location$location), fixed= T),]

for(i in paises_en$NAME){
  print(i)
  df_location$country_2 <- ifelse(grepl(tolower(i), tolower(df_location$location), fixed= T), tolower(i), df_location$country_2)
}

for(i in paises_en$NAME){
  print(i)
  # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower('spain')] <- as.character.factor(paises_en$ISO[paises_en$NAME == 'SPAIN'])
  df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower(i)] <- as.character.factor(paises_en$ISO[paises_en$NAME == i])
}

# Colocar iso code, para después referencia
df_location$country_code_2 <-  paises_en[tolower(paises_en$NAME) == df_location$country_code_2, c('ISO')]

for(i in paises_es$Pais){
  print(i)
  # ifelse(grepl("Argentina", df_location$location, fixed= T), "Argentina", "")
  df_location$country_2 <- ifelse(grepl(tolower(i), tolower(df_location$location), fixed= T), tolower(i), df_location$country_2)
}

for(i in paises_es$Pais){
  print(i)
  df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower(i)] <- as.character.factor(paises_es$Codigo[paises_es$Pais == i])
}

for(i in paises_es$Codigo){
  print(i)
  df_location$Region[!is.na(df_location$country_code_2) & df_location$country_code_2 == i] <- paises_es$Region[paises_es$Codigo == i]
  df_location$Continente[!is.na(df_location$country_code_2) & df_location$country_code_2 == i] <- paises_es$Continente[paises_es$Codigo == i]
}
barplot(table(df_location$Continente))

nrow(df_location[is.na(df_location$country_2),])
# 64% de nulls
print(nrow(df_location[is.na(df_location$country_2),])  / nrow(df_location))
sort(unique(tolower(df_location$country_2)))


#----------------------------------------------------------------------------------
#  FIN Tratar nulls en location
#----------------------------------------------------------------------------------

table(df_location$location)
df_location[is.na(df_location$country_code), ]

# Como ver cuantos null en casa columna
nrow(df_location[is.na(df_location$location),])
nrow(df_location[is.na(df_location$retweet_location),])
nrow(df_location[is.na(df_location$quoted_location),])
nrow(df_location[is.na(df_location$country_code),])
nrow(df_location[is.na(df_location$country),])
nrow(df_location)
# Hay coincidencias
unique(df_location[,c("country", "country_code")])

df_location[df_location$country == 'NA', ]

sort(unique(tolower(df_location$country_2)))
# Marca de error => Angola de chilANGOLAndia
df_location[df_location$country_2 == 'angola' & !is.na(df_location$country_2), ]
# Marca de error => macao de huMACAO - Estado de puerto rico
df_location[df_location$country_2 == 'macao' & !is.na(df_location$country_2), ]
## Hay de india y de INDIAna, USA
df_location[df_location$country_2 == 'india' & !is.na(df_location$country_2), ]
df_location[df_location$country_2 == 'iceland' & !is.na(df_location$country_2), ]
# Polonia, pero eran de la Embajada de cuba, retweet_location
df_location[df_location$country_2 == 'polonia' & !is.na(df_location$country_2), ]
# Georgia, USA
df_location[df_location$country_2 == 'georgia' & !is.na(df_location$country_2), ]
## GRanada españa
df_location[df_location$country_2 == 'granada' & !is.na(df_location$country_2), ]
# Iran encaja con varias otras cosas, entonces mIRANda (Venezuela), almIRANte brown....
df_location[df_location$country_2 == 'iran' & !is.na(df_location$country_2), ]
## Noruega en location, retweet location madrid
df_location[df_location$country_2 == 'noruega' & !is.na(df_location$country_2), ]


#----------------------------------------------------------------------------------
#  FIN Tratar sacar info de location
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
#  Numericos
#----------------------------------------------------------------------------------
# js<-'[{"$project":{"_id":"$_id","text":"$text","display_text_width":"$display_text_width","is_quote":"$is_quote","is_retweet":"$is_retweet","favorite_count":"$favorite_count","retweet_count":"$retweet_count","followers_count":"$followers_count","friends_count":"$friends_count","listed_count":"$listed_count","statuses_count":"$statuses_count","favourites_count":"$favourites_count","account_created_at":"$account_created_at","verified":"$verified","reply_count":"$reply_count"}}]'
# jsonlite::fromJSON(js)
# numericos <- tweets$aggregate(js)
tweets <- mongo(db="DMUBA", collection="tweet_completo_estadisticas")
numericos <- tweets$find()
summary(numericos)

boxplot(numericos$display_text_width) # Distinto de la longitud de caracteres de text

barplot(table(numericos$verified)) #Muy pocos verificados
barplot(table(numericos$quoted_verified)) #pocos verificados
barplot(table(numericos$retweet_verified)) #Muchos verificados
barplot(table(tweets_types[!tweets_types$is_retweet & !tweets_types$is_quote,]$verified))
barplot(table(tweets_types[!tweets_types$is_retweet & tweets_types$is_quote,]$verified))
barplot(table(tweets_types[tweets_types$is_retweet & !tweets_types$is_quote,]$verified))
barplot(table(tweets_types[tweets_types$is_retweet & tweets_types$is_quote,]$verified))


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

tweets_count[!tweets_count$is_cuarentena_related & !tweets_count$is_sex_related,] %>% select(2:3)
# carpincho?
# Tweets politicos, hablando bien o mal de alberto.
# Hashtags de paises
# Feminismo/Feminicidio
# Cuba

# Despues con esos hashtags, podrían buscarse los tweets y hacer nubes de palabras, o sentimental.

## Text hashtags
tweets <- mongo(db='DMUBA', collection='tweet_text')
text_hastags <- tweets$find()

text_hastags$has <- ifelse(grepl("afp", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #94
text_hastags$has <- ifelse(grepl("afpgraphics", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #46
text_hastags$has <- ifelse(grepl("chile", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #403
text_hastags$has <- ifelse(grepl("cuba", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #375
text_hastags$has <- ifelse(grepl("cuba", text_hastags$text), T, F) & ifelse(grepl("médic", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #49
text_hastags$has <- ifelse(grepl("venezuel", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #407
text_hastags$has <- ifelse(grepl("mexico", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #139
text_hastags$has <- ifelse(grepl("méxico", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #701
text_hastags$has <- ifelse(grepl("mejico", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #1
text_hastags$has <- ifelse(grepl("méjico", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,])
text_hastags$has <- ifelse(grepl("argentin", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #398
text_hastags$has <- ifelse(grepl("buenos", text_hastags$text), T, F) & ifelse(grepl("aires", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #32
text_hastags$has <- ifelse(grepl("médic", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) # 804
text_hastags$has <- ifelse(grepl("medic", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #291
text_hastags$has <- ifelse(grepl("chin", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #491
text_hastags$has <- ifelse(grepl("eeuu", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #201
text_hastags$has <- ifelse(grepl("usa", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #853
text_hastags$has <- ifelse(grepl("u.s.a", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #821
text_hastags$has <- ifelse(grepl("e.e.u.u", text_hastags$text), T, F) #& ifelse(grepl("cuba", text_hastags$text), T, F) 
nrow(text_hastags[text_hastags$has,]) #5

# afp <- 115
# & afpgraphics <- 52
# chile <- 464
# mexico/méxico <- 1101
# cuba <- 537
# cuba y medico <- 70
# argentin <- 450
# medic/médico <- 1200
# venezuela <- 500
# chin <- 580
# eeuu/usa/u.s.a/e.e.u.u <- 2000

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






### Sentiment general

```{r}
# Para ejecutar descomentar esta linea.
#palabra.df <- as.vector(tweets_text.df2$text)

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

```

```{r}
print(sentimientos1)
```

### Word cloud CUBA
http://www.sthda.com/english/wiki/text-mining-and-word-cloud-fundamentals-in-r-5-simple-steps-you-should-know
```{r}

library("wordcloud")
library("RColorBrewer")

# Me deja sin memoria. Esto haría un wordcloud
tweets_cuba <- mongo(db="DMUBA", collection="tweet_cuba")
tweets_cuba <- tweets_cuba$find()

docs <- tweets_cuba$text
docs <- gsub("http.*","",docs)
docs <- gsub("https.*","",docs)

#Quitando los hashtags y usuarios en los tweets_text
docs <- gsub("#\\w+","",docs)
docs <- gsub("@\\w+","",docs)

docs <- gsub("[[:punct:]]","",docs)
docs <- gsub("\\w*[0-9]+\\w*\\s*", "",docs)

docs <- gsub("[[:punct:]]","",docs)
docs <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", docs)
docs <- iconv(docs,from="UTF-8",to="ASCII//TRANSLIT")

docs <- Corpus(VectorSource(docs))
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")
# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("spanish"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("cuba", "cubanos", "cubanas")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)
dtm <- TermDocumentMatrix(docs)
# dtm <- TermDocumentMatrix(tweets_text.df2$text)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)



```

```{r}
set.seed(1234)

# png(filename="nube-cuba.png", width=1000, bg="white")
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=100, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))
# dev.off()
```

### Word cloud - Mexico

```{r}

# Me deja sin memoria. Esto haría un wordcloud
tweets_mx <- mongo(db="DMUBA", collection="tweet_mx")
tweets_mx <- tweets_mx$find()

docs <- tweets_mx$text
docs <- gsub("http.*","",docs)
docs <- gsub("https.*","",docs)

#Quitando los hashtags y usuarios en los tweets_text
docs <- gsub("#\\w+","",docs)
docs <- gsub("@\\w+","",docs)

docs <- gsub("[[:punct:]]","",docs)
docs <- gsub("\\w*[0-9]+\\w*\\s*", "",docs)

docs <- gsub("[[:punct:]]","",docs)
docs <- gsub("[^[:alnum:][:blank:]?&/\\-]", "", docs)
docs <- iconv(docs,from="UTF-8",to="ASCII//TRANSLIT")

docs <- Corpus(VectorSource(docs))
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")
# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("spanish"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("mexico", "méxico")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)
dtm <- TermDocumentMatrix(docs)
# dtm <- TermDocumentMatrix(tweets_text.df2$text)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)


```

```{r}

set.seed(1234)
# png(filename="nube-mx.png", width=1000, bg="white")
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=100, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))
# dev.off()
```
