

#read.actigraph("agd file","time zone of the study")

read.acti <-function(x,tz="GMT",...){
options(java.parameters = "-Xmx1000m")
suppressWarnings(suppressMessages(if (!require(sqldf)){
      install.packages(pkgs="sqldf",repos="http://cran.r-project.org");
	require(sqldf)}))
suppressWarnings(suppressMessages(if (!require(XLConnect)){
      install.packages(pkgs="XLConnect",repos="http://cran.r-project.org");
	require(XLConnect)}))

suppressWarnings(suppressMessages(if (!require(PhysicalActivity)){
      install.packages(pkgs="PhysicalActivity",repos="http://cran.r-project.org");
	require(PhysicalActivity)}))

if(length(x)==1){
drv <- dbDriver("SQLite")
con <- dbConnect(drv, x)
ad.set <- dbReadTable(con,"settings")
ad.set <<- ad.set
origen<- as.POSIXct(as.character(as.POSIXlt((as.numeric(
  ad.set[grep("startdatetime",ad.set[,2]),3])/1e7),
  origin="0001-01-01 00:00:00", tz ="GMT")),tz=tz)
longitud <- as.numeric(ad.set[grep("epochcount",ad.set[,2]),3])

base <- dbReadTable(con, "data")
base$date <-origen+seq(from=0,by=10, length.out=longitud)
base <- base[c("date",names(base)[-c(1,dim(base)[2])])]
}

if(length(x)>1){
base <- do.call(rbind,lapply(x,function(y){
drv <- dbDriver("SQLite")
con <- dbConnect(drv, y)
ad.set <- dbReadTable(con,"settings")
ad.set <<- ad.set
origen<- as.POSIXct(as.character(as.POSIXlt((as.numeric(
  ad.set[grep("startdatetime",ad.set[,2]),3])/1e7),
  origin="0001-01-01 00:00:00", tz ="GMT")),tz=tz)
longitud <- as.numeric(ad.set[grep("epochcount",ad.set[,2]),3])

base <- dbReadTable(con, "data")
base$date <-origen+seq(from=0,by=10, length.out=longitud)
base <- base[c("date",names(base)[-c(1,dim(base)[2])])]
base
}))
base <- base[order(base$date),]
}

base2 <-pa.acti2(base,x)

res <- list(
  settings=ad.set,
  raw.data=base2[[1]],
  control=base2[[2]])

}


#########################################################################################
#########################################################################################

