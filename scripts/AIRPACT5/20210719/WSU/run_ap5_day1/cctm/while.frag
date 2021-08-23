	 while ( ! -e $GC_ICpath/$GC_ICfile )
         	echo "no previous day CGRID to use for ICON ..wait 15 minutes"
	 	ls -lt ${GC_ICpath}
         	set loop_cnt = `expr ${loop_cnt} + 1`
         	echo Loop Count is ${loop_cnt}
	 	if ( ${loop_cnt} == 13 ) then
			echo Threer-hour Loop Ending With No CGRID File, Exiting
			exit(1)
	 	endif
         	sleep 900
	end
