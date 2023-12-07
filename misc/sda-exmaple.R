library(soilDB)
library(rosettaPTF)

x <- SDA_query("SELECT TOP 100000 component.cokey, chorizon.chkey,
                  texture,
                  wtenthbar_l, wtenthbar_r, wtenthbar_h,
                  wthirdbar_l, wthirdbar_r, wthirdbar_h,
                  wfifteenbar_l, wfifteenbar_r, wfifteenbar_h,
                  ---wsatiated_l, wsatiated_r, wsatiated_h,
                  ksat_l, ksat_r, ksat_h,
                  awc_l, awc_r, awc_h,
                  sandtotal_l, sandtotal_r, sandtotal_h,
                  silttotal_l, silttotal_r, silttotal_h,
                  claytotal_l, claytotal_r, claytotal_h,
                  dbthirdbar_l, dbthirdbar_r, dbthirdbar_h
                 FROM component
                 INNER JOIN chorizon ON component.cokey = chorizon.cokey
                 INNER JOIN chtexturegrp ON chorizon.chkey = chtexturegrp.chkey AND rvindicator = 'Yes'")
x$id <- 1:nrow(x)
res <- run_rosetta(x[,c("sandtotal_r", "silttotal_r", "claytotal_r",
                 "dbthirdbar_r", "wthirdbar_r", "wfifteenbar_r")])
x <- merge(x, res, by = "id")
View(x)
x$ksat_pred_r <- 10^(x$log10_Ksat_mean) / 24 # cm/day -> cm/hr
x$ksat_pred_ratio <- x$ksat_pred_r / x$ksat_r
plot(x$ksat_r, x$ksat_pred_r, xlab="SSURGO (cm/h)",ylab="ROSETTA (cm/h)",
     xlim=c(0,100), ylim=c(0,100))
m<-lm(x$ksat_pred_r~x$ksat_r)
abline(m, lty=2)
abline(0,1)
summary(m)
x2 <- subset(x, !grepl("-|SR|BR|WB|DUR|VAR|PT|PM|GR|CB|FRAG|PEAT|SG|IND|CEM|GYP|CPF|MARL|G|CE|MUCK", x$texture))
plot(x2$ksat_pred_r~factor(x2$texture), ylim=c(0,200))
plot(x2$ksat_r~factor(x2$texture),ylim=c(0,200))
plot(x2$ksat_pred_ratio~factor(x2$texture))
