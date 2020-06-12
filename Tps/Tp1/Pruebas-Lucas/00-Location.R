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

df$porcentaje_na <- df$Na / nrow(df_location) * 100
barplot(sort(df$Unique, decreasing = T))
barplot(df$Na)


# png(filename="location_porc_na.png", width=1000, bg="white")
png(filename="location_porc_na.png", width=1000, bg="white")
ggplot(df, aes(x=reorder(Atributo, porcentaje_na), y=porcentaje_na, fill=Atributo)) + 
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="Set2") +
  labs(
    title = "",
    subtitle = "",
    caption = "",
    tag = ""
  ) +
  xlab("") +
  ylab("") +
  theme(plot.title = element_text(hjust = 0.5), 
        axis.text=element_text(size=14),
        axis.text.y = element_text( margin = margin(10, 10, 10, 10)),
        axis.title.x = element_text(margin = margin(t = 10, r = 10, b = 10, l = 10)),
        legend.text=element_text(size=14),
        aspect.ratio = 1/1
  ) +
  coord_flip()
dev.off()
# dev.off()

#----------------------------------------------------------------------------------
#  Tratar nulls en location
#----------------------------------------------------------------------------------
# Es el más acotado, usarlo como referencia, 
barplot(sort(table(df_location$country)))
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
df_location$country_2 <- df_location$country
df_location$country_code_2 <- df_location$country_code
for(i in paises_en$NAME){
  print(i)
  df_location$country_2 <- ifelse(grepl(tolower(i), tolower(df_location$location), fixed= T), tolower(i), df_location$country_2)
}


for(i in paises_en$NAME){
  print(i)
  if (nrow(df_location[!is.na(df_location$country_2) & df_location$country_2 == tolower(i),]) > 0) {
    # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower('spain')] <- as.character.factor(paises_en$ISO[paises_en$NAME == 'SPAIN'])
    # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower(i)] <- as.character.factor(paises_en$ISO[paises_en$NAME == i])
    df_location[!is.na(df_location$country_2) & df_location$country_2 == tolower(i),]$country_code_2 <- paises_en$ISO[paises_en$NAME == i]
  }
}

# # Colocar iso code, para después referencia
# df_location$country_code_2 <-  paises_en[tolower(paises_en$NAME) == df_location$country_2, c('ISO')]

for(i in paises_es$Pais){
  print(i)
  # ifelse(grepl("Argentina", df_location$location, fixed= T), "Argentina", "")
  df_location$country_2 <- ifelse(grepl(tolower(i), tolower(df_location$location), fixed= T), tolower(i), df_location$country_2)
}

for(i in paises_es$Pais){
  print(i)
  if (nrow(df_location[!is.na(df_location$country_2) & df_location$country_2 == tolower(i),]) > 0) {
    # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower('spain')] <- as.character.factor(paises_en$ISO[paises_en$NAME == 'SPAIN'])
    # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower(i)] <- as.character.factor(paises_en$ISO[paises_en$NAME == i])
    df_location[!is.na(df_location$country_2) & df_location$country_2 == tolower(i),]$country_code_2 <- paises_es$Codigo[paises_es$Pais == i]
  }
  # df_location$country_code_2[!is.na(df_location$country_2) & df_location$country_2 == tolower(i)] <- as.character.factor(paises_es$Codigo[paises_es$Pais == i])
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
