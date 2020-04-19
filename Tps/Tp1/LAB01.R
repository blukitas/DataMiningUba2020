#TODO general: Comentar lo que veo en cada partecita.

print("Solucion Laboratorio 1:")

print("Import de librerías")
library("ggplot2")
library("readr")
library("dplyr")
library("highcharter")
library("treemap")
library("modeest")

print("Leemos el csv")
data <- read.csv('C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\Repo\\Practicos\\LAB01\\MPI_subnational.csv')

print("Ejercicio 1: Info relevante")
str(data)

print("Filas con NA")
no_na_data <- data %>% filter(!is.na(Intensity.of.deprivation.Regional))
print(data[rowSums(is.na(data)) > 0,])

print("Regiones")
levels(data$World.region)

# Regiones nombres cortos - Mejor para gráficos
data$region_corto <- strtrim(row.names(table(data$World.region)), 10)

# Columnas numéricas
numeric_columns <- names(data)[sapply(data, is.numeric)]

print("Estadísticos básicos de variables numéricas")
summary(data[,numeric_columns])

print("Cantidad de ciudades por región")
barx <- barplot(table(data$World.region), 
                col=unique(data$World.region),
                xlab = "Regiones",
                ylab = "Cant ciudades", 
                ylim = c(0,500),
                main="Cantidad de ciudades por regiones", 
                xaxt="n")
text(x=barx, y=-75, unique(data$region_corto), xpd=TRUE, srt=25)

print("También graficado de otra forma")
treemap(as.data.frame(table(data$World.region)), index="Var1", vSize="Freq", type="index")
# Proporcion de ciudades por region
prop.table(table(data$World.region))
# Pie de regiones en proporcion
pie(prop.table(table(data$World.region)))

print("Ejercicio 2: Medidas de posición")
print("Mediana")
mposMedian <- aggregate(MPI.National ~ World.region, data=data, FUN=median)
names(mposMedian)[2] <- 'MPI.National.Med'
mposMedian <- cbind(mposMedian, aggregate(MPI.Regional ~ World.region, data=data, FUN=median))
mposMedian[3] <- NULL
names(mposMedian)[3] <- 'MPI.Regional.Med'
mposMedian <- cbind(mposMedian, aggregate(Headcount.Ratio.Regional ~ World.region, data=data, FUN=median))
mposMedian[4] <- NULL
names(mposMedian)[4] <- 'Headcount.Ratio.Regional.Med'
mposMedian <- cbind(mposMedian, aggregate(Intensity.of.deprivation.Regional ~ World.region, data=data, FUN=median))
mposMedian[5] <- NULL
names(mposMedian)[5] <- 'Intensity.of.deprivation.Regional.Med'
print(mposMedian)

print("Media")
mposMean <- aggregate(MPI.National ~ World.region, data=data, FUN=mean)
names(mposMean)[2] <- 'MPI.National.Media'
mposMean <- cbind(mposMean, aggregate(MPI.Regional ~ World.region, data=data, FUN=mean))
mposMean[3] <- NULL
names(mposMean)[3] <- 'MPI.Regional.Media'
mposMean <- cbind(mposMean, aggregate(Headcount.Ratio.Regional ~ World.region, data=data, FUN=mean))
mposMean[4] <- NULL
names(mposMean)[4] <- 'Headcount.Ratio.Regional.Media'
mposMean <- cbind(mposMean, aggregate(Intensity.of.deprivation.Regional ~ World.region, data=data, FUN=mean))
mposMean[5] <- NULL
names(mposMean)[5] <- 'Intensity.of.deprivation.Regional.Media'

# Mode <- Create the function.
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

print("Moda")
mposMode <- aggregate(MPI.National ~ World.region, data=data, FUN=getmode)
names(mposMode)[2] <- 'MPI.National.Moda'
mposMode <- cbind(mposMode, aggregate(MPI.Regional ~ World.region, data=data, FUN=getmode))
mposMode[3] <- NULL
names(mposMode)[3] <- 'MPI.Regional.Moda'
mposMode <- cbind(mposMode, aggregate(Headcount.Ratio.Regional ~ World.region, data=data, FUN=getmode))
mposMode[4] <- NULL
names(mposMode)[4] <- 'Headcount.Ratio.Regional.Moda'
mposMode <- cbind(mposMode, aggregate(Intensity.of.deprivation.Regional ~ World.region, data=data, FUN=getmode))
mposMode[5] <- NULL
names(mposMode)[5] <- 'Intensity.of.deprivation.Regional.Moda'

# TODO: Ordenar, graficiar

print("Ejercicio 3: Medidas de dispersión")

for (var in numeric_columns) {
  cat(paste('Estadísticos de la columna: ', var, '\n'))
  cat(paste('\t * Desvio estándar: ', sd(no_na_data[[var]]), '\n'))
  cat(paste('\t * Varianza: ', var(no_na_data[[var]]), '\n'))
  cat(paste('\t * Rango:', range(no_na_data[[var]]), '\n'))
  
  png(filename=paste("box", var,"-.png"))
  boxplot(data[[var]] ~ data$World.region, main = "MPI por region", xlab="Region", ylab="MPI.National")
  dev.off()
}

print("Scatterplot, todos contra todos:")
# EL más básico
plot(data[numeric_columns])
