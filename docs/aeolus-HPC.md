# Aeolus HPC

## Login Information

- Aeolus
  - WSU IP address = 134.121.120.166
    - Resolves to aeolus.wsu.edu
  - Account name for AIRPACT5 forecast model = "airpact5"
  - Password for AIRPACT5
    - Primary contact [Prof. Jun Meng](mailto:jun.meng@wsu.edu)
    - Secondary contact [Dr. Von P. Walden](mailto:v.walden@wsu.edu)
  - How to contact Aeolus support?
      - email vcea.support@wsu.edu
      - or open a support ticket at the VCEA IT help desk: https://it.vcea.wsu.edu/ 
- Rainier
  - UW IP address rainier.atmos.washington.edu
  - Account name = "empact"
  - Password for rainier
    - Primary contact [Prof. Jun Meng](mailto:jun.meng@wsu.edu)
    - Secondary contact [Dr. Von P. Walden](mailto:v.walden@wsu.edu)
  - Note that one can log onto rainier directly (with password) from aeolus using the command ```rainier```
  - How to get support?
      - Email David Owens (ovens@atmos.washington.edu or ovens@uw.edu)
      - Call David's office: 206-685-8108 

## Basic AIRPACT5 directory structure

- Notes
  - AIRPACT5 is actually run by a series of scripts that are initiated on rainier.atmos.washington.edu by the UW WRF system
    - /home/disk/rainier_empact/AQSIM_AIRPACT5_wMCIP5.1.pl
    - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY1_ssh_aeolus.csh
    - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY1.pl

  - AIRPACT5 is run as three separate forecasts for Days 1, 2 and 3.

### Code and scripts

- ==Main control script for AIRPACT5 - /home/airpact5/AIRHOME/run_ap5_day1/master4all.csh==

- Main directory - /home/airpact5/AIRHOME
  - Day 1 forecast - /home/airpact5/AIRHOME/run_ap5_day1
  - Day 2 forecast - /home/airpact5/AIRHOME/run_ap5_day2
  - Day 3 forecast - /home/airpact5/AIRHOME/run_ap5_day3

- Sub-directories for qsub submission scripts each forecast day under /home/airpact5/AIRHOME/run_ap5_dayX/
  - bcon - Boundary conditions (bcon) using MOZART
  - bcon_WACCM - Boundary conditions (bcon) using WACCM
  - blueprints - Templates (blueprints) for all qsub scripts (for submitting jobs to Aeolus cluster)
  - cctm - CCTM 
  - cleanup - Cleanup after successful forecast
  - emis - Emissions with additional sub-directories for anthro, fire_new, megan2.10, and merge
  - icon - Initial conditions
  - jproc - Photolysis-Rate Processor

### Log files

- Daily log files - /home/airpact5/AIRHOME/run_ap5_dayX/master4all_yyyymmdd.log
  - where X is 1, 2 or 3 for Day 1, 2 or 3

### Data

- Forecast data for days 1, 2, and 3 are contained in
  - Day 1 - /home/airpact5/AIRRUN
  - Day 2 - /home/airpact5/AIRRUNDAY2
  - Day 3 - /home/airpact5/AIRRUNDAY3
  - Note that these are symbolic links to
    - /data/lar/projects/airpact5/AIRRUN, ...
- The sub-directory structure for each forecast day is (for Day 1) /home/airpact5/AIRRUN/yyyy/yyyymmdd00
  - List of data sub-directories
    - BCON
      - output
        - bcon_cb05_yyyymmdd.ncf
    - CCTM
      - ACON_yyyymmdd.ncf
      - AERODIAM_yyyymmdd.ncf
      - AEROVIS_yyyymmdd.ncf
      - ==CGRID_yyyymmdd.ncf==
        - This file is needed for starting tomorrow's forecast
      - CONC_yyyymmdd.ncf
      - DRYDEP_yyyymmdd.ncf
      - WETDEP_yyyymmdd.ncf
    - EMISSION
      - anthro
        - moves
          - output
            - merged
              - mgts_l_moves_usa_canada.ncf
          - report
        - output
          - all_afdust
          - all_nodust
          - nonroad_model
          - point
          - rwc_tpy_method
          - seca
      - fire
        - bluesky
          - fire_events.csv
          - fire_locations.csv
          - fire_locations_yyyymmdd.kml
          - invent_ptday.txt
          - invent_ptinv.txt
          - output.json
          - ptday-yyyymmdd00.orl
          - ptinv-yyyymmdd00.orl
      - fire_can
        - bluesky
      - megan2.10
        - CB05_yyyymmdd.ncf
        - PFILE_yyyymmdd.ncf
      - merged
        - emis2d4plot.ncf
        - EMISSIONS_3D_AIRPACT_04km_yyyymmdd.ncf
    - IMAGES (used for website graphics)
      - aconc
        - ave08hr
        - ave24hr
        - hourly
      - aerovis
        - hourly
      - bcon
        - hourly
      - emis
        - gif
      - met
        - gif
    - JPROC
      - JTABLE_2025245
      - JTABLE_2025246
        - where 245 and 246 are the day numbers for today and tomorrow
    - ==LOGS - Detailed log files for all the various AIRPACT5 daily scripts==
      - bcon
      - cctm
      - emis
      - jproc
      - plot
      - post
    - MCIP37 (copied from empact@rainier.atmos.washington.edu)
      - GRIDBDY2D
      - GRIDDESC
      - GRIDCRO2D
      - GRIDDOT2D
      - LUFRAC_CRO
      - METBDY3D
      - METCRO3D
      - METCRO2D
      - METDOT3D
      - namelist.mcip
      - SOI_CRO
    - ==POST - Important output files==
      - CCTM
        - AIRNowSites_yyyymmdd_v10.dat
        - aod550nm2d_yyyymmdd.ncf
        - aod550nm3d_yyyymmdd.ncf
        - aqsid.csv
        - aqsid2025_master.csv
        - combined_yyyymmdd.ncf
        - combined3d_yyyymmdd.ncf
        - newaqsid.csv
        - O3_L01_08hr_yyyymmdd.ncf
        - onlyIDs.csv
        - PM25_24hr_yyyymmdd.json
        - PM25_L01_24hr_yyyymmdd.ncf
        - sed.txt
        - VR_miles_yyyymmdd.ncf

## [GitHub repo](https://github.com/wsular/airpact)

- CHANGELOGs - Contains changes made to code and scripts
- graphics - Flowchats for AIRPACT4 and AIRPACT5
- operations - Documents pertaining to AIRPACT5 Operations
- python - Python code for reading some AIRPACT5 output
- requests - Log of requests for AIRPACT5 data
- scripts - Copy of AIRPACT5 code and scripts as of 19 July 2021
  - Saved just after Joe Vaughan's retirement
- storage - Documents pertaining to storage on aeolus
