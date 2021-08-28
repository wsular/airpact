# AIRPACT-5 Operations Issues

---
## 28 August 2021
### Reruns from 20210818 - 20210822
- Setup for 20210818
  - Determine daynumber for previous day using iPython: ```datetime(2021,8,17).strftime('%j') ```
  ```
  cd ~/AIRRUN/2021/2021081700/CCTM
  cp /data/lar/projects/airpact5/saved/2021/08/cgrid/CGRID_20210814.ncf CGRID_20210817.ncf
  setenv INFILE CGRID_20210817.ncf
  m3tshift
    <cr>    # Enter logical name for  INPUT FILE [INFILE] >>
    <cr>    # Enter starting (source) date (YYYYDDD) for run [YYYYDAY]>>
    <cr>    # Enter starting (source) time  (HHMMSS) for run [80000] >>
    2021229
    <cr>    # Enter target time  (HHMMSS) for run [80000] >>
    <cr>    # Enter output time step (HHMMSS) for run [10000] >>
    <cr>    # Enter duration (HHMMSS) for run [10000] >>
    <cr>    # Enter logical name for OUTPUT FILE [OUTFILE] >>
  mv CGRID_20210817.ncf CGRID_20210817.ncf.original
  mv OUTFILE CGRID_20210817.ncf
  ncdump -h CGRID_20210817.ncf | less        # Scroll to bottom to check dates; SDATE should be 2021229 for this case
  ``` 
  - Then start rerun
  ```
  cd ~/AIRHOME/run_ap5_day1
  master4all.csh 20210818 >&! logfile
  ```
  - To check job submissions
  ```
  qstatme
  ```

---
## 18 August 2021

### Issue
  - The VCEA IT group worked last night and needed to bring the power down to aeolus
    - This necessitated having to stop all existing jobs.
      - This caused several of the Day 1 runs to abort prematurely (I think...)
        - AP5pre timed out again while working on BCON

### Resolution
  - I restarted day 1 about 9:40 am (local)
    ```
    cd ~/AIRHOME/run_ap5_day1
    master4all.csh 20210817 >&! logfile
    ```

---
## 17 August 2021
### Issue
  - Very similar circumstances to 16 August 2021
    - Log files have similar entries
    - Runs seems to have gotten about the same way through
    - However, no plots were available this morning at 7:45 am (local)
      - I think this is because the day 2 run was not recognized by the web display yesterday, so nothing was available to plot for 20210821 once the runs failed earlier this morning

### Diagnosis
  - I really don't know why this is failing
    - But AP5pre failed again trying to run "anthropogenic emissions - nonmobile"
      ```
      -----------------------------------------
      run scripts for anthropogenic emissions

      **************************************************
      run SMOKE scripts for anthropogenic emissions - nonmobile
      =>> PBS: job killed: walltime 8471 exceeded limit 8460
      Terminated
      ```

### Resolution
  - I restarted both day 1 and day 2 just after 8 am (local)
    ```
    cd ~/AIRHOME/run_ap5_day1
    master4all.csh 20210817 >&! logfile
    cd ~/AIRHOME/run_ap5_day2
    ./master4all_day2.csh 20210817
    ```
    - All of the runs completed about 1330 (local); 5.5 hours
    - The Day 2 plots are still not available
      - I can see that the aconc plot files are not present
      - So I reran Day 2 yet again

---
## 16 August 2021

### Issue
  - Day 1 and Day 2 runs failed
    - Current web display shows Day 2 run from yesterday
