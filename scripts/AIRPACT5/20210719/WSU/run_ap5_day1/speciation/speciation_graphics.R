### And now we'll plot everything that the 'sitecompare' tool provides

## Agreed to plot a timeseries, Fractional Bias (bugle plot), Box plots of Model/ Monitor vs month 
## and modeled species fraction in PM2.5, with observed species fraction in PM2.5

## Read in ALL the CSV files Farren places in 'datadir' - redefine as necessary.


sitecmp_plotting_routine = function() { 


	suppressMessages(library(lattice))
	datadir <- "/home/airpact5/AIRHOME/run_ap5_day1/speciation"
	setwd(datadir)
	site_locations = read.csv("site_locations.csv")
#	site_locations = read.csv("site_locations_new.csv")



	na_strings = c("<Samp", "NoData", "Calib", "FailPwr", "RS232", "Spare", "Down", "Zero", "InVld", "Edit", 
"-_Shutdown", "+_Startup", "G_UOL", "UOL", "OutCal", "Span", "_", "Purge", "M", "MA", "#NAME?", "#DIV/0!", "#N/A", 
"#NULL!", "#NUM!", "#VALUE!", "#REF!", NA, "-999", "A", ".", "&nbsp;", "Void", "VOID", "-9999", "-99999", "void", 
"Maint", "maint", "UM", "<NA>", "None")

	sitecmp_files = NULL
	for (allsitecmp_files in dir(pattern="sitecmp_improve_csn.+\\.csv")) { 

		if(nrow(read.csv(allsitecmp_files, na.strings = na_strings, skip= 5, header=T)) > 0) { 

			sitecmp_file_data = read.csv(allsitecmp_files, na.strings = na_strings, skip= 6, header=F)
			sitecmp_file_headers = read.csv(allsitecmp_files, na.strings = na_strings, skip= 3, nrows=2)
			names(sitecmp_file_data) = gsub(paste(c("\\.1", "_NA", " ", "_$"), collapse="|")  , "", paste(names(sitecmp_file_headers), as.character(t(as.vector(sitecmp_file_headers[2,]))), sep="_"))
			sitecmp_files = rbind(sitecmp_files, sitecmp_file_data)
			}

		}

	if(nrow(sitecmp_files) == 0) { stop("No data present in input files") } 

	sitecmp_files$Date = as.Date(strptime(sitecmp_files$Time.On, "%m/%d/%Y"))
	sitecmp_files$Sitename = as.character(site_locations[match(sitecmp_files$SiteId, site_locations$SiteID), "Sitename2"])

	sitecmp_files$SiteId = as.character(sprintf("%09d", sitecmp_files$SiteId))

	sitecmp_files$seasons = ifelse(as.numeric(format(sitecmp_files$Date, "%m")) %in% 1:2, 1, ifelse(as.numeric(format(sitecmp_files$Date, "%m")) %in% 3:5, 2, ifelse(as.numeric(format(sitecmp_files$Date, "%m")) %in% 6:8, 3, ifelse(as.numeric(format(sitecmp_files$Date, "%m")) %in% 9:10, 4, 5))))


## Limit new comparisons to the most current year


	year_of_data = max(as.numeric(format(sitecmp_files$Date, "%Y")), na.rm=T)

	sitecmp_files = sitecmp_files[as.numeric(format(sitecmp_files$Date, "%Y")) == year_of_data, c("Sitename", "SiteId", "Date", "seasons", grep(paste(c("Observed", "Modeled"), collapse="|"), names(sitecmp_files), value=T, ignore.case=T))]





	the_species_list = unique(gsub(paste(c("_Observed", "_Modeled"), collapse="|"), "", names(sitecmp_files)[-c(1:4)]))

	for (SP in the_species_list) { 


		suppressWarnings(rm(list = ls(pat = paste(c("sitecmp_files_all", "only_this_site", "site_stats"), collapse="|"))))


		SP1 = if(SP == "PM25") { quote(PM[2.5]) 
				} else { if(SP == "PM_NO3") { 
					quote(PM~NO[3]) } else { if(SP == "PM_SO4") { 
						quote(PM~SO[4]) } else { if (SP == "PM_NH4") { 
							quote(PM~NH[4]) } else { gsub("_", " ", SP) 
						}
					}
				}
			}


		for (SN in unique(sitecmp_files$SiteId)) {

			suppressWarnings(rm(list = ls(pat = paste(c("sitecmp_files_all", "only_this_site", "site_stats"), collapse="|"))))

			only_this_site = sitecmp_files[sitecmp_files$SiteId == SN,]
			only_this_site = only_this_site[order(only_this_site$Date), ]
			only_this_site2 = only_this_site[only_this_site$PM25_Observed > 0,]

			only_this_site3 = na.omit(only_this_site[, c("Date", paste(SP, "Observed", sep="_"), paste(SP, "Modeled", sep="_"))])



## Timeseries plot

			if(nrow(only_this_site3) > 4) { 

				yrange_site = round(max(only_this_site3[, 2:3]), 1) * 1.3

				png(paste(SP, "_", SN, "_", year_of_data, "_timeline.png", sep=""), height=892, width= 1280, pointsize= 22)

				par(mar=c(5,5.5,3,2))

				with(only_this_site3, plot(Date, get(paste(SP, "Observed", sep="_")), pch=19, cex= 1.5, xlab="",ylab= "Concentration, µg/m³", main= substitute(SP23~"at"~SN1~"in"~year_of_data1, list(SN1= gsub("_", " ", SN), year_of_data1 = year_of_data, SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, ylim= c(0, yrange_site)))

				grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

				legend("top", col=1:2, text.col=1:2, pch= c(19, 22), legend=c("Observed", "Modeled"), ncol=2, cex=2)
				with(only_this_site3, points(Date, get(paste(SP, "Observed", sep="_")), pch=19, cex= 1.5))

				with(only_this_site3,points(Date, get(paste(SP, "Modeled", sep="_")), col=2, pch=22, cex=2) )


				dev.off()
				}

## Fractional bias plot, only considering days with measured PM2.5 > 0 ug/m3

			if(nrow(na.omit(only_this_site2)) > 4) { 

				png(paste(SP, "_", SN, "_", year_of_data, "_fracbias.png", sep=""), height=892, width= 1280, pointsize= 22)

				par(mar=c(5,5.5,3,2))

				with(only_this_site2, plot(get(paste(SP, "Observed", sep="_")), I(200*(get(paste(SP, "Modeled", sep="_"))- get(paste(SP, "Observed", sep="_")))/ (get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_")))), pch=19, cex= 1.5, ylab="Fractional bias, %", xlab= "Observed concentration, µg/m³", main= 
substitute(SP23~"at"~SN1~"in"~year_of_data1, list(SN1= gsub("_", " ", SN), year_of_data1 = year_of_data, 
SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, xlim= c(0,(yrange_site/1.15)), ylim=c(-200, 200),  col= seasons  ))


				grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

				curve( 170*exp(-x/0.5) + 30, 0, yrange_site/1.15, add=T, col=3, lwd=3 )

				curve( -170*exp(-x/0.5) - 30, 0, yrange_site/1.15, add=T, col=3, lwd=3)

				legend("topright", col=c(1:5)[sort(unique(only_this_site2$seasons))], text.col= 
c(1:5)[sort(unique(only_this_site2$seasons))], pch= 19, legend=
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sort(unique(only_this_site2$seasons))], ncol=2, bg="transparent", box.lty=0, cex=2)

				with(only_this_site2, points(get(paste(SP, "Observed", sep="_")), 
I(100*(get(paste(SP, "Modeled", sep="_"))- get(paste(SP, "Observed", sep="_")))/ get(paste(SP, "Observed", sep="_"))), pch=19, cex= 1.5, col= seasons  ))


				dev.off()


## Monthly model performance boxplots


				png(paste(SP, "_", SN, "_", year_of_data, "_boxplot.png", sep=""), height=892, width= 1280, pointsize= 22)

				par(mar=c(7,5.5,3,2))

				with(only_this_site2, boxplot(I(get(paste(SP, "Modeled", sep="_"))/ get(paste(SP, "Observed", sep="_"))) ~ factor(as.numeric(format(Date, "%m")), levels= 1:12, labels= month.abb), cex= 1.5, 
ylab="Model/ Observed ratio", xlab= "", main= substitute(SP23~"at"~SN1~"in"~year_of_data1, list(SN1= gsub("_", " ", SN), year_of_data1 = year_of_data, SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, ylim=c(0.1, 10),  log="y", las=2, yaxt="n", outline=FALSE  ))
				grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

				abline(h=1, untf=T, col= 3, lwd=2)

				with(only_this_site2, boxplot(I(get(paste(SP, "Modeled", sep="_"))/ get(paste(SP, "Observed", sep="_"))) ~ factor(as.numeric(format(Date, "%m")), levels= 1:12, labels= month.abb), cex= 1.5, cex.axis=2, ylim=c(0.1, 10),  log="y", las=2, add=T, ylab="", xlab="", yaxt="n", outline=FALSE  ))

				axis(2, at= c(0.1, 0.2, 0.5, 1, 2,5,10), labels= c(0.1, 0.2, 0.5, 1, 2,5,10), cex.axis=2)

				dev.off()





### Scatterplot of species fractions, measured vs modeled


				if( SP != "PM25") { 

					png(paste(SP, "_", SN, "_", year_of_data, "_scatter.png", sep=""), height=892, width= 1280, pointsize= 22)

					par(mar=c(5,5.5,3,2))

					with(only_this_site2, plot(I(get(paste(SP, "Modeled", sep="_"))/ PM25_Modeled) ~ 
I(get(paste(SP, "Observed", sep="_"))/ PM25_Observed), cex= 1.5, ylab=substitute("Modeled"~SP23*"/"~PM[2.5]~"ratio", 
list(SP23= SP1)), xlab= substitute("Observed"~SP23*"/"~PM[2.5]~"ratio", list(SP23= SP1)), main= 
substitute(SP23~"at"~SN1~"in"~year_of_data1, list(SN1= gsub("_", " ", SN), year_of_data1 = year_of_data, 
SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, pch=19, xlim=c(0,1), ylim=c(0,1), col= seasons  ))
					grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

					abline(0,1, col= 3, lwd=2)

					legend("topleft", col=c(1:5)[sort(unique(only_this_site2$seasons))], text.col= 
c(1:5)[sort(unique(only_this_site2$seasons))], pch= 19, legend= 
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sort(unique(only_this_site2$seasons))], ncol=2, bg="transparent", box.lty=0, cex=2)

					with(only_this_site2, points(I(get(paste(SP, "Modeled", sep="_"))/ PM25_Modeled) ~ 
I(get(paste(SP, "Observed", sep="_"))/ PM25_Observed), cex= 1.5, col= seasons, pch=19  ))


					dev.off()
					}


### Stacked barchart of modeled and measured seasonal means

				if( SP == "PM25") { 

					sitecmp_files_all3 = aggregate(only_this_site2[, grep(paste(c("Observed", "Modeled"), collapse="|"), names(only_this_site2), value=T, ignore.case=T)], list(only_this_site2$season), mean, na.rm=T)
					names(sitecmp_files_all3)[1] = "season"


					sitecmp_files_all3= data.frame(season= sitecmp_files_all3[, 1], 
data.frame(lapply(sitecmp_files_all3[, -1], function(X) ifelse(!is.finite(X), 0, X)) ))


					sitecmp_files_all3$PM25_remainder_Observed = sitecmp_files_all3$PM25_Observed - 
rowSums(sitecmp_files_all3[, c("PM_EC_Observed", "PM_OC_Observed", "PM_NO3_Observed", "PM_SO4_Observed", "PM_NH4_Observed")], na.rm=T)

					sitecmp_files_all3$PM25_remainder_Modeled = sitecmp_files_all3$PM25_Modeled - (sitecmp_files_all3$PM_EC_Modeled + sitecmp_files_all3$PM_OC_Modeled + sitecmp_files_all3$PM_NO3_Modeled + sitecmp_files_all3$PM_SO4_Modeled + sitecmp_files_all3$PM_NH4_Modeled)

					ylim_max = round(max(c(sitecmp_files_all3$PM25_Modeled, sitecmp_files_all3$PM25_Observed), na.rm=T) * 1.3, 1)
					sitecmp_files_all3$PM25_Modeled = sitecmp_files_all3$PM25_Observed = NULL

					sitecmp_files_all4 = data.frame(season = sitecmp_files_all3$season, sitecmp_files_all3[, grep("Observed", names(sitecmp_files_all3))])

					names(sitecmp_files_all4) = gsub("_Observed", "", names(sitecmp_files_all4))
					sitecmp_files_all4$Type = "Measured"

					sitecmp_files_all5 = data.frame(season = sitecmp_files_all3$season, sitecmp_files_all3[, grep("Modeled", names(sitecmp_files_all3))])

					names(sitecmp_files_all5) = gsub("_Modeled", "", names(sitecmp_files_all5))
					sitecmp_files_all5$Type = "Modeled"			

					sitecmp_files_all6 = rbind(sitecmp_files_all4, sitecmp_files_all5)
					sitecmp_files_all6$Lab1= paste(sitecmp_files_all6$season, sitecmp_files_all6$Type, sep="_")
					sitecmp_files_all6 = sitecmp_files_all6[order(sitecmp_files_all6$Lab1), ]
					sitecmp_files_all6$Type2 = ifelse(sitecmp_files_all6$Type == "Measured", "obs", "model")
					sitecmp_files_all6$Lab2 = paste(
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sitecmp_files_all6$season],sitecmp_files_all6$Type2, sep=": ")

					sitecmp_files_all6= sitecmp_files_all6[, c("Lab2", "PM25_remainder", "PM_OC", "PM_NO3", "PM_SO4", "PM_NH4", "PM_EC")]


					png(paste("PM25_", SN, "_", year_of_data, "_barchart.png", sep=""), height=892, width= 1280, pointsize= 22)

					par(mar=c(11,5,3,1))
					barplot(t(sitecmp_files_all6[, 2:7]), beside=F, names.arg = sitecmp_files_all6$Lab2, col= c(0, "cadetblue1", "#FFFFBFFF", 3, "#EDB48EFF", 8), las=2, space= c(3, 0.1), ylim=c(0,ylim_max), cex.names= 1.6, 
main = "", cex.lab=1.6, cex.main= 1.6, cex.axis=1.6, ylab="", xlab="")

					grid(NA, NULL, col = "lightgray", lty = "dashed", lwd=2)

					barplot(t(sitecmp_files_all6[, 2:7]), beside=F, names.arg = sitecmp_files_all6$Lab2, col= c(0, "cadetblue1", "#FFFFBFFF", 3, "#EDB48EFF", 8), las=2, space= c(3, 0.1), legend.text= rev(c("Other", "OC", 
expression(NO[3]), expression(SO[4]), expression(NH[4]), "EC")), args.legend=list(x="top", ncol= 6, cex= 1.6, fill= c(0,"cadetblue1", "#FFFFBFFF", 3, "#EDB48EFF", 8), bg="white"), ylim=c(0,ylim_max), cex.names= 1.6, 
main = substitute(bold("Seasonal means of"~PM[2.5]~"breakdown at"~SN1~"in"~year_of_data1), 
list(year_of_data1 = as.character(year_of_data), SN1= as.character(gsub("_", " ", SN)))), cex.lab=1.6, cex.main= 1.6, cex.axis=1.6, ylab=expression(PM[2.5]*", µg/m³"), xlab="", add=T)


					box()

					dev.off()

					}

				}


### Now the statistical tables

			site_stats = with(only_this_site, aggregate(get(paste(SP, "Observed", sep="_")), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, signif(mean(X, na.rm=T), 3), NA) } ))
				names(site_stats) = c("Season", "Observed_Mean")

			site_stats$Observed_Max = signif(with(only_this_site, aggregate(get(paste(SP, "Observed", sep="_")), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, max(X, na.rm=T), NA) } ))[,2], 3)

			site_stats$Mean_bias = signif(with(only_this_site, aggregate(I(get(paste(SP, "Modeled", sep="_")) - 
get(paste(SP, "Observed", sep="_"))), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, mean(X, na.rm=T), 
NA) } ))[,2],3)


			site_stats$Mean_error = signif(with(only_this_site, aggregate(I(abs(get(paste(SP, "Modeled", sep="_")) - get(paste(SP, "Observed", sep="_")))), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, mean(X, na.rm=T), NA) } ))[,2], 3)


			site_stats$Fractional_bias = signif(with(only_this_site, aggregate(I((get(paste(SP, "Modeled", sep="_")) - get(paste(SP, "Observed", sep="_")))/(get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_")))), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, mean(X, na.rm=T), NA) } ))[,2] * 2, 3)


			site_stats$Fractional_error = signif(with(only_this_site, aggregate(I(abs(get(paste(SP, "Modeled", 
sep="_")) - get(paste(SP, "Observed", sep="_")))/(get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_")))), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 4, mean(X, na.rm=T), NA) } ))[,2] * 2, 3)

			site_stats$Correlation_Coefficient_R2 = NA

			for (ssn1 in 1:(nrow(site_stats))) { 

				only_this_site_season = na.omit(only_this_site[only_this_site$seasons == as.numeric(site_stats[ssn1, "Season"]), c(paste(SP, "Modeled", sep="_"), paste(SP, "Observed", sep="_"))] )
				if(nrow(only_this_site_season) > 4) { 

					site_stats$Correlation_Coefficient_R2[ssn1] = 
signif(summary(with(only_this_site_season, lm(get(paste(SP, "Modeled", sep="_")) ~ get(paste(SP, "Observed", sep="_")))))$r.squared,3)
					}
				}

			site_stats$"Number_of_obs_&_model_data_pairs" = with(only_this_site, aggregate(I(get(paste(SP, 
"Modeled", sep="_")) - get(paste(SP, "Observed", sep="_"))), list(seasons), function(X) { Y= length(which(is.finite(X))); ifelse(Y > 4, Y, "<5") }))[,2]


			site_stats$Season = c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[site_stats$Season]
			write.csv(site_stats, paste(SP, "_", SN, "_", year_of_data, "_stats.csv", sep=""), na= "", row.names=F)
			}





###					 THE SAME PLOTS FOR ALL SITES NOW




		if(nrow(na.omit(sitecmp_files)) > 15 ) { 

			yrange_site = round(max(c(sitecmp_files[, paste(SP, "Observed", sep="_")], 
sitecmp_files[, paste(SP, "Modeled", sep="_")]), na.rm=T), 1) * 1.3


## Fractional bias plot, only considering days with measured PM2.5 > 0 ug/m3


			sitecmp_files_all2 = sitecmp_files[sitecmp_files$PM25_Observed > 0,]

			png(paste(SP, "_AllSites_", year_of_data, "_fracbias.png", sep=""), height=892, width= 1280, pointsize= 22)

			par(mar=c(5,5.5,3,2))

			with(sitecmp_files_all2, plot(jitter(get(paste(SP, "Observed", sep="_"))), I(jitter(200*(get(paste(SP, "Modeled", sep="_"))- get(paste(SP, "Observed", sep="_")))/ (get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_"))))), pch=21, cex= 1.5, ylab="Fractional bias, %", xlab= "Observed concentration, µg/m³", 
main= substitute(SP23~"at all sites in"~year_of_data1, list(year_of_data1 = year_of_data, 
SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, xlim= c(0,(yrange_site/1.15)), ylim=c(-200, 200),  col= seasons  ))

			grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

			curve( 170*exp(-x/0.5) + 30, 0, yrange_site/1.15, add=T, col=3, lwd=3 )

			curve( -170*exp(-x/0.5) - 30, 0, yrange_site/1.15, add=T, col=3, lwd=3)

			legend("topright", col=c(1:5)[sort(unique(sitecmp_files_all2$seasons))], text.col= 
c(1:5)[sort(unique(sitecmp_files_all2$seasons))], pch= 21, legend=
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sort(unique(sitecmp_files_all2$seasons))], ncol=2, bg="transparent", box.lty=0, cex=2)

			with(sitecmp_files_all2, points(jitter(get(paste(SP, "Observed", sep="_"))), 
I(jitter(100*(get(paste(SP, "Modeled", sep="_"))- get(paste(SP, "Observed", sep="_")))/ get(paste(SP, "Observed", sep="_")))), pch=21, cex= 1.5, col= seasons  ))

			dev.off()


## Monthly model performance boxplots


			png(paste(SP, "_AllSites_", year_of_data, "_boxplot.png", sep=""), height=892, width= 1280, pointsize= 22)

			par(mar=c(7,5.5,3,2))

			with(sitecmp_files_all2, boxplot(I(get(paste(SP, "Modeled", sep="_"))/ get(paste(SP, "Observed", sep="_"))) ~ factor(as.numeric(format(Date, "%m")), levels= 1:12, labels= month.abb), cex= 1.5, 
ylab="Model/ Observed ratio", xlab= "", main= substitute(SP23~"at all sites in"~year_of_data1, 
list(year_of_data1 = year_of_data, SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, 
ylim=c(0.1, 10),  log="y", las=2, yaxt="n", outline=FALSE    ))
			grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

			abline(h=1, untf=T, col= 3, lwd=2)
			axis(2, at= c(0.1, 0.2, 0.5, 1, 2,5,10), labels= c(0.1, 0.2, 0.5, 1, 2,5,10), cex.axis=2)

			with(sitecmp_files_all2, boxplot(I(get(paste(SP, "Modeled", sep="_"))/ get(paste(SP, "Observed", sep="_"))) ~ factor(as.numeric(format(Date, "%m")), levels= 1:12, labels= month.abb), cex= 1.5, 
ylab="Model/ Observed ratio", xlab= "", main= substitute(SP23~"at all sites in"~year_of_data1, 
list(year_of_data1 = year_of_data, SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, 
ylim=c(0.1, 10),  log="y", las=2, yaxt="n", add=T, outline=FALSE    ))


			dev.off()





### Scatterplot of species fractions, measured vs modeled


			if( SP != "PM25") { 

				png(paste(SP, "_AllSites_", year_of_data, "_scatter.png", sep=""), height=892, width= 1280, pointsize= 22)

				par(mar=c(5,5.5,3,2))

				with(sitecmp_files_all2, plot(I(jitter(get(paste(SP, "Modeled", sep="_"))/ PM25_Modeled)) ~ 
I(jitter(get(paste(SP, "Observed", sep="_"))/ PM25_Observed)), cex= 1.5, ylab= substitute("Modeled"~SP23*"/"~PM[2.5]~"ratio", list(SP23= SP1)), xlab= substitute("Observed"~SP23*"/"~PM[2.5]~"ratio", list(SP23= SP1)), 
main= substitute(SP23~"at all sites in"~year_of_data1, list(year_of_data1 = year_of_data, 
SP23= SP1)), cex.lab=2, cex.main= 2, cex.axis=2, pch=21, xlim=c(0,1), ylim=c(0,1), col= seasons))

				grid(NULL, NULL, col = "lightgray", lty = "dashed", lwd=2)

				abline(0,1, col= 3, lwd=2)

				legend("topleft", col=c(1:5)[sort(unique(sitecmp_files_all2$seasons))], text.col= 
c(1:5)[sort(unique(sitecmp_files_all2$seasons))], pch= 21, legend=
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sort(unique(sitecmp_files_all2$seasons))], ncol=2, bg="transparent", box.lty=0, cex=2)

				with(sitecmp_files_all2, points(I(jitter(get(paste(SP, "Modeled", sep="_"))/ PM25_Modeled)) ~ 
I(jitter(get(paste(SP, "Observed", sep="_"))/ PM25_Observed)), cex= 1.5, col= seasons))
		
				dev.off()
				}

			

### Stacked barchart of modeled and measured seasonal means


			if( SP == "PM25") { 

				sitecmp_files_all3 = aggregate(sitecmp_files_all2[, grep(paste(c("Observed", "Modeled"), collapse="|"), names(sitecmp_files_all2), value=T, ignore.case=T)], list(sitecmp_files_all2$season), mean, na.rm=T)
				names(sitecmp_files_all3)[1] = "season"


				sitecmp_files_all3= data.frame(season= sitecmp_files_all3[, 1], 
data.frame(lapply(sitecmp_files_all3[, -1], function(X) ifelse(!is.finite(X), 0, X))))


				sitecmp_files_all3$PM25_remainder_Observed = sitecmp_files_all3$PM25_Observed - 
rowSums(sitecmp_files_all3[, c("PM_EC_Observed", "PM_OC_Observed", "PM_NO3_Observed", "PM_SO4_Observed", "PM_NH4_Observed")], na.rm=T)

				sitecmp_files_all3$PM25_remainder_Modeled = sitecmp_files_all3$PM25_Modeled - (sitecmp_files_all3$PM_EC_Modeled + sitecmp_files_all3$PM_OC_Modeled + sitecmp_files_all3$PM_NO3_Modeled + sitecmp_files_all3$PM_SO4_Modeled + sitecmp_files_all3$PM_NH4_Modeled)

				ylim_max = round(max(c(sitecmp_files_all3$PM25_Modeled, sitecmp_files_all3$PM25_Observed), na.rm=T) * 1.3, 1)
				sitecmp_files_all3$PM25_Modeled = sitecmp_files_all3$PM25_Observed = NULL
	
				sitecmp_files_all4 = data.frame(season = sitecmp_files_all3$season, sitecmp_files_all3[, grep("Observed", names(sitecmp_files_all3))])

				names(sitecmp_files_all4) = gsub("_Observed", "", names(sitecmp_files_all4))
				sitecmp_files_all4$Type = "Measured"
	
				sitecmp_files_all5 = data.frame(season = sitecmp_files_all3$season, sitecmp_files_all3[, grep("Modeled", names(sitecmp_files_all3))])

				names(sitecmp_files_all5) = gsub("_Modeled", "", names(sitecmp_files_all5))
				sitecmp_files_all5$Type = "Modeled"			

				sitecmp_files_all6 = rbind(sitecmp_files_all4, sitecmp_files_all5)
				sitecmp_files_all6$Lab1= paste(sitecmp_files_all6$season, sitecmp_files_all6$Type, sep="_")
				sitecmp_files_all6 = sitecmp_files_all6[order(sitecmp_files_all6$Lab1), ]
				sitecmp_files_all6$Type2 = ifelse(sitecmp_files_all6$Type == "Measured", "obs", "model")
				sitecmp_files_all6$Lab2 = paste(
c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[sitecmp_files_all6$season],sitecmp_files_all6$Type2, sep=": ")


				sitecmp_files_all6= sitecmp_files_all6[, c("Lab2", "PM25_remainder", "PM_OC", "PM_NO3", "PM_SO4", "PM_NH4", "PM_EC")]


				png(paste("PM25_AllSites_", year_of_data, "_barchart.png", sep=""), height=892, width= 1280, pointsize= 22)

				par(mar=c(11,5,3,1))


				barplot(t(sitecmp_files_all6[, 2:7]), beside=F, names.arg = sitecmp_files_all6$Lab2, col= 
c(0, "cadetblue1","#FFFFBFFF", 3, "#EDB48EFF", 8), las=2, space= c(3, 0.1), ylim=c(0,ylim_max), cex.names= 1.6, main = "", cex.lab=1.6, cex.main= 1.6, cex.axis=1.6, ylab="", xlab="")

				grid(NA, NULL, col = "lightgray", lty = "dashed", lwd=2)

				barplot(t(sitecmp_files_all6[, 2:7]), beside=F, names.arg = sitecmp_files_all6$Lab2, col= 
c(0, "cadetblue1","#FFFFBFFF", 3, "#EDB48EFF", 8), las=2, space= c(3, 0.1), legend.text= rev(c("Other", "OC", 
expression(NO[3]), expression(SO[4]), expression(NH[4]), "EC")), args.legend=list(x="top", ncol= 6, cex= 1.6, bg="white",fill=c(0, "cadetblue1","#FFFFBFFF", 3, "#EDB48EFF", 8) ), ylim=c(0,ylim_max), cex.names= 1.6, main = 
substitute(bold("Seasonal means of"~PM[2.5]~"breakdown at all sites in"~year_of_data1), 
list(year_of_data1 = as.character(year_of_data))), cex.lab=1.6, cex.main= 1.6, cex.axis=1.6, 
ylab=expression(PM[2.5]*", µg/m³"), xlab="", add=T)

				box()

				dev.off()

				}

			}
	

### Now lets do some stats based on the whole dataset


			site_stats = with(sitecmp_files, aggregate(get(paste(SP, "Observed", sep="_")), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, signif(mean(X, na.rm=T),3), NA) } ))
			names(site_stats) = c("Season", "Observed_Mean")

			site_stats$Observed_Max = signif(with(sitecmp_files, aggregate(get(paste(SP, "Observed", sep="_")), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, max(X, na.rm=T), NA) } ))[,2], 3)


			site_stats$Mean_bias = signif(with(sitecmp_files, aggregate(I(get(paste(SP, "Modeled", 
sep="_")) - get(paste(SP, "Observed", sep="_"))), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, mean(X, na.rm=T), NA) } ))[,2],3)


			site_stats$Mean_error = signif(with(sitecmp_files, aggregate(I(abs(get(paste(SP, "Modeled", 
sep="_")) - get(paste(SP, "Observed", sep="_")))), list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, mean(X, na.rm=T), NA) } ))[,2], 3)


			site_stats$Fractional_bias = signif(with(sitecmp_files, aggregate(I((get(paste(SP, "Modeled", sep="_")) - get(paste(SP, "Observed", sep="_")))/(get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_")))), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, mean(X, na.rm=T), NA) } ))[,2] * 2, 3)


			site_stats$Fractional_error = signif(with(sitecmp_files, aggregate(I(abs(get(paste(SP, "Modeled", 
sep="_")) - get(paste(SP, "Observed", sep="_")))/(get(paste(SP, "Modeled", sep="_")) + get(paste(SP, "Observed", sep="_")))), 
list(seasons), function(X) { ifelse(length(which(is.finite(X))) > 14, mean(X, na.rm=T), NA) } ))[,2] * 2, 3)


			site_stats$Correlation_Coefficient_R2 = NA

			for (ssn1 in 1:(nrow(site_stats))) { 

				sitecmp_files_all_season = na.omit(sitecmp_files[sitecmp_files$seasons == 
as.numeric(site_stats[ssn1, "Season"]), c(paste(SP, "Modeled", sep="_"), paste(SP, "Observed", sep="_"))] )
				if(nrow(sitecmp_files_all_season) > 14) { 

					site_stats$Correlation_Coefficient_R2[ssn1] = 
signif(summary(with(sitecmp_files_all_season, lm(get(paste(SP, "Modeled", sep="_")) ~ get(paste(SP, "Observed", sep="_")))))$r.squared, 3)
					}
				}

			site_stats$"Number_of_obs_&_model_data_pairs" = with(sitecmp_files, aggregate(I(get(paste(SP, 
"Modeled", sep="_")) - get(paste(SP, "Observed", sep="_"))), list(seasons), function(X) { Y= length(which(is.finite(X))); ifelse(Y > 14, Y, "<15") }))[,2]


			site_stats$Season = c("Jan-Feb", "Mar-May", "Jun-Aug", "Sep-Oct", "Nov-Dec")[site_stats$Season]
			write.csv(site_stats, paste(SP, "_AllSites_", year_of_data, "_stats.csv", sep=""), na= "", row.names=F)
			

		}



	detach("package:lattice")
	}



sitecmp_plotting_routine()
