# AIRPACT-5 Operations Issues

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
