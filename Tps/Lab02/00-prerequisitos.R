# Cargo las librerias instaladas en un vector de chars
librerias_instaladas<-rownames(installed.packages())
libs_requeridas = c("ggplot2"
                    ,"readr"
                    ,"dplyr"
                    ,"highcharter"
                    ,"treemap"
                    ,"modeest"
                    ,"GGally");

for (c in libs_requeridas) {
  if(c %in% librerias_instaladas == FALSE) {
    install.packages(c, dependencies = TRUE)
  }
  library(c);
}
