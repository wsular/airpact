sectors = c("nonroad", "points", "rwc_tpy", "seca", "all_other", "moves_rpd", "moves_rpp", "moves_rpv") # whatever categories you want

for (sc in sectors) { 
               daily_secfiles = dir(pattern= paste("^", sc, ".*\\.csv", sep=""), ignore.case =T)
               if (length(daily_secfiles) > 0) { 
                              sector_file = NULL
                              for (secfiles in daily_secfiles) {
                                             sector_file = rbind(sector_file, read.csv(secfiles, sep=";"))
                                             }
				print(paste(length(daily_secfiles), "reports used for", sc))
                              sector_file_aggregated = aggregate(sector_file[, -c(1:4)], list(sector_file[, 2], sector_file[,3], sector_file[,4]), function(x) { signif(mean(x, na.rm=T), 4) } )
                              names(sector_file_aggregated)[1:3] = names(sector_file)[2:4]
                              sector_file_aggregated[,1] = as.character(sprintf("%06d", as.numeric(sector_file_aggregated[,1])))
                              sector_file_aggregated = sector_file_aggregated[order(sector_file_aggregated[,1]), ] 
                              write.csv(sector_file_aggregated, paste(sc, "monthly_avg.csv", sep="_"), row.names=F, quote=T)
                              }
               }

