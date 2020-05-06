# Lab 03

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
library("Rlof")
library("scatterplot3d")

## Leemos el txt

data <- read.table('C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Lab03\\ruidoso.txt', 
                   sep=',', header =TRUE, strip.white = T, stringsAsFactors = T)

str(data)
summary(data)
head(data)
data[1 ] <- NULL

num_cols <- names(data)[sapply(data, is.numeric)]

num_cols

print(data[rowSums(is.na(data)) > 0,])

no_na_data <- data %>% filter(!is.na(Industry_65dB))

# data_log$Road_55dB <- as.character(junk$Road_55dB)
no_na_data$Road_55dB[no_na_data$Road_55dB  == 0]  <- 0.0000001
no_na_data$Road_60dB[no_na_data$Road_60dB  == 0]  <- 0.0000001
no_na_data$Railways_65dB[no_na_data$Railways_65dB  == 0]  <- 0.0000001
no_na_data$Industry_65dB[no_na_data$Industry_65dB == 0]  <- 0.0000001

data_log <- as.data.frame(apply(no_na_data[num_cols], 2, log))
# Log de 0 no da, podemos agregar +0.00001 como para caretearla

boxplot(data_log, use.cols = TRUE, title="Boxplot")

ggpairs(data[num_cols], title="Correlograma") 
ggpairs(data_log[num_cols], title="Correlograma") 

plot(sort(data$Road_55dB))
plot(sort(data_log$Road_55dB))
plot(sort(data$Road_60dB))
plot(sort(data_log$Road_60dB))
plot(sort(data$Railways_65dB))
plot(sort(data_log$Railways_65dB))
plot(sort(data$Industry_65dB))
plot(sort(data_log$Industry_65dB))


## Boxplot t IQR
### A manopla
data_log.riq <- IQR(data_log$Road_55dB)
print(data_log.riq)
cuantiles<-quantile(data_log$Road_55dB, c(0.25, 0.5, 0.75), type = 7)
print(cuantiles)
outliers_min<-as.numeric(cuantiles[1])-1.5*data_log.riq
print(outliers_min)
outliers_max<-as.numeric(cuantiles[3])+1.5*data_log.riq
print(outliers_max)
### Con info boxplot
bp = boxplot(data_log$Road_55dB)
out_inf = bp$stats[1]
out_sup = bp$stats[5]
cat("Extremo inferior", out_inf)
cat("Extremo superior", out_sup)

### Version sin recortar
png(filename=paste("Outliers-IQR-with.png"))
plot(sort(data_log$Road_55dB))
dev.off()

### Versión recortando

png(filename=paste("Outliers-IQR-without.png"))
plot(sort(data_log$Road_55dB[data_log$Road_55dB>outliers_min & data_log$Road_55dB<outliers_max]))
dev.off()

## Desvíos de la Media

N=3
desvio<-sd(data_log$Road_55dB)
print(desvio)
outliers_max<-mean(data_log$Road_55dB)+N*desvio
print(outliers_max)
outliers_min<-mean(data_log$Road_55dB)-N*desvio


png(filename=paste("Outliers-DesvioMedia-without.png"))
plot(sort(data_log[data_log>outliers_min & data_log<outliers_max], decreasing = FALSE))
dev.off()
## Z-Score

data_log$zscore<-(data_log$Road_55dB-mean(data_log$Road_55dB))/sd(data_log$Road_55dB)
umbral<-2
max(data_log$zscore)
min(data_log$zscore)

png(filename=paste("Outliers-Z-core-n3-without.png"))
plot(sort(data_log$Road_55dB[data_log$zscore<umbral], decreasing = FALSE))
dev.off()
png(filename=paste("Boxplot-Z-score-n3-without.png"))
boxplot(sort(data_log$Road_55dB[data_log$zscore<umbral], decreasing = FALSE))
dev.off()
### Tiende a pasar que recorto outliers, pero a partir de ahí se recalcula la media, el IQR, entonces vuelven a surgir outliers.


## RLOF
data$score <- lof(data[num_cols], k=3)
umbral <- 4
data$outlier <- (data$score > umbral)
data$color <- ifelse(data$outlier, "red", "black")
# data$result_rlof <- na.omit(data[num_cols])


png(filename=paste("Outliers-rlof-k3-road55-without.png"))
plot(data$Road_55dB, col=data$color)
dev.off()

png(filename=paste("Outliers-rlof-k3-road60-without.png"))
plot(data$Road_60dB, col=data$color)
dev.off()

png(filename=paste("Outliers-rlof-k3-road55-60-without.png"))
plot(data$Road_55dB, data$Road_60dB, col=data$color)
dev.off()

png(filename=paste("Scatterplot3d-rlof-k3-road55-60-without.png"))
scatterplot3d(data$Road_55dB, data$Road_60dB, data$Railways_65dB, color = data$color)
dev.off()

## Distancia de Mahalanobis
no_na_data$mahalanobis <- mahalanobis(no_na_data[,num_cols], colMeans(no_na_data[,num_cols]), cov(no_na_data[,num_cols]))

# Ordenamos de forma decreciente, según el score de Mahalanobis
no_na_data <- no_na_data[order(no_na_data$mahalanobis,decreasing = TRUE),]

# Descartamos los outliers según un umbral
umbral<-8
no_na_data$outlier <- (no_na_data$mahalanobis > umbral)
no_na_data$color <- ifelse(no_na_data$outlier, "red", "black")


png(filename=paste("Outliers-mah-u8-road55-without.png"))
plot(no_na_data$Road_55dB, col=no_na_data$color)
dev.off()

png(filename=paste("Outliers-mah-u8-road60-without.png"))
plot(no_na_data$Road_60dB, col=no_na_data$color)
dev.off()

png(filename=paste("Outliers-mah-u8-road55-60-without.png"))
plot(no_na_data$Road_55dB, no_na_data$Road_60dB, col=no_na_data$color)
dev.off()



ggpairs(no_outliers[num_cols], title="Correlograma") 
ggpairs(data[num_cols], title="Correlograma") 

no_outliers <- no_na_data[no_na_data$outlier != TRUE, ]
no_outliers_log <- as.data.frame(apply(no_outliers[num_cols], 2, log))