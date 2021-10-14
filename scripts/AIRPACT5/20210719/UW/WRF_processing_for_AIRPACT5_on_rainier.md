# WRF processing for AIRPACT5 on rainier

## Scripts that run on rainier each night

- /home/disk/rainier_empact/AQSIM_AIRPACT.pl
  - /home/disk/rainier_empact/AQSIM_MCIP5.1_AIRPACT5_DAY1.pl
    - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY1.pl
      - /home/disk/rainier_empact/airpact5/AIRHOME/mcip/AP5_mcip5.1_37_DAY1.csh
        - /home/disk/rainier_empact/airpact5/AIRHOME/mcip/mcip5.1_AP5_37_DAY1.csh
          - /home/disk/rainier_empact/MCIP5.1/src/mcip.exe
        - /home/disk/rainier_empact/airpact5/AIRHOME/mcip/rsync_MCIP5.1_37_DAY1.csh
      - /home/disk/rainier_empact/airpact5/AIRHOME/RUN/AP5_DAY1_ssh_aeolus.csh
        - /home/airpact5/AIRHOME/run_ap5_day1/master4all.csh - !! run on aeolus, but started from rainier... !!
  - /home/disk/rainier_empact/check_space.csh

