# AIRPACT5 Operational Workflow

- Note that the directory "/home/rainier_empact/" is the same as "/home/disk/rainier_empact/"
  - This is important because the disk system shows "/home/disk/rainier_empact/", but the AIRPACT5 scripts use "/home/rainier_empact/" (which is confusing...)

## AIRPACT5 log and error files

- This section lists the important log and error files to determine if AIRPACT5 ran correctly for a particular day.
  - /home/disk/rainier_empact/yyyymmdd00_AIRPACT.log
    - DAY 1
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY1.err
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY1.log
    - DAY 2
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY2.err
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY2.log
    - DAY 3
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY3.err
      - /home/disk/rainier_empact/airpact5/AIRPACT5_MCIP37_yyyymmdd00_DAY3.log

## AIRPACT5 control scripts

- This sections lists the main control scripts for running AIRPACT5 (on a daily basis). 
  - The AIRPACT5 scripts are initiated by empact@rainier.atmos.washington.edu by the University of Washington.
    - These scripts perform the following tasks:
      - Convert the daily UW WRF forecasts to MCIP format.
      - Copy the MCIP files to aeolus.wsu.edu at Washington State University.
      - Initiate the AIRPACT5 master4all.csh script for each of the 3-day forecasts (that runs AIRPACT5 on aeolus)

### Scripts run by empact@rainier.atmos.washington.edu

- Main AIRPACT5 control scripts
  - /home/disk/rainier_empact/AQSIM_AIRPACT.pl
    - Symbolic link: AQSIM_AIRPACT.pl -> AQSIM_AIRPACT5_wMCIP5.1.pl
    - /home/disk/rainier_empact/AQSIM_AIRPACT5_wMCIP5.1.pl

      - DAY 1
        - /home/disk/rainier_empact/AQSIM_MCIP5.1_AIRPACT5_DAY1.pl
          - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY1.pl
            - Run MCIP and copy files to aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/mcip/AP5_mcip5.1_37_DAY1.csh
            - Run AIRPACT5 on aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY1_ssh_aeolus.csh

      - DAY 2
        - /home/disk/rainier_empact/AQSIM_MCIP5.1_AIRPACT5_DAY2.pl
          - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY2.pl
            - Run MCIP and copy files to aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/mcip/AP5_mcip5.1_37_DAY2.csh
            - Run AIRPACT5 on aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY2_ssh_aeolus.csh

      - DAY 3
        - /home/disk/rainier_empact/AQSIM_MCIP5.1_AIRPACT5_DAY3.pl
          - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY3.pl
            - Run MCIP and copy files to aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/mcip/AP5_mcip5.1_37_DAY3.csh
            - Run AIRPACT5 on aeolus.wsu.edu
              - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY3_ssh_aeolus.csh

### Scripts run by airpact5@aeolus.wsu.edu

- The /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAYx_ssh_aeolus.csh scripts on rainier.atmos.washington.edu run the following scripts (via SSH) on aeolus.wsu.edu
  - DAY 1
    - /home/airpact5/AIRHOME/run_ap5_day1/master4all.csh
  - DAY 2
    - /home/airpact5/AIRHOME/run_ap5_day2/master4all_day2.csh
  - DAY 3
    - /home/airpact5/AIRHOME/run_ap5_day3/master4all_day3.csh

- ==!! These are the scripts that are used to rerun AIRPACT5 if the normal daily forecasts fail !!==
  - Note that one can specify which programs/scripts to run in each of the master4all scripts
  ```
  # all switches should be "Y" for daily operation
    set RUN_PRECCTM         = Y # JPROC, BCON, and anthropogenic emission
    set RUN_MEGAN_PARALLEL  = Y # added 2016-04-30
    set RUN_FIS_BSP_FIRES   = Y # added 2020-09-03
    set RUN_EMIS_FIRE_ORL   = Y # added 2016-04-30
    set RUN_EMIS_MERGE      = Y # added 2016-04-30
    set RUN_PLOT_BCON       = Y
    set RUN_PLOT_NONCCTM    = Y
    set RUN_CCTM            = Y
    set RUN_POSTCCTM        = Y
    set RUN_PLOT_CCTM       = Y
    set RUN_CLEANUP         = Y
  ```

  - As shown, all the switches should be "Y" (yes) for daily operation
  - But when AIRPACT5 needs to be rerun, one can set the switches to "N" (no) for each of the routines that were run successfully, then set the remaining switches to "Y" to rerun them.
