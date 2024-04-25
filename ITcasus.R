##package installeren
#install.packages("cbsodataR")
#install.packages("DBI")
#install.packages("RSQLite")
#install.packages("dbplyr")

library(cbsodataR)
library(tidyverse)
library(gridExtra)
library(DBI)
library(RSQLite)
library(dplyr)



#Casus 1: R
##stap 1:gegevens ophalen
toc <- cbs_get_toc()
#head(toc)
data <- cbs_get_data("83131NED")
#head(data)

##stap 2:gegevens ophalen en R-functie
#R-functie: CPIkwartaalmutatie
CPIkwartaalmutatie <- function(begindatum,einddatum,data){
  
  data <- data
  dd1 <- begindatum
  dd2 <- einddatum
  
  if (substr(dd1,5,6) == "q1") {
    dd1 <- paste('03','/','01','/',substr(dd1,1,4),sep ="") 
  } else if (substr(dd1,5,6) == "q2") {
    dd1 <- paste('06','/','01','/',substr(dd1,1,4),sep ="") 
  } else if (substr(dd1,5,6) == "q3") {
    dd1 <- paste('09','/','01','/',substr(dd1,1,4),sep ="") 
  } else {
    dd1 <- paste('12','/','01','/',substr(dd1,1,4),sep ="") 
  }
  
  if (substr(dd2,5,6) == "q1") {
    dd2 <- paste('03','/','01','/',substr(dd2,1,4),sep ="") 
  } else if (substr(dd2,5,6) == "q2") {
    dd2 <- paste('06','/','01','/',substr(dd2,1,4),sep ="") 
  } else if (substr(dd2,5,6) == "q3") {
    dd2 <- paste('09','/','01','/',substr(dd2,1,4),sep ="") 
  } else {
    dd2 <- paste('12','/','01','/',substr(dd2,1,4),sep ="") 
  }
  
  dd1 <- as.Date(dd1, "%m/%d/%Y")
  dd2 <- as.Date(dd2, "%m/%d/%Y")
  
  data1 <- data[(data$Bestedingscategorieen==unique(data$Bestedingscategorieen)[1]&grepl("MM",data$Perioden)),c("Perioden","CPI_1")]
  data1$Perioden2 <- paste(substr(data1$Perioden,7,8),'/','01','/',substr(data1$Perioden,1,4),sep ="")
  data1$Perioden2 <- as.Date(strptime(data1$Perioden2, "%m/%d/%Y"))
  data1 <- data1[order(data1$Perioden2),]
  
  data1$jaar <- substr(data1$Perioden,1,4)
  data1$maand <- substr(data1$Perioden,7,8)
  data1$Perioden1 <- paste(substr(data1$Perioden,7,8),'/',substr(data1$Perioden,1,4),sep ="")
  
  q = nrow(data1)/3
  z <- 1:q
  for (x in 1:q) {
    z[x] <- mean(data1$CPI_1[(3*x-2):(3*x)])
  }
  
  data1 <- data1[data1$maand %in% c("03","06","09","12"),]
  data1$kwartaalCPI <- z
  
  data1$kwartaalCPI2 <- c(0,data1$kwartaalCPI[1:(q-1)])
  data1$kwartaalmutatie <- round((data1$kwartaalCPI/data1$kwartaalCPI2-1)*100,1)
  
  
  data1 <- data1[(data1$Perioden2>=dd1 & data1$Perioden2<=dd2),]
  
  q = nrow(data1)
  z <- 1:q
  for (x in 1:q) {
    if (data1$maand[x] == "03") {
      z[x] <- paste(data1$jaar[x],'q1',sep ="") 
    } else if (data1$maand[x] == "06") {
      z[x] <- paste(data1$jaar[x],'q2',sep ="") 
    } else if (data1$maand[x] == "09") {
      z[x] <- paste(data1$jaar[x],'q3',sep ="") 
    } else {
      z[x] <- paste(data1$jaar[x],'q4',sep ="") 
    }
  }
  data1$Perioden3 <- z 
  
  data1 <- data1[,c("Perioden3","Perioden2","kwartaalmutatie")]
  
  return (data1)
}



##stap 3: grafieken en resultaten op in een lokale database
#voorbeeld
#grafieken
dd1 <- "1996q1"
dd2 <- "2000q4"
df1 <- CPIkwartaalmutatie(dd1,dd2,data)

dd1 <- "2001q1"
dd2 <- "2005q4"
df2 <- CPIkwartaalmutatie(dd1,dd2,data)

p1<-ggplot(df1, aes(x=Perioden2, y=kwartaalmutatie)) + geom_line(color='blue',size=0.5) +
  labs(title = "Kwartaalmutatie (1996q1-2000q4)", x= "Date", y= "Kwartaalmutatie") +
  scale_x_date(date_labels = "%m-%Y")

p2<-ggplot(df2, aes(x=Perioden2, y=kwartaalmutatie)) + geom_line(color='red',size=0.5) +
  labs(title = "Kwartaalmutatie (2001q1-2005q4)", x= "Date", y= "Kwartaalmutatie") +
  scale_x_date(date_labels = "%m-%Y")

grid.arrange(p1, p2, nrow=2)

#resultaten op in een lokale database
portaldb <- dbConnect(RSQLite::SQLite(), "./test.db")
dbWriteTable(portaldb,"dbdf1",df1)
dbWriteTable(portaldb,"dbdf2",df2)
#dbListTables(portaldb)