### Diagnosis
  - Check logs in ~/AIRRUN/2021/2021081600
    - Only these directories were present:
      - BCON, EMISSION, JPROC, LOGS, and MCIP27
    - The available cluster logs files were (in chronological order):
      - AP5FIS20210816.o1343739
        - Many warnings of "WARNING: Failed to lookup fuelbed information"
          - From /usr/local/lib/python3.5/dist-packages/bluesky-4.2.1-py3.5.egg/bluesky/modules/fuelbeds.py
            - Couldn't find this script on aeolus, but found it at GitHub; [fuelbeds.py](https://github.com/pnwairfire/bluesky/blob/master/bluesky/modules/fuelbeds.py)
            - Error is thrown in fuelbeds.py because of [FccsLookUp](https://pypi.airfire.org/simple/fccsmap/)
              - Error might be related to the inability of the Python script to find "fccs_fuelload.nc" data file
              - Tried to locate this file on aeolus
        - End of script
        ```
        2021-08-16 05:31:25,510 WARNING: Failed to sum 'total' consumption for fire 202108090000_202108152359_46981942-230777306: 'consumption'
        2021-08-16 05:31:25,510 WARNING: Failed to sum 'flaming' consumption for fire 202108090000_202108152359_46981942-230777306: 'consumption'
        2021-08-16 05:31:25,510 WARNING: Failed to sum 'smoldering' consumption for fire 202108090000_202108152359_46981942-230777306: 'consumption'
        2021-08-16 05:31:25,510 WARNING: Failed to sum 'residual' consumption for fire 202108090000_202108152359_46981942-230777306: 'consumption'
        Status on singularity exec call is 0
        Good status on /home/airpact5/AIRHOME/run_ap5_day1/emis/fire_new/airpact_FIS_exec.csh
        end script: /var/spool/torque/mom_priv/jobs/1343739.mgt2-ib.local.SC Sun Aug 15 22:31:28 PDT 2021
        ```
      - AP5meg20210816.o1343740
          ```
          Warning: no access to tty (Bad file descriptor).
          Thus no job control in this shell.
          
          -----------------------------------------
          run MEGAN (parallel mode)
          end script: Sun Aug 15 22:38:12 PDT 2021
          ```
      - AP5fire20210816.o1343741
        ```
        Fire processing successfully completed on first attempt
        -rw-r--r-- 1 airpact5 lar 13603083128 Aug 15 23:51 /data/lar/projects/airpact5/AIRRUN/2021/2021081600/EMISSION/fire_can/smoke/pgts3d_l_2021228_1_AIRPACT_04km_fire.ncf
        ```
      - AP5pre20210816.o1343738
        ```
        run SMOKE scripts for anthropogenic emissions - MOVES
        =>> PBS: job killed: walltime 8497 exceeded limit 8460
        Terminated
        ```
      - Track down fuelbeds.py to see where it is trying to grab the BlueSky info from...
  - Conclusion
    - It looks as if the problems started early with information from BlueSky
    - It also seems as though the SMOKE scripts for MOVES timed out
      - This may be related to the initial error from BlueSky, but I'm not sure.
    - In any case, it seems as though the runs need to be resubmitted...

### Resolution
- According to Joe Vaughan's suggestion in email from 13 August 2021, I restarted the Day 1 runs
  ```
  cd ~/AIRHOME/run_ap5_day1
  master4all.csh 20210816 >&! logfile
  ```
  - The output from new version of AP5fire20210816.o1343855 contains
    ```
    Warning: no access to tty (Bad file descriptor).
    Thus no job control in this shell.

    -----------------------------------------
    run scripts for fire emission in the US using BlueSky Pipeline
    Found final fire emissions file
    /data/lar/projects/airpact5/AIRRUN/2021/2021081600/EMISSION/fire/smoke/pgts3d_l_2021228_1_AIRPACT_04km_fire.ncf
    run scripts for fire emission in Canada using BlueSky Canada
    found final fire emissions file
    /data/lar/projects/airpact5/AIRRUN/2021/2021081600/EMISSION/fire_can/smoke/pgts3d_l_2021228_1_AIRPACT_04km_fire.ncf
    ```
---
## 14 August 2021
### Issue
  - After yesterday's issue with the scheduler, all the jobs seem to have run properly overnight.
  - However, the Day 2 graphics again did not appear on the airpact website.
  - Email from Jen Hinds about status of graphics on aeolus
    ```
    On aeolus, I do not see any GIF images in the "aconc" folder for today's Day2 or yesterday's Day2:
    
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081500/IMAGES/aconc/hourly/gif
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081400/IMAGES/aconc/hourly/gif
    
    There is no ~/aconc/hourly/gif folder, which is where I'm expecting to find images.  The last Day2 "aconc" imagery was here:
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081300/IMAGES/aconc/hourly/gif
    
    I do see images for "emis" and "met" for today's Day2 and yesterday's Day2:
    
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081500/IMAGES/emis/gif
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081400/IMAGES/emis/gif
    
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081500/IMAGES/met/gif
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081400/IMAGES/met/gif
    
    Also, for the performance charts, this Day2 file does not exist:
    /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081500/POST/CCTM/AIRNowSites_20210815_v10.dat
    ```
    - To me, this looks as if part of the Day 2 run is finishing properly, but that the final graphics are not.
###  Diagnosis
  - Compared files in /home/airpact5/AIRHOME/run_ap5_day1 from 20210810 and 20210814 to see if they are different; searching for clues for why 20210814 failed
  - Check log files in Error_Path = aeolus.wsu.edu:/data/lar/projects/airpact5/AIRRUN/2021/2021081300/LOGS/
    - /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081400/IMAGES/aconc/hourly has no gifs; /data/lar/projects/airpact5/AIRRUN/2021/2021081400/IMAGES/aconc/hourly for Day 1 does have gifs
      - So the plotting for Day 2 failed (which is consistent with Jen's email)
    - There is no POST directory in /data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081400
### Resolution
  - As of 9:13 pm, this is still unresolved
  - This issue resolved itself overnight with the Day 1 and Day 2 runs performed on 15 August.

---
## 13 August 2021
### Issue
  - The Aeolus cluster failed on 13 August 2021 when someone attempted to start too many jobs.
    - This caused the scheduler queue to stop.
    - Some of the airpact jobs remained in either queued (Q) or held (H) status.
### Resolution
  - Andrew Bates eventually reset the scheduler queue, and the jobs began to run.
  - All of the jobs eventually finished.
### Remaining issue
  - However, the Day 2 graphics never appeared on the airpact website.
