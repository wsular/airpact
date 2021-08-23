#!/usr/bin/python
# this reads smkreport monthly averaged outputs to create a summary table
# version 1.0 by Farren Herron-Thorpe; March 10, 2016

import csv

#Get the SCC Descriptions
SCCdict = eval(open('./SCC_T2_lookup.txt').read())
STATEdict = eval(open('./state_lookup.txt').read())

# Create output file
fout = open('./smkrpt_summary.csv','w')
fout.write('Sector,State,County,SourceDescription,CO,NH3,SO2,NOX,VOC,PM10,PM2_5,DSPM2_5,GASPM2_5\n')

#Process "all_other" sector
reader = csv.DictReader(open('./all_other_monthly_avg.csv'),delimiter=',')
SECTOR = 'all_other'
for row in reader:
    #Load County and SCC details
    FIPS = row['Region']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTierCode = row['SCCTier2']
    SCCTier2 = SCCdict[SCCTierCode]

    #Load Individual Species
    CO = float(row['S.CO'])
    NH3 = float(row['S.NH3'])
    PM10 = float(row['S.PM10'])
    SO2 = float(row['S.SO2'])

    #Load PM2.5 Tracers
    DSPM2_5 = float(row['S.T_DSPM2_5'])
    GASPM2_5 = float(row['S.T_GASPM2_5'])    

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process nonroad sector
reader = csv.DictReader(open('./nonroad_monthly_avg.csv'),delimiter=',')
SECTOR = 'nonroad'
for row in reader:
    #Load County and SCC details
    FIPS = row['Region']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTierCode = row['SCCTier2']
    SCCTier2 = SCCdict[SCCTierCode]

    #Load Individual Species
    CO = float(row['S.CO'])
    NH3 = float(row['S.NH3'])
    PM10 = float(row['S.PM10'])
    SO2 = float(row['S.SO2'])

    #Load PM2.5 Tracers
    DSPM2_5 = float(row['S.T_DSPM2_5'])
    GASPM2_5 = float(row['S.T_GASPM2_5'])    

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process rwc_tpy sector
reader = csv.DictReader(open('./rwc_tpy_monthly_avg.csv'),delimiter=',')
SECTOR = 'rwc_tpy'
for row in reader:
    #Load County and SCC details
    FIPS = row['Region']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTierCode = row['SCCTier2']
    SCCTier2 = SCCdict[SCCTierCode]

    #Load Individual Species
    CO = float(row['S.CO'])
    NH3 = float(row['S.NH3'])
    PM10 = float(row['S.PM10'])
    SO2 = float(row['S.SO2'])

    #Set PM2.5 Tracers to zero (not included in input file)
    DSPM2_5 = 0
    GASPM2_5 = 0

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process points sector
reader = csv.DictReader(open('./points_monthly_avg.csv'),delimiter=',')
SECTOR = 'points'
for row in reader:
    #Load County and SCC details
    FIPS = row['Region']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTierCode = row['SCCTier2']
    SCCTier2 = SCCdict[SCCTierCode]

    #Load Individual Species
    CO = float(row['S.CO'])
    NH3 = float(row['S.NH3'])
    PM10 = float(row['S.PM10'])
    SO2 = float(row['S.SO2'])

    #Load PM2.5 Tracers
    DSPM2_5 = float(row['S.T_DSPM2_5'])
    GASPM2_5 = float(row['S.T_GASPM2_5'])    

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 

    #Load VOC Species
    ALD2 = float(row['S.ALD2'])
    ALDX = float(row['S.ALDX'])
    ETH = float(row['S.ETH'])
    ETHA = float(row['S.ETHA'])
    ETOH = float(row['S.ETOH'])
    FORM = float(row['S.FORM'])
    IOLE = float(row['S.IOLE'])
    ISOP = float(row['S.ISOP'])
    OLE = float(row['S.OLE'])
    PAR = float(row['S.PAR'])
    TERP = float(row['S.TERP'])
    TOL = float(row['S.TOL'])
    XYL = float(row['S.XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process moves_rpd sector
reader = csv.DictReader(open('./moves_rpd_monthly_avg.csv'),delimiter=',')
SECTOR = 'moves_rpd'
for row in reader:
    #Load County and SCC details
    FIPS = row['FIPS']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTier2 = 'On-Roadway Mobile Emissions (e.g. from driving)'

    #Load Individual Species
    CO = float(row['CO'])
    NH3 = float(row['NH3'])

    SO2 = float(row['SO2'])

    #Set PM2.5 Tracers to zero (not included in input file)
    DSPM2_5 = 0
    GASPM2_5 = 0    

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 
    
    PMC = float(row['PMC'])
    PM10 = PM2_5+PMC

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process moves_rpp sector
reader = csv.DictReader(open('./moves_rpp_monthly_avg.csv'),delimiter=',')
SECTOR = 'moves_rpp'
for row in reader:
    #Load County and SCC details
    FIPS = row['FIPS']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTier2 = 'Off-Network Mobile Emissions (e.g. evaporation from fuel tanks of parked vehicles)'

    #Set Individual Species to zero (not included in input file)
    CO = 0
    NH3 = 0
    PM10 = 0
    SO2 = 0

    #Set PM2.5 Tracers to zero (not included in input file)
    DSPM2_5 = 0
    GASPM2_5 = 0    

    #Set NOx Species to zero (not included in input file)
    NOX = 0

    #Set PM2.5 Species to zero (not included in input file)
    PM2_5 = 0

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

#Process moves_rpv sector
reader = csv.DictReader(open('./moves_rpv_monthly_avg.csv'),delimiter=',')
SECTOR = 'moves_rpv'
for row in reader:
    #Load County and SCC details
    FIPS = row['FIPS']
    State = STATEdict[FIPS[0:3]]
    County = row['County']
    SCCTier2 = 'Off-Network Mobile Emissions (e.g. from parked vehicles starting, idling, or refueling)'

    #Load Individual Species
    CO = float(row['CO'])
    NH3 = float(row['NH3'])

    SO2 = float(row['SO2'])

    #Set PM2.5 Tracers to zero (not included in input file)
    DSPM2_5 = 0
    GASPM2_5 = 0    

    #Load NOx Species
    NO = float(row['NO'])
    NO2 = float(row['NO2'])
    NOX = NO+NO2

    #Load PM2.5 Species
    PAL = float(row['PAL'])
    PCA = float(row['PCA'])
    PCL = float(row['PCL'])
    PEC = float(row['PEC'])
    PFE = float(row['PFE'])
    PK = float(row['PK'])
    PMG = float(row['PMG'])
    PMN = float(row['PMN'])
    PMOTHR = float(row['PMOTHR'])
    PNA = float(row['PNA'])
    PNCOM = float(row['PNCOM'])
    PNH4 = float(row['PNH4'])
    PNO3 = float(row['PNO3'])
    POC = float(row['POC'])
    PSI = float(row['PSI'])
    PSO4 = float(row['PSO4'])
    PTI = float(row['PTI'])
    PM2_5 = PAL+PCA+PCL+PEC+PFE+PK+PMG+PMN+PMOTHR+PNA+PNCOM+PNH4+PNO3+POC+PSI+PSO4+PTI 

    PMC = float(row['PMC'])
    PM10 = PM2_5+PMC

    #Load VOC Species
    ALD2 = float(row['ALD2'])
    ALDX = float(row['ALDX'])
    ETH = float(row['ETH'])
    ETHA = float(row['ETHA'])
    ETOH = float(row['ETOH'])
    FORM = float(row['FORM'])
    IOLE = float(row['IOLE'])
    ISOP = float(row['ISOP'])
    OLE = float(row['OLE'])
    PAR = float(row['PAR'])
    TERP = float(row['TERP'])
    TOL = float(row['TOL'])
    XYL = float(row['XYL'])
    VOC = PAR+ETH*2+ETOH*2+OLE*2+TOL*7+XYL*8+FORM+ALD2*2+ISOP*5+ETHA*2+IOLE*4+ALDX*2+TERP*10

    lineOut = '"%s","%s","%s","%s",%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n' % (SECTOR, State, County, SCCTier2, CO, NH3, SO2, NOX, VOC, PM10, PM2_5, DSPM2_5, GASPM2_5)
    fout.write(lineOut)

fout.close()
