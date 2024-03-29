library(hydroGOF)


getwd()
wd <-"H:/Masterarbeit/2_Data/3_fog_time_series/dsd/LWP/Integrals/"
setwd(wd)

fogEvent <- '20121019_20121020_Integrals.csv'
fogEventNr <- 7
Integrals <- read.table(fogEvent, header = T, sep=",")
breakPoints <-read.table('breakpoints_tempDyn.csv', header = T, sep=";") 

LWP.df <- data.frame(dateTime = as.POSIXct(Integrals$dateTime), 
                     LWP_ground = Integrals$LWP_ground, 
                     LWP_profile = Integrals$LWP_profile, 
                     LWP_measured_ground = Integrals$LWP_measured_ground,
                     LWP_measured_profile=Integrals$LWP_measured_profile)

ZIntegral.df <- data.frame(dateTime = as.POSIXct(Integrals$dateTime),
                           dBZ_ground = Integrals$dBZIntegral_ground, 
                           dBZ_profile = Integrals$dBZIntegral_profile, 
                           dBZ_measured = Integrals$dBZIntegral_measured)

LWPIntegral_ordered <- LWP.df[order(LWP.df[,1]),]
ZIntegral_ordered <- ZIntegral.df[order(ZIntegral.df[,1]),]
dateTime <- ZIntegral_ordered$dateTime
dateTime_LWP <- LWPIntegral_ordered$dateTime

LWPdiff_ground <- LWPIntegral_ordered$LWP_ground-LWPIntegral_ordered$LWP_measured_ground
LWPdiff_profile <- LWPIntegral_ordered$LWP_profile-LWPIntegral_ordered$LWP_measured_profile

diff_ground <- ZIntegral_ordered$dBZ_ground-ZIntegral_ordered$dBZ_measured
diff_profile <- ZIntegral_ordered$dBZ_profile-ZIntegral_ordered$dBZ_measured

LWPIntegral_ordered$dBZdiff_ground <- diff_ground
LWPIntegral_ordered$LWPdiff_ground <- LWPdiff_ground
LWPIntegral_ordered$LWPdiff_profile <- LWPdiff_profile

LWPIntegral_ordered[LWPIntegral_ordered$dBZdiff_ground==0 | 
                    LWPIntegral_ordered$dBZdiff_ground<(-4000),]<- NA

LWPIntegral_ordered$datetime <- dateTime
LWPIntegral_ordered$dateTime <- NULL

TSLength <- length(LWPIntegral_ordered$LWP_ground)

rmse1_2 <- rmse(LWPIntegral_ordered$LWP_ground[1:breakPoints[1,fogEventNr]],
                LWPIntegral_ordered$LWP_measured_ground[1:breakPoints[1,fogEventNr]],na.rm=T)

rmse2_2<- rmse(LWPIntegral_ordered$LWP_profile[1:breakPoints[1,fogEventNr]],
               LWPIntegral_ordered$LWP_measured_profile[1:breakPoints[1,fogEventNr]])

rmse1_3 <- rmse(LWPIntegral_ordered$LWP_ground[breakPoints[1,fogEventNr]:TSLength],
                LWPIntegral_ordered$LWP_measured_ground[breakPoints[1,fogEventNr]:TSLength])

rmse2_3 <- rmse(LWPIntegral_ordered$LWP_profile[breakPoints[1,fogEventNr]:TSLength],
                LWPIntegral_ordered$LWP_measured_profile[breakPoints[1,fogEventNr]:TSLength])

rmse1_total <- rmse(LWPIntegral_ordered$LWP_ground[1:TSLength],
                LWPIntegral_ordered$LWP_measured_ground[1:TSLength])
rmse2_total <- rmse(LWPIntegral_ordered$LWP_profile[1:TSLength],
                    LWPIntegral_ordered$LWP_measured_profile[1:TSLength])

######################################################################################################

par(mfrow=c(1,1), cex.axis=1, cex.main=1.5, cex.lab=1.5, mar=c(2,2,1,8.5), 
    oma =c(2,3,1,1),xpd=FALSE)
plot(LWPIntegral_ordered$datetime,
     LWPIntegral_ordered$LWPdiff_ground,
     ylab="",
     xlab="",
     ylim=c(-15,15),
     type = "l",   
     col ="black",
     xaxt="n")
abline(h=0,lty=21)
abline(v=LWPIntegral_ordered$datetime[breakPoints[1,fogEventNr]],lty=4)
abline(v=LWPIntegral_ordered$datetime[breakPoints[2,fogEventNr]],lty=4)

###### For 2 Segments #############################################
segmentAbstand <- 14.5
segments(LWPIntegral_ordered$datetime[1],segmentAbstand,LWPIntegral_ordered$datetime[breakPoints[1,fogEventNr]-1],
         segmentAbstand, lwd=1.5, col="grey20")
segments(LWPIntegral_ordered$datetime[breakPoints[1,fogEventNr]+1],segmentAbstand,
         LWPIntegral_ordered$datetime[length(LWPIntegral_ordered$datetime)],segmentAbstand,lwd=1.5,
         col="grey20")


lines(LWPIntegral_ordered$datetime, LWPIntegral_ordered$LWPdiff_profile,col="darkgrey")
points(LWPIntegral_ordered$datetime, LWPIntegral_ordered$LWPdiff_ground,pch=20)
points(LWPIntegral_ordered$datetime, LWPIntegral_ordered$LWPdiff_profile,pch=20, col="darkgrey")
axis.POSIXct(1, at=seq(LWPIntegral_ordered$datetime[1],
                       LWPIntegral_ordered$datetime[length(LWPIntegral_ordered$datetime)], 
                       by="hour"),format="%H")

mtext("Hour UTC", side=1, line=2.5)
mtext(bquote(paste("Difference to measured LWP [g"~m^-2~"]")), side=2, line = 2.8)
mtext("II", side =3, line = -1.1,adj=0,at=LWPIntegral_ordered$datetime[10])
mtext("III", side =3, line = -1.1,adj=0,at=LWPIntegral_ordered$datetime[39])
legend("bottom",inset=c(0.01,0.01),c("dsd_ground","dsd_profile"),
       col=c("black","darkgrey"),lty=c(1,1),pch=c(20,20),merge=TRUE, horiz=TRUE,cex=0.9)
par(xpd=TRUE)
legend("right",inset=c(-0.32,0),c('RMSE',
                                  paste('ground_total:',format(round(rmse1_total,2),nsmall=2)),
                                  paste('profile_total:',format(round(rmse2_total,2),nsmall=2)),
                                  paste('ground_I:',format(round(rmse1_2,2),nsmall=2)),
                                  paste('profile_I:',format(round(rmse2_2,2),nsmall=2)),
                                  paste('ground_II:',format(round(rmse1_3,2),nsmall=2)),
                                  paste('profile_II:',format(round(rmse2_3,2),nsmall=2)),
                                  lty=NULL),cex=0.9, bty="n",text.font=c(2,1,1,1,1,1,1,1,1))





