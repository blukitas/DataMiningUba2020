# TP 1
print("Imports")
require(dplyr)
require(readr)
# library(readr)
# library(dplyr)

print("Leemos el csv")
data <- read.csv('C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\Repo\\Practicos\\LAB01\\MPI_subnational.csv')

print("Nombres del dataframe")
names(data)

print("Nombres y tipos de datos")
sapply(data, class)
sapply(data, typeof)

print("Obtenemos las columnas numéricas")
numeric_columns <- names(data)[sapply(data, is.numeric)]

print("Estadísticos básicos de variables numéricas")
summary(data[,numeric_columns])

print("Cantidad de ciudades por región")
data %>% count(World.region)

print("Gráfico de ciudades por región")
regiones <- data %>% count(World.region)
barplot(
       table(data$World.region), 
       xlab = "Regiones",
       ylab = "Cant ciudades", 
       ylim = c(0,500),
       main="Cantidad de ciudades por regiones") 

# Grafico ciudades x region
barx <- barplot(table(data$World.region), 
                col=c("lightgreen"),
                xlab = "Regiones",
                ylab = "Cant ciudades", 
                ylim = c(0,500),
                main="Cantidad de ciudades por regiones", 
                xaxt="n")
text(x=barx, y=-90, unique(data$World.region), xpd=TRUE, srt=70)

print("Medida posicion - Medianas")
mpos <- aggregate(MPI.National ~ World.region, data=data, FUN=median)
names(mpos)[2] <- 'MPI.National.Med'
mpos <- cbind(mpos, aggregate(MPI.Regional ~ World.region, data=data, FUN=median))
mpos[3] <- NULL
names(mpos)[3] <- 'MPI.Regional.Med'
mpos <- cbind(mpos, aggregate(Headcount.Ratio.Regional ~ World.region, data=data, FUN=median))
mpos[4] <- NULL
names(mpos)[4] <- 'Headcount.Ratio.Regional.Med'
mpos <- cbind(mpos, aggregate(Intensity.of.deprivation.Regional ~ World.region, data=data, FUN=median))
mpos[5] <- NULL
names(mpos)[5] <- 'Intensity.of.deprivation.Regional.Med'

print("Medida posicion - medias")
mpos <- cbind(mpos, aggregate(MPI.National ~ World.region, data=data, FUN=mean))
mpos[6] <- NULL
names(mpos)[6] <- 'MPI.National.Media'
mpos <- cbind(mpos, aggregate(MPI.Regional ~ World.region, data=data, FUN=mean))
mpos[7] <- NULL
names(mpos)[7] <- 'MPI.Regional.Media'
mpos <- cbind(mpos, aggregate(Headcount.Ratio.Regional ~ World.region, data=data, FUN=mean))
mpos[8] <- NULL
names(mpos)[8] <- 'Headcount.Ratio.Regional.Media'
mpos <- cbind(mpos, aggregate(Intensity.of.deprivation.Regional ~ World.region, data=data, FUN=mean))
mpos[9] <- NULL
names(mpos)[9] <- 'Intensity.of.deprivation.Regional.Media'

# Boxplot mpi nacional por regiones
boxplot(data$MPI.National~data$World.region, main = "MPI por region", xlab="Region", ylab="MPI.National")
