# Constructing 8-hour rolling averages of ozone from AIRPACT5 output

- From Joe Vaughan
  - Important directories
    - /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/ave08hr_IDEQ
    - /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_AIRNow_IDEQ
    - /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_max8hro3_IDEQ
    - ==README==
        ```
        README
        For extraction of max8hr O3 for Pocatello and Twin Falls sites for 2020 (entire) for IDEQ, Rong Li.
        JKV 03/25/21

        Starts in dir ~airpact5/AIRHOME/run_ap5_day1/post/cctm/ave08hr_IDEQ
        run_08hr_O3_from_saved.csh regenerates the surface level 8-hr rolling average O3 from a given date,
        accessing data from the 'saved' archive.  24 values of rolling 8-hr average O3 are solved per day.
        Per run, the input files are the combine files (ncf) from day specified and prior day.
        Output file for each run is level 1 rolling 8-hr average O3, also ncf.

        Then in dir ~airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_max8hro3_IDEQ the code
        run_2020_month-by-month.csh YYYYMM

        Which runs:
        run_site_extract_Roll8hrO3.csh YYYYMM
        resulting in files in locations, e.g.:

        /data/lar/projects/airpact5/AIRRUN/2020/2020030100/POST/CCTM/IDEQ_Sites_20200301_v10.dat

        and also runs:
        run_site_daily_max8hr03.csh YYYYMM
        resulting in files in locations:
        /data/lar/projects/airpact5/AIRRUN/2020/2020030100/POST/CCTM/
        -rw-r--r-- 1 airpact5 lar   32 Mar 29 12:48 IDEQ_Id_Falls_NW_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   32 Mar 29 12:48 IDEQ_Id_Falls_NE_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   32 Mar 29 12:48 IDEQ_Id_Falls_SW_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   32 Mar 29 12:48 IDEQ_Id_Falls_SE_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   33 Mar 29 12:48 IDEQ_Pocatello_NW_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   33 Mar 29 12:48 IDEQ_Pocatello_NE_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   33 Mar 29 12:48 IDEQ_Pocatello_SW_20200301_max8O3.csv
        -rw-r--r-- 1 airpact5 lar   33 Mar 29 12:48 IDEQ_Pocatello_SE_20200301_max8O3.csv

        A further code is then needed to collate data per site for the year:

        ```
    - Retrieve saved data for ozone
      - /data/lar/projects/airpact5/AIRRUN/20XX/YYYYMMDD00/POST/CCTM/O3_L01_08hr*.ncf

    - Test day
      - 2020011500
      - /data/lar/projects/airpact5/AIRRUN/2020/2020011500/POST/CCTM/IDEQ*.csv

- ==From Von P. Walden==
  - Two new Python scripts to: 
    - Copy data from aeolus to gaia
    - Extract 8-hour rolling averages of ozone for Pocatello and Idaho Falls AQS sites
      - These are both run AFTER run_08hr_O3_from_saved.csh on aeolus in ~airpact5/AIRHOME/run_ap5_day1/post/cctm/ave08hr_IDEQ
  
- Missing data for 2021
  - 2021010100
  - 2021010200
  - 2021033100
  - 2021040100
  - 2021061600
  - 2021061700
  - 2021061800
  - 2021081900
  - 2021082100
  - 2021082200
  - 2021082300
  - 2021091600
  - 2021120100
  - 2021120200
  - 2021120300
  - 2021120400
  - 2021120500
  - 2021120600
  - 2021120700
  - 2021120800
  - 2021120900
  - 2021121000
  - 2021121100
  - 2021121200
  - 2021121300
  - 2021121400
  - 2021121500
  - 2021121600
  - 2021121700
  - 2021121800
  - 2021121900
  - 2021122000
  - 2021122100
  - 2021122200
  - 2021122300
