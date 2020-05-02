print("Solucion Laboratorio 2:")

print("Import de librerías")
library("ggplot2");
library("readr");
library("dplyr");
library("highcharter");
library("treemap"); # Gráfico treemap
library("modeest"); # Moda estimada
library("GGally");
library("infotheo"); # Discretize variable
library("sqldf"); # SQL para data frames
library("MASS"); # Chi2 en variables cualitativas



print("Leemos el csv")
sn <- read.csv("C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Lab02\\MPI_subnational.csv")
n <- read.csv("C:\\Users\\Lucas\\Desktop\\2019\\Data minning\\DataMiningUba2020\\Tps\\Lab02\\MPI_national.csv")


length(unique(n$Country))
length(unique(sn$Country))
setdiff(unique(n$Country), unique(sn$Country))

diff_paises

head(sn)
str(sn)
names(sn)
no_na_sn <- data %>% filter(!is.na(Intensity.of.deprivation.Regional))

head(n)
str(n)
names(n)

# Merge
df <- merge(n, sn, by.x = "ISO",  by.y = "ISO.country.code")
# Correcciones
df$Country.y <- NULL
names(df)[2] = "Country"


str(df)


# df minimalista
df_simple <- df
df_simple$ISO <- NULL
names(df_simple) <- c(
  "Country"                           
  , "Urban"                        
  , "R.Urban"             
  , "IOD.Urban"    
  , "Rural"                        
  , "R.Rural"             
  , "IOD.Rural"    
  , "Region"              
  , "World.region"                      
  , "National"                      
  , "Regional"                     
  , "R.Regional"          
  , "IOD.Regional")
str(df_simple)
num_simple <- names(df_simple)[sapply(df_simple, is.numeric)]
no_na_df <- df %>% filter(!is.na(Intensity.of.deprivation.Regional))
no_na_df_simple <- df_simple %>% filter(!is.na(IOD.Regional))
# Pais - Región - Región mundial tienden a lo mismo con distinta granularidad 

str(num_simple)
str(no_na_df_simple[num_simple])

head(df)
str(df)
summary(df)
names(df)

names(df) = 
# Columnas numéricas
numeric_columns <- names(df)[sapply(df, is.numeric)]

print("Estadísticos básicos de variables numéricas")
summary(df[,numeric_columns])


# Ejemplo slqdf para hacer SQL queries a un dataframe
join_string = "SELECT Country, ISO FROM n where ISO like '%CH%' "
sql_query = sqldf(join_string,stringsAsFactors = FALSE)
head(sql_query)

library(infotheo)

# Infotheo discretizacion
# Discretize recibe el atributo, el método de binning y la cantidad de bins
# Mas bins, más parecida queda la curva suavizada a la normal.
#   Con demasiado es la misma recta
bin_eq_freq <- discretize(n$Headcount.Ratio.Rural,"equalfreq", 50)

# Nos copiamos el atributo original
bin_eq_freq$Headcount.Ratio.Rural = n$Headcount.Ratio.Rural

# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:50){
  # Min más baja, onda escalera por debajo la curva.
  # bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = min(bin_eq_freq$Headcount.Ratio.Rural[ bin_eq_freq$X==bin])
  # Mean, la va siguiendo por el medio
  bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = mean(bin_eq_freq$Headcount.Ratio.Rural[ bin_eq_freq$X==bin])
  # Similar a mean pero un poco más abajo
  # bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = min(bin_eq_freq$Headcount.Ratio.Rural[ bin_eq_freq$X==bin])
}

# grafico Sepal.Width ordenado de menor a mayor
plot(sort(n$Headcount.Ratio.Rural) , type = "l", col="red", 
     ylab = "Headcount.Ratio.Rural", xlab = "Observaciones", main = "Dato original vs suavizado")
# Agrego la serie de la variable media 
lines(sort(bin_eq_freq$suavizado),
      type = "l", col="blue")
legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)


## Infotheo 2.
# Nos copiamos el atributo original
bin_eq_freq <- discretize(no_na_data$Headcount.Ratio.Regional,"equalfreq", 50)
bin_eq_freq$Headcount.Ratio.Regional = no_na_sn$Headcount.Ratio.Regional

# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:50){
  bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = mean(bin_eq_freq$Headcount.Ratio.Regional[ bin_eq_freq$X==bin])
}

# grafico Sepal.Width ordenado de menor a mayor
plot(sort(no_na_sn$Headcount.Ratio.Regional) , type = "l", col="red", 
     ylab = "Headcount.Ratio.Regional", xlab = "Observaciones", main = "Dato original vs suavizado")
# Agrego la serie de la variable media 
lines(sort(bin_eq_freq$suavizado),
      type = "l", col="blue")
legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)



print("Correlaciones")
cor(no_na_df_simple[num_simple], method = "pearson", use = "complete.obs")

png(filename=paste("Scatterplot.png"))
ggpairs(df_simple[num_simple], title="correlogram with ggpairs()") 
dev.off()

num_n <- names(n)[sapply(n, is.numeric)]
num_sn <- names(sn)[sapply(sn, is.numeric)]
ggpairs(n[num_n], title="correlogram with ggpairs()") 
ggpairs(sn[num_sn], title="correlogram with ggpairs()") 
plot(sn$MPI.Regional, sn$Headcount.Ratio.Regional * sn$Intensity.of.deprivation.Regional)


plot(df_simple$National, df_simple$R.Urban)
plot(df_simple$National, df_simple$R.Rural)
plot(df_simple$R.Urban, df_simple$R.Rural)
plot(df_simple$R.Regional, df_simple$R.Urban)
plot(df_simple$R.Regional, df_simple$R.Rural)

# Todos los plots
for (var in num_simple) {
  png(filename=paste("Plot-", var,"-.png"))
  
  plot(sort(no_na_df_simple[[var]]) , type = "p", col="red", 
     ylab = "Headcount.Ratio.Regional", xlab = "Observaciones", main = "Dato original vs suavizado")
  dev.off()
  
  png(filename=paste("BoxPlot-", var,"-.png"))
  p2<-ggplot(no_na_df_simple, aes(x=no_na_df_simple[[var]])) +
    geom_boxplot() +
    coord_flip()
  plot(p2)
  dev.off()
}
png(filename=paste("BoxPlot-Urban-.png"))
p2<-ggplot(no_na_df_simple, aes(x=no_na_df_simple$Urban)) +
  geom_boxplot() +
  coord_flip()
plot(p2)
dev.off()

# Discretizar para R.Urabno
bin_eq_freq <- discretize(no_na_df_simple$R.Urban,"equalfreq", 50)
bin_eq_freq$R.Urban = no_na_df_simple$R.Urban

# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:50){
  bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = mean(bin_eq_freq$R.Urban[ bin_eq_freq$X==bin])
}

# grafico Sepal.Width ordenado de menor a mayor
plot(sort(no_na_df_simple$R.Urban) , type = "p", col="red", 
     ylab = "R.Urban", xlab = "Observaciones", main = "Dato original vs suavizado")
# Agrego la serie de la variable media 
lines(sort(bin_eq_freq$suavizado),
      type = "p", col="blue")
legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)


# ------------ bIN FRECUENCIA
# Discretizar para R.Rural
bin_eq_freq <- discretize(no_na_df_simple$R.Rural,"equalfreq", 20)
bin_eq_freq$R.Rural = no_na_df_simple$R.Rural

# Por cada bin calculamos la media y reemplazamos en el atributo suavizado
for(bin in 1:20){
  bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = mean(bin_eq_freq$R.Rural[ bin_eq_freq$X==bin])
}

# grafico Sepal.Width ordenado de menor a mayor
plot(sort(no_na_df_simple$R.Rural) , type = "p", col="red", 
     ylab = "R.Rural", xlab = "Observaciones", main = "Dato original vs suavizado")
# Agrego la serie de la variable media 
lines(sort(bin_eq_freq$suavizado),
      type = "p", col="blue")
legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)
# ------------------------- bIN FRECUENCIA


# ------------ bIN width
# Discretizar para R.Rural
  bin_eq_freq <- discretize(no_na_df_simple$R.Rural,"equalwidth", 20)
  bin_eq_freq$R.Rural = no_na_df_simple$R.Rural
  
  # Por cada bin calculamos la media y reemplazamos en el atributo suavizado
  for(bin in 1:20){
    bin_eq_freq$suavizado[ bin_eq_freq$X==bin] = mean(bin_eq_freq$R.Rural[ bin_eq_freq$X==bin])
  }
  
  # grafico Sepal.Width ordenado de menor a mayor
  plot(sort(no_na_df_simple$R.Rural) , type = "p", col="red", 
       ylab = "R.Rural", xlab = "Observaciones", main = "Dato original vs suavizado")
  # Agrego la serie de la variable media 
  lines(sort(bin_eq_freq$suavizado),
        type = "p", col="blue")
  legend("topleft", legend=c("Original", "Suavizado"), col=c("red", "blue"), lty=1)
# ------------------------- bIN width

str(no_na_df_simple)
library(MASS)
tbl_cont = table(no_na_df_simple$Region, no_na_df_simple$Country)
print(tbl_cont)
chisq.test(tbl_cont)

plot(no_na_df_simple$Region,no_na_df_simple$Region)


