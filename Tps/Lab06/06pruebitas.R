
print("Solucion Laboratorio 1:")

print("Import de librerías")
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

## Leemos el txt
data <- read.table('C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Lab03\\auto-mpg.data-original.txt')

## Primeros ajustes
names(data)[1] <- 'mpg'
names(data)[2] <- 'cylinders'
names(data)[3] <- 'displacement'
names(data)[4] <- 'horsepower'
names(data)[5] <- 'weight'
names(data)[6] <- 'acceleration'
names(data)[7] <- 'model.year'
names(data)[8] <- 'origin'
names(data)[9] <- 'car.name'
data$car.name <- tolower(data$car.name)

## Primer vistazo del dataset
str(data)

## Algunos estadísticos
summary(data)

# Columnas numéricas
num_cols <- names(data)[sapply(data, is.numeric)]

# Datos nulos
## 8 datos en MPG y6 en HorsePower
print(data[rowSums(is.na(data)) > 0,])
count(data[rowSums(is.na(data)) > 0,])
## Dos null o más, en fila
print(data[rowSums(is.na(data)) > 1,])
# TODO: Porcentaje de NA por columna?
count(data) #406
dt_null <- table(is.na(data))
dt_null[2]/dt_null[1]
```


# Pequeño resumencito

unique(data$model.year)
unique(data$origin)
unique(data$cylinders)

length(unique(data$car.name))
length(data$car.name)
# Hay algunos autos repetidos, pero en general como nombre completo casi que no.
#   TODO: Cuales son los repetidos?
# Si lo dividimos en los espacios, se generan 3 columnas:
# * Una primera columna con las marcas de los coches, 
#     "amc"           "audi"          "bmw"           "buick"         "cadillac"      "capri"         "chevroelt"     "chevrolet"    
#     "chevy"         "chrysler"      "citroen"       "datsun"        "dodge"         "fiat"          "ford"          "hi"           
#     "honda"         "maxda"         "mazda"         "mercedes"      "mercedes-benz" "mercury"       "nissan"        "oldsmobile"   
#     "opel"          "peugeot"       "plymouth"      "pontiac"       "renault"       "saab"          "subaru"        "toyota"       
#     "toyouta"       "triumph"       "vokswagen"     "volkswagen"    "volvo"         "vw"           
#   Al ser pocos, podemos ver que algunas marcas en particular tienen valores con ruido. Fácil de corregir a mano, pero si sería un primer problema.
# * Una segunda y tercera, que definen realmente el modelo
name.x <- data %>%
  separate(car.name, c("name1", "name2", "name3"), " ")
data$car.brand <- name.x$name1
sort(unique(data$car.brand))
# dplyr::filter(data, grepl('ford', car.brand))
# table(sort(data$car.brand))
data$car.brand[data$car.brand == 'toyouta']  <- "toyota" 
data$car.brand[data$car.brand == 'chevroelt']  <- "chevrolet" 
data$car.brand[data$car.brand == 'vokswagen']  <- "volkswagen" 
data$car.brand[data$car.brand == 'vw']  <- "volkswagen" 
data$car.brand[data$car.brand == 'maxda']  <- "mazda" 
# En este caso pasa que mercedes benz puede estar separado y quedo en la segunda columna
data$car.brand[data$car.brand == 'mercedes']  <- "mercedes-benz" 


png(filename="figure.png", width=1000, bg="white")
par(mar=c(8,8,4,1)+.1)
# barplot(c(1.1, 0.8, 0.7), horiz=TRUE, border="blue", axes=FALSE, col="darkblue")
# axis(2, at=1:3, lab=c("elephant", "hippo", "snorkel"), las=1, cex.axis=1.3)
barx <- barplot(table(sort(data$car.brand)),
                #col=unique(data$car.brand),
                # xlab = "Marcas",
                ylab = "Cant",
                ylim = c(0,60),
                main = "Cantidad de coches por marcas",
                xaxt="n")
text(x=barx, y=-9, unique(sort(data$car.brand)), xpd=TRUE, srt=90)
dev.off()

print("Treemap")
png(filename=paste("00-brands-representativity.png"))
brands <- as.data.frame(table(data$car.brand))
treemap(brands, index="Var1", vSize="Freq", type="index")
dev.off()



# Primer intento de boxplot
## Problema: Distintas escalas, no queda bien.
boxplot(data, use.cols = TRUE)
# Segundo intento, normalizando
no_na_data <- data %>% filter(!is.na(mpg)) %>% filter(!is.na(horsepower))
summary(no_na_data)

data_norm <- as.data.frame(apply(no_na_data[num_cols], 2, function(x) (x - min(x))/(max(x)-min(x))))


boxplot(data_norm, use.cols = TRUE)

#cols_names
# "mpg(3)" "cylinders" "displacement(25)" "horsepower(10)"   "weight(50)" "acceleration(3)" "model.year(1)" "origin(1)" car.name"   
# Histogramas
str(data)
unique(data$model.year)
dev.off()
ggplot(no_na_data, aes(x=car.name)) +
  geom_histogram( binwidth=1, fill="#000000", color="#000000", alpha=0.9) +
  ggtitle("Bin size = 3") +
  theme_ipsum() +
  theme(
    plot.title = element_text(size=15)
  )

## Correlación
png(filename=paste("Scatterplot.png"))
ggpairs(data[num_cols], title="correlogram with ggpairs()") 
dev.off()

# Ruidosos
plot(data$acceleration)

## Boxplot t IQR
### A manopla
data.riq <- IQR(data$acceleration)
print(data.riq)
cuantiles<-quantile(data$acceleration, c(0.25, 0.5, 0.75), type = 7)
print(cuantiles)
outliers_min<-as.numeric(cuantiles[1])-1.5*data.riq
print(outliers_min)
outliers_max<-as.numeric(cuantiles[3])+1.5*data.riq
print(outliers_max)
### Con info boxplot
bp = boxplot(data$acceleration)
out_inf = bp$stats[1]
out_sup = bp$stats[5]
cat("Extremo inferior", out_inf)
cat("Extremo superior", out_sup)

### Version sin recortar
plot(sort(data$acceleration))
### Versión recortando
plot(sort(data$acceleration[data$acceleration>outliers_min & data$acceleration<outliers_max]))

## Desvíos de la Media

N=3
desvio<-sd(data$acceleration)
print(desvio)
outliers_max<-mean(data$acceleration)+N*desvio
print(outliers_max)
outliers_min<-mean(data$acceleration)-N*desvio

plot(sort(data[data>outliers_min & data<outliers_max], decreasing = FALSE))

## Z-Score

data$zscore<-(data$acceleration-mean(data$acceleration))/sd(data$acceleration)
umbral<-2
max(data$zscore)
min(data$zscore)

plot(sort(data$acceleration[data$zscore<umbral], decreasing = FALSE))
boxplot(sort(data$acceleration[data$zscore<umbral], decreasing = FALSE))
### Tiende a pasar que recorto outliers, pero a partir de ahí se recalcula la media, el IQR, entonces vuelven a surgir outliers.



data_regresion <- data
# De donde saco el Modelo
# DEl plot de correlaciones, la mayor correlacion para mpg es weight. Que no es demasiado buena ya.
par(mfrow=c(1, 1))  # divide graph area in 2 columns
scatter.smooth(x=data_regresion$horsepower, y=data_regresion$displacement, main="HP ~ displacement")  # scatterplot

par(mfrow=c(1, 2))  # divide graph area in 2 columns
boxplot(data_regresion$horsepower, main="HP", sub=paste("Outlier rows: ", boxplot.stats(data_regresion$horsepower)$out))
boxplot(data_regresion$displacement, main="displacement", sub=paste("Outlier rows: ", boxplot.stats(data_regresion$displacement)$out))

library("e1071")
par(mfrow=c(1, 2))  # divide graph area in 2 columns
plot(density(no_na_data$horsepower), main="Density Plot: horsepower", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(no_na_data$mpg), 2))) 
polygon(density(no_na_data$horsepower), col="red")
plot(density(data_regresion$displacement), main="Density Plot: Displacement", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(data_regresion$weight), 2))) 
polygon(density(data_regresion$displacement), col="red")

# Leer: http://r-statistics.co/Linear-Regression.html
rl_model<-lm(data_regresion$horsepower ~ data_regresion$weight, data = data_regresion) #0.70
rl_model<-lm(data_regresion$horsepower ~ data_regresion$displacement, data = data_regresion) #0.80
rl_model<-lm(data_regresion$horsepower ~ data_regresion$displacement + data_regresion$weight, data = data_regresion) #0.81
rl_model<-lm(data_regresion$horsepower ~ data_regresion$displacement + data_regresion$weight + data_regresion$acceleration, data = data_regresion) #0.88

# Imprimimos los coeficientes del modelo
print(rl_model$coefficients)
summary(rl_model)




par(mfrow=c(1, 1))  # divide graph area in 2 columns
scatter.smooth(x=data_regresion$mpg, y=data_regresion$weight, main="HP ~ weight")  # scatterplot


par(mfrow=c(1, 2))  # divide graph area in 2 columns
boxplot(data_regresion$horsepower, main="HP", sub=paste("Outlier rows: ", boxplot.stats(data_regresion$horsepower)$out))
boxplot(data_regresion$weight, main="weight", sub=paste("Outlier rows: ", boxplot.stats(data_regresion$weight)$out))


par(mfrow=c(1, 2))  # divide graph area in 2 columns
plot(density(no_na_data$horsepower), main="Density Plot: Horsepower", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(no_na_data$mpg), 2))) 
polygon(density(no_na_data$horsepower), col="red")
plot(density(data_regresion$weight), main="Density Plot: Weight", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(data_regresion$weight), 2))) 
polygon(density(data_regresion$weight), col="red")


# Leer: http://r-statistics.co/Linear-Regression.html

rl_model<-lm(data_regresion$mpg ~ data_regresion$weight, data = data_regresion) #0.69

rl_model<-lm(data_regresion$mpg ~ data_regresion$weight + data_regresion$model.year, data = data_regresion) #0.8069
rl_model<-lm(data_regresion$mpg ~ data_regresion$weight + data_regresion$origin + data_regresion$model.year, data = data_regresion) #0.8169

rl_model<-lm(data_regresion$mpg ~ data_regresion$displacement, data = data_regresion) #0.64
rl_model<-lm(data_regresion$mpg ~ data_regresion$horsepower, data = data_regresion) #0.60
rl_model<-lm(data_regresion$mpg ~ data_regresion$displacement + data_regresion$weight, data = data_regresion) #0.69
rl_model<-lm(data_regresion$mpg ~ data_regresion$displacement + data_regresion$weight + data_regresion$horsepower, data = data_regresion) #0.704
rl_model<-lm(data_regresion$mpg ~ data_regresion$displacement + data_regresion$weight + data_regresion$acceleration, data = data_regresion) #0.698

# Imprimimos los coeficientes del modelo
print(rl_model$coefficients)
summary(rl_model)


# Hacemos la imputación
iris.imp$regresion[is.na(iris.imp$regresion)]<-coef[1]+SW*coef[2]+PL*coef[3]

# Verificamos que no existen faltantes
sum(is.na(iris.imp$regresion))