pa.acti2 <-function(ace,x){

suppressWarnings(suppressMessages(if (!require(PhysicalActivity)){
      install.packages(pkgs="PhysicalActivity",repos="http://cran.r-project.org");
	require(PhysicalActivity)}))

ace$cont<-1:dim(ace)[1]

ace$axis1.1  <- c(ace[2:dim(ace)[1],c("axis1")],NA)
ace$axis1.2  <- c(ace[3:dim(ace)[1],c("axis1")],rep(NA,2))
ace$axis1.3  <- c(ace[4:dim(ace)[1],c("axis1")],rep(NA,3))
ace$axis1.4  <- c(ace[5:dim(ace)[1],c("axis1")],rep(NA,4))
ace$axis1.5  <- c(ace[6:dim(ace)[1],c("axis1")],rep(NA,5))
ace$axis1._1 <- c(NA,ace[1:((dim(ace)[1])-1),c("axis1")])
ace$axis1._2 <- c(rep(NA,2),ace[1:((dim(ace)[1])-2),c("axis1")])
ace$axis1._3 <- c(rep(NA,3),ace[1:((dim(ace)[1])-3),c("axis1")])
ace$axis1._4 <- c(rep(NA,4),ace[1:((dim(ace)[1])-4),c("axis1")])
ace$axis1._5 <- c(rep(NA,5),ace[1:((dim(ace)[1])-5),c("axis1")])



sdf5<-apply(ace[,c("axis1","axis1.1","axis1.2","axis1.3","axis1.4","axis1.5")],1,sd)
meanf5<-apply(ace[,c("axis1","axis1.1","axis1.2","axis1.3","axis1.4","axis1.5")],1,mean)
ace$cvf5<-as.numeric(sdf5/meanf5)


sdf4<-apply(ace[,c("axis1._1","axis1","axis1.1","axis1.2","axis1.3","axis1.4")],1,sd)
meanf4<-apply(ace[,c("axis1._1","axis1","axis1.1","axis1.2","axis1.3","axis1.4")],1,mean)
ace$cvf4<-as.numeric(sdf4/meanf4)


sdf3<-apply(ace[,c("axis1._2","axis1._1","axis1","axis1.1","axis1.2","axis1.3")],1,sd)
meanf3<-apply(ace[,c("axis1._2","axis1._1","axis1","axis1.1","axis1.2","axis1.3")],1,mean)
ace$cvf3<-as.numeric(sdf3/meanf3)


sdf2<-apply(ace[,c("axis1._3","axis1._2","axis1._1","axis1","axis1.1","axis1.2")],1,sd)
meanf2<-apply(ace[,c("axis1._3","axis1._2","axis1._1","axis1","axis1.1","axis1.2")],1,mean)
ace$cvf2<-as.numeric(sdf2/meanf2)


sdf1<-apply(ace[,c("axis1._4","axis1._3","axis1._2","axis1._1","axis1","axis1.1")],1,sd)
meanf1<-apply(ace[,c("axis1._4","axis1._3","axis1._2","axis1._1","axis1","axis1.1")],1,mean)
ace$cvf1<-as.numeric(sdf1/meanf1)


sdb5<-apply(ace[,c("axis1._5","axis1._4","axis1._3","axis1._2","axis1._1","axis1")],1,sd)
meanb5<-apply(ace[,c("axis1._5","axis1._4","axis1._3","axis1._2","axis1._1","axis1")],1,mean)
ace$cvb5<-as.numeric(sdb5/meanb5)

ace$CV <- apply(ace[,c("cvb5","cvf1","cvf2","cvf3","cvf4","cvf5")],1,min)
ace$CV[is.na(ace$CV)]<-0


ace$mets[ace$axis1<=8] <- 1
ace$mets[ace$axis1>8 & ace$CV>10] <- 0.749395+(0.716431*(log(ace$axis1[ace$axis1>8 & ace$CV>10])))
						-(0.179874*(log(ace$axis1[ace$axis1>8 & ace$CV>10]))^2)+
						(0.033173*(log(ace$axis1[ace$axis1>8 & ace$CV>10]))^3)
ace$mets[ace$axis1>8 & ace$CV<=10] <- 2.294275*(exp(0.00084679*ace$axis1[ace$axis1>8 & ace$CV<=10]))


acti<-ace
rm(ace)
names(acti)[1]<-"date"
acti$date2 <- as.POSIXct(format(acti$date,format="%Y-%m-%d %H:%M"))
#acti2<-aggregate(subset(acti,select=c("mets")),by=list(acti$date2),FUN=mean)
acti2<-aggregate(mets~date2,data=acti,FUN=mean,na.rm=T)
names(acti2)<-c("date","mets.acti")
acti3<-aggregate(cbind(axis1,steps)~date2,data=acti,FUN=sum,na.rm=T)
names(acti3)<-c("date","axis1","steps")
acti4<-merge(acti3,acti2,by="date")

grup <- rle(acti4$axis1)

acti4$date.ch <- as.character(acti4$date)
acti4$wear <- wearingMarking(acti4,TS="date.ch",cts="axis1",perMinuteCts=1)$wearing

acti4$wearing<-acti4$mets.acti
acti4$wearing[acti4$wear=="nw"]<-NA

acti4$day <- format(acti4$date,format="%Y-%m-%d")
acti4$worn[!is.na(acti4$wearing)==T]<- "Wearing Device, hours"
acti4$time.pa[acti4$wearing>=1.5 & acti4$wearing<3 & !is.na(acti4$wearing)] <- "Light Physical Activity (1.5-3 METs), hours"
acti4$time.pa[acti4$wearing>=3 & acti4$wearing<6 & !is.na(acti4$wearing)] <- "Moderate Physical Activity (3-6 METs), hours"
acti4$time.pa[acti4$wearing>=6 & !is.na(acti4$wearing)] <- "Vigorous Physical Activity (>6 METs), hours"
acti4

#anado wearing & METs al raw.data
acti <- merge(acti,acti4[c("date","wearing")],by.x="date2",by.y="date",all.x=T)

# png(sub("agd","png",x),width = 800, height = 600)
# plot(acti4$date,acti4$mets.acti,type="l",xlab="Date",ylab="Intensity (METs)")
# dev.off()

WEARING <-as.data.frame(unclass(round(table(acti4$worn,acti4$day)/60,2)))
PA <-as.data.frame(unclass(round(table(acti4$time.pa,acti4$day)/60,2)))
STEPS <- with(acti4,tapply(steps,day,sum))
control <- rbind(WEARING,PA)
control$TOTAL <- rowSums (control, na.rm = FALSE, dims = 1)

res <- list(raw=acti,
            control=control)
res
}


