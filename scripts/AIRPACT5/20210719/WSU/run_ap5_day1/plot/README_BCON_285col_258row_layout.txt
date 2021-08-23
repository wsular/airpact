# README on BCON file layout for perimiter values.  JKV  03/20/17

See document at https://www.cmascenter.org/cmaq/science_documentation/pdf/ch12.pdf

With NCOLS = 285, NROWS = 258, NTHIK = 1, the number of value is PERIM = 1090.

Assume we are interested in referencing BCON file values in both:
	 FORTRAN (array defined as farray(1:PERIM), and
 	 NCAR commmand language (array defined as narray(0:PERIM-1).
 
The layout of values for the perimeter by direction BCON are:
	Southern BCON = farray(1:285)  		and narray(0:284)
	Eastern BCON =  farray(287:544) 	and narray(286:543)
	Northern BCON = farray(547:831) 	and narray(546:830)
	Western BCON = farray(833:1090)		and narray(832:1089)

Dump (ncdump -h) on bcon file shows values for AIRPACT4 & 5 d4-km domains:
        LAY = 37 ;
        VAR = 49 ;
        PERIM = 1090 ;
                :EXEC_ID = "????????????????                                                                " ;
                :FTYPE = 2 ;
                :CDATE = 2017079 ;
                :CTIME = 50156 ;
                :WDATE = 2017079 ;
                :WTIME = 50156 ;
                :SDATE = 2017079 ;
                :STIME = 80000 ;
                :TSTEP = 10000 ;
                :NTHIK = 1 ;
                :NCOLS = 285 ;
                :NROWS = 258 ;
                :NLAYS = 37 ;
                :NVARS = 49 ;
                :GDTYP = 2 ;
                :P_ALP = 30. ;
                :P_BET = 60. ;
                :P_GAM = -121. ;
                :XCENT = -121. ;
                :YCENT = 49. ;
                :XORIG = -342000. ;
                :YORIG = -942000. ;
                :XCELL = 4000. ;
                :YCELL = 4000. ;
                :VGTYP = 7 ;
                :VGTOP = 5000.f ;
                :VGLVLS = 1.f, 0.995f, 0.99f, 0.9841f, 0.9772f, 0.9702f, 0.962f, 0.9525f, 0.9414f, 0.9284f, 0.9134f, 0.896f, 0.8759f, 0.8527f, 0.826f, 0.7955f, 0.7608f, 0.7218f, 0.6785f, 0.6309f, 0.5785f, 0.5213f, 0.4594f, 0.3953f, 0.336f, 0.2832f, 0.2363f, 0.1951f, 0.1595f, 0.1291f, 0.1031f, 0.0806f, 0.0612f, 0.0449f, 0.0312f, 0.0194f, 0.0091f, 0.f ;
                :GDNAM = "METCRO_AIRPACT_0" ;
                :UPNAM = "MechConv_mz4    " ;
                :VAR-LIST = "NR              PAR             IOLE            TERP            ETH             ETOH            ROOH            ETHA            OLE             AECJ            FORM            ALD2            MGLY            AACD            MEOH            MEPX            CH4             CO              CRES            DMS             ASOIL           ALDX            H2O2            HNO3            PNA             HO2             ISPD            ISOP            PANX            N2O5            NH3             ANO3J           ANH4J           NO2             NO              O3              AORGPAJ         AORGAJ          NTR             PAN             SO2             ASO4J           AORGBJ        
