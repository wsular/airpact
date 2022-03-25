# AIRPACT-5 Operations Issues
## How to Setup AIRPACT5 to rerun
- The primary control script for the AIRPACT5 modeling system on aeolus.wsu.edu is:
  - /home/airpact5/AIRHOME/run_ap5_day1/master4all.csh

- To rerun this script
  1. Edit the switches in master4all.csh to select where to start the run
  2. Execute "./master4all.csh YYYYMMDD" from /home/airpact5/AIRHOME/run_ap5_day1/
  3. To check the execution of the various jobs that are queued by master4all.csh, type "qstatme"
  4. The job logs can be monitored in /home/airpact5/AIRRUN/YYYY/YYYYMMDD00/LOGS/
     1. Use "ls -ltr" to sort the logs according to time (oldest to newest)

---
## 24 March 2022
### Issue
- The nightly run of AIRPACT5 was not executed on the evening of 23 March 2022
- We noticed that the Day 1 and Day 2 scripts were started on aeolus (probably by someone at UW; David Ovens??) at around 12:24 pm on 24 March 2022. 
  - I know this because I started receiving email that the AIRPACT5 were running
  - Note that we did NOT receive any email notification last night at around 10 pm, which is the normal time to receive notification.

### Diagnosis
- Note from David Ovens at UW on the [Pacific Northwest Environmental Forecasts and Observation website](https://a.atmos.washington.edu/mm5rt/)
  - "A computer crash meant that last night's 2022032400 WRF-GFS runs did not run and that this morning's 2022032412 runs are delayed. Sorry for the inconvenience. D. Ovens 9:52 am PST 3/24/2022."

### Resolution
- Somehow both the Day 1 and Day 2 runs were started at 12:24 pm on 24 March 2022
  - It appears as though they were started at the same time
    - This caused the Day 2 runs for 2022032500 to finish before the Day 1 runs for 2022032400
      - So, it's not clear if the correct forecasts are being created, and if the correct files will be created for the 2022032500 run tonight...
- As of 1530 local on 20220324, we're waiting for the Day 1 and Day 2 runs to complete...
  - The Day 2 runs finished on the evening of 20220324 local time.
  - The Day 1 runs finished in the early morning or 20220325.
- The normal nightly run started on time around 10 pm local on 20220324.
  - The runs for both Day 1 and Day 2 appear to have run successfully overnight
    - Graphics for both Day 1 and Day 2 are now available on the AIRPACT5 website
- So, it appears as though 20220324 was re-run successfully yesterday after someone at UW (probably David Ovens) restarted the AIRPACT5 scripts.
- And it also appears that the current day (20220325) also ran successfully.
- Therefore, this issue was resolved by restarting both the Day 1 and Day 2 scripts on rainier at UW.

---
## 6 March 2022

### Issue
- Email from Joe Vaughan
  ```
  Vaughan, Joseph K
  Sun 3/6/2022 7:42 AM

  To: Walden, Von P.; Ghazvini, Mohammadamin Vahidi
  Von,
  Amin,
  
  Seems that AIRPACT died last night, running out of wall clock time while doing the precctm stuff.  See below.
  
  I’m going for a hike with friends but could consult later in the afternoon, once I’m back.  Let me know if you’d like my assistance.
  
  Joe
  
  From: root <noreply@aeolus.wsu.edu>
  Date: Sunday, March 6, 2022 at 12:52 AM
  To: Walden, Von P. <v.walden@wsu.edu>, Vaughan, Joseph K <jvaughan@wsu.edu>
  Subject: PBS JOB 1400749.mgt2-ib.local

  PBS Job Id: 1400749.mgt2-ib.local
  Job Name:   AP5pre20220306
  Exec host:  compute-2-7-ib.local/0
  Aborted by PBS Server 
  Job exceeded its walltime limit. Job was aborted
  See Administrator for help
  Exit_status=-11
  resources_used.cput=00:08:19
  resources_used.energy_used=0
  resources_used.mem=439748kb
  resources_used.vmem=3149816kb
  resources_used.walltime=02:21:47
  ```

### Diagnosis
- It looks as if AIRPACT5 didn't have enough wall time to download and process all of the BCON data.
  - So, I'm just going to restart master4all.csh and start the processing again on aeolus
  
  ```
  cd AIRRUN/run_ap5_day1
  ./master4all.csh 20220306

  # The run_ap5_day1 scripts finished in the afternoon of 20220306
  #    The following was done after they finished completely

  cd /home/airpact5/run_ap5_day2
  # Edited master4all_day2.csh to temporarily comment out "sleep 5400"; 90 minute wait
  ./master4all_day2.csh 20220306
  # This script started 8 jobs for 20220307
  ```
  - Unfortunately, the day2 rerun hung on the AP52fire20220307 process; it showed "W" (wait) for hours, so it was in some kind of limbo waiting for something...
  ```
  # Edited master4all_day2.csh to temporarily comment out "sleep 5400" and the RUN_PRECCTM switch, because this was successfully run earlier today.
  ./master4all_day2.csh 20220306
  # This script started 1 job (AP52meg20220307)

  ```

### Resolution
- Simply restarting the master4all.csh script seems to have fix the problem that occurred last night.
- All the routines were run successfully and all the normal files and graphics seem to have been created after the second restart of master4all_day2.csh.
- Resolved by 20220307 8:50 am local.

---
## 16 September 2021

### Issue
- MCIP data was not received from UW
  - All three email that are normally sent were *not* received
    - Typical email
      1. Status on mcip5.1_AP5_37_DAY1.csh is 0
      2. Status on /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY1_ssh_aeolus.csh is 0
      3. Status on rsync_MCIP5.1_37_DAY1.csh is 0

### Diagnosis
- Note that the graphics for 2021091600 are currently available (from yesterday's run), but obviously graphics for 2021091700 are not available
- Assuming that something happened with the normal UW WRF run overnight that would have created 2021091600

### Resolution
- Emailed Stacy Brodzik (srbrodzik@gmail.com) at UW and cc'd Joe Vaughan and Dave Ovens (ovens@atmos.washington.edu) to copy the data to the designated directory on rainier
  - Joe followed up with this email
    ```
    Stacy,

    I'm writing because I don't see that Von told you where  and what he needed regarding that data, and we can’t expect you would just know that.

    The data our job looks for is as seen here for yesterday: /home/disk/rainier_empact/mm5rt_data/2021091500 % ls
    wrfout_d3.2021091500.f07.0000@  wrfout_d3.2021091500.f18.0000@  wrfout_d3.2021091500.f29.0000@  wrfout_d3.2021091500.f40.0000@  wrfout_d3.2021091500.f51.0000@
    wrfout_d3.2021091500.f08.0000@  wrfout_d3.2021091500.f19.0000@  wrfout_d3.2021091500.f30.0000@  wrfout_d3.2021091500.f41.0000@  wrfout_d3.2021091500.f52.0000@
    wrfout_d3.2021091500.f09.0000@  wrfout_d3.2021091500.f20.0000@  wrfout_d3.2021091500.f31.0000@  wrfout_d3.2021091500.f42.0000@  wrfout_d3.2021091500.f53.0000@
    wrfout_d3.2021091500.f10.0000@  wrfout_d3.2021091500.f21.0000@  wrfout_d3.2021091500.f32.0000@  wrfout_d3.2021091500.f43.0000@  wrfout_d3.2021091500.f54.0000@
    wrfout_d3.2021091500.f11.0000@  wrfout_d3.2021091500.f22.0000@  wrfout_d3.2021091500.f33.0000@  wrfout_d3.2021091500.f44.0000@  wrfout_d3.2021091500.f55.0000@
    wrfout_d3.2021091500.f12.0000@  wrfout_d3.2021091500.f23.0000@  wrfout_d3.2021091500.f34.0000@  wrfout_d3.2021091500.f45.0000@  wrfout_d3.2021091500.f56.0000@
    wrfout_d3.2021091500.f13.0000@  wrfout_d3.2021091500.f24.0000@  wrfout_d3.2021091500.f35.0000@  wrfout_d3.2021091500.f46.0000@  wrfout_d3.2021091500.f57.0000@
    wrfout_d3.2021091500.f14.0000@  wrfout_d3.2021091500.f25.0000@  wrfout_d3.2021091500.f36.0000@  wrfout_d3.2021091500.f47.0000@
    wrfout_d3.2021091500.f15.0000@  wrfout_d3.2021091500.f26.0000@  wrfout_d3.2021091500.f37.0000@  wrfout_d3.2021091500.f48.0000@
    wrfout_d3.2021091500.f16.0000@  wrfout_d3.2021091500.f27.0000@  wrfout_d3.2021091500.f38.0000@  wrfout_d3.2021091500.f49.0000@
    wrfout_d3.2021091500.f17.0000@  wrfout_d3.2021091500.f28.0000@  wrfout_d3.2021091500.f39.0000@  wrfout_d3.2021091500.f50.0000@

    Each of these is a link such as lrwxrwxrwx 1 rmm5rt rmm5rt 70 Sep 16 05:52 wrfout_d3.2021091500.f12.0000 -> /home/disk/mm5rt/data/2021091500/airpact/wrfout_d3.2021091500.f12.0000*

    So please provide that stuff for the 16th (00z WRF run) in like manner.

    We hate to be demanding, but if the data is placed anywhere else, our scripts will need to be modified, and that should be avoided if possible.

    Thanks,

    Joe
    ```
- ==As of 8:13 pm on 17 Sep 2021, I'm still waiting for the UW to copy the necessary files to rerun 2021091600==

### Resolution
- Based on the point of failure in RUN_POSTCCTM, I suspected that the script needed at least three files from the previous day (2021091600)
  1. So I copied the following files from 2021091500 into new directories in 2021091600
    -  ~AIRRUN/2021/2021091500/CCTM/CGRID_20210915.ncf
    -  ~AIRRUN/2021/2021091500/POST/CCTM/combined_20210915.ncf
    -  ~AIRRUN/2021/2021091500/POST/CCTM/combined3d_20210915.ncf
  2. I then shifted the SDATE from 15 Sept to 16 Sept in each of these files using 'm3tshift'; see 29 August 2021 below
  3. I then edited ~AIRHOME/run_ap5_day1/master4all.csh to run only the following scripts (setting to 'Y'):
    - RUN_POSTCCTM
    - RUN_PLOT_CCTM
    - RUN_CLEANUP
  4. But then something curious happened... 
    - RUN_POSTCCTM ran, but finished stating that there was an error
    - However, I could not find any error in the log file
    - In fact, I checked all the data files in ~AIRRUN/2021/2021091500/POST/CCTM/ with those in ~AIRRUN/2021/2021091700/POST/CCTM/, and all the normal files were present and approximately the correct size.
    - So, I assumed that RUN_POSTCCTM had, in fact, run normally to completion in spite of throwing an error.
      - I believe that the presence of the error at the exit of this script caused the two subsequent scripts (RUN_PLOT_CCTM and RUN_CLEANUP) to not execute
  5. So, I then edited ~AIRHOME/run_ap5_day1/master4all.csh again to run the last two scripts (setting to 'Y'):
    - RUN_PLOT_CCTM
    - RUN_CLEANUP
  6. Final check was to see if the [website](http://www.lar.wsu.edu/airpact/) picked up the graphics for 20210917 (at the top of hour when it looks for new graphics) 
  7. Solved!! The modeling system should now be set up for tomorrow's run (which will start in a couple of hours).


---
## 29 August 2021
### Reruns from 20210818 - 20210822
- Setup for 20210818
  - Determine daynumber for desired day using iPython: ```datetime(2021,8,18).strftime('%j') ```
  ```
  cd ~/AIRRUN/2021/2021081700/CCTM
  cp /data/lar/projects/airpact5/saved/2021/08/cgrid/CGRID_20210814.ncf CGRID_20210817.ncf
  setenv INFILE CGRID_20210817.ncf
  m3tshift
    <cr>              # Enter logical name for  INPUT FILE [INFILE] >>
    <cr>              # Enter starting (source) date (YYYYDDD) for run [YYYYDAY]>>
    <cr>              # Enter starting (source) time  (HHMMSS) for run [80000] >>
    2021230           # Day number for 20210818 (next day!!)
    <cr>              # Enter target time  (HHMMSS) for run [80000] >>
    <cr>              # Enter output time step (HHMMSS) for run [10000] >>
    <cr>              # Enter duration (HHMMSS) for run [10000] >>
    <cr>              # Enter logical name for OUTPUT FILE [OUTFILE] >>
  rm CGRID_20210817.ncf
  mv OUTFILE CGRID_20210817.ncf
  ncdump -h CGRID_20210817.ncf | less        # Scroll to bottom to check dates; SDATE (start date) should be 2021230 for this case
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
### Results
- 20210818
  - Scripts ran successfully, but I don't know what happened to the acon images directory
    - Does Jen Hinds "see" the files?
- 20210819
  - ==Scripts did NOT run because the MCIP data is missing from UW==
- 20210820
  - ==Still has not been rerun...==

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
