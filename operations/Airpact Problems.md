|number|date of occurrence|problem|who found|act|date solved|
|------|------------------|-------|---------|---|-----------|
|1|11/7/2022|the KFBC missing from 22/06/2022|Joe|1. the information of PM2.5_obs and mod don't exist (Jen sent us the correct link). 2. a column name was changed in the new file (Nicole corrected the code).|14/07/2022|
|2|6/7/2022|Airpact is over quota|Dave Anderson|Joe and Amin found that the used capacity is around 41 TB till our allowed capacity is around 35 TB on 7/8.|16/7/2022|
|3|13/07/2022|firesmoke of canada not working since 12/05/2022|Joe|1. Amin emailed to Roland Schigas (rschigas@eoas.ubc.ca) their system administrator on 7/13. 2. we changed airpact_FIS_exec.csh to new bluesky and also change some commands to consider the emission of US and canada togother on 8/24 but it does not work because the Aeolus support can’t update the version Centos from 6 to 7 and the Singularity give us an error for running the BlueSky v4.3.56.||
|4|24/08/2022|we don't have fire emission for run of this day|Amin|We changed the bluesky to 4.3.56 but it does not work so we changed back to 4.2.1.|24/08/2022|
|5|6/8/2022|fire emission for re-run is not correct|Von|We changed the airpact_FIS_exec.csh script to get fire for historical dates and should compare the result with previous run.|21/10/2022|
|6|16/09/2022|PBS: job killed: walltime 3643 exceeded limit 3600 in run day 2 for mrg and pltc scripts|Amin|with the automatic run for the next day the matter was solved; maybe it was a problem of the cluster. 2.The location of the new fire and the historical fires are a little different in some points.|17/09/2022|
|7|18/10/2022|I changed the fire script to consider the October fires as Wildfire|Joe|I updated the Change log in Github.|21/10/2022|
|8|31/10/2022|"day 2 didn't run for 30; 31/10/2022 and 1/11/2022"|Amin|I reran for 1/11/2022 with ./master4all_day2.csh 20221031. We deleted the data from 2013 till 2017 and problem was solved.|4/11/2022|
|9|14/11/2022|day2 didn't run for 14/11/2022|Amin|We deleted the data for 2018 and problem was solved.|15/11/2022|
|10|12/1/2023|KFBC not working|Amin|Because of the changing to the new website the previous links didn't work. I asked Jen to create a new link and sent them to Nicole to replace in the code|12/1/2023|
|11|23/01/2023|day2 didn't run for 23/01/2023|Amin|I checked the log files and considered that there is an error with run_merge.csh. Then I checked and noticed that there is some missed file related to MEGAN in error.log. Then I checked and noticed that there is not any run for MEGAN  last night! I rerun master4all for day2 and the issue was solved.|23/01/2023|
|12|27/03/2023|Images for day2 were not on the new website|Amin|I asked Jen about it and she said that she can not connect to Aeolus; then we asked VCEA to solve it.|27/03/2023|
|13|15/04/2023|MCIP for day1 (15/04/2023) and day2 (16/04/2023) didn't receive|Amin|There was an email from UW that says there was an error for syncing and I asked David Ovens and he said it's seems like a network error. I asked him about MCIP outputs for day1 (15/04/2023) and day2 (16/04/2023)|16/04/2023|
|14|22/04/2023|WACCM outputs didn't receive and redated BCON was used for 22 and 23/04/2023|Amin|I checked the WACCM site and the outputs were there then talked with Joe and he said it is maybe because of time matter. The problem was solved for next days.|24/04/2023|
|15|26/05/2023|postcctm and plotcctm didn't work for day1 and day2|Amin|I checked the extract file and the python code for day1 and day2 was not correct; then I reran postcctm and plotcctm for day1 and day2|26/05/2023|
|16|17/07/2023|cctm; postcctm and plotcctm didn't run for day2|Amin|I reran submit cctm; postcctm and plotcctm for day2 (day2=18july2023)|17/07/2023|
|17|19/09/2023|day1 and day2 was not submitted at night but we received error emails at 8 am|Amin|I reran master4all for day1 and day2|19/09/2023|
|18|26/10/2023|cctm of day2 did not run|Amin|I reran cctm; post and plot cctm|26/10/2023|
|19|31/10/2023|cctm of day2 did not run|Amin|I reran cctm; post and plot cctm"|31/10/2023|
|20|5/12/2023|kfbc not working|Amin|Emailed Nicole June; by solving the issue related the website (No. 21) this problem was solved automatically|7/12/2023|
|21|5/12/2023|hourly performance and monthly statistics not working|Amin|Emailed Jen and vcea support and then solved|5/12/2023|
|22|31/12/2023|day3 did not complete for new year|Amin|just waiting for the next days' run|3/1/2024|
|23|1/1/2024|day2 and day3 did not complete for new year|Amin|it is related to the new year that the path outputs did not match with the path of mcip files.|2/1/2024|
|24|11/1/2024|day2 did not complete. Merge did not work.|Amin|it was related to moves stuffs which is not rau for 12/01/2024 for day2.|12/1/2024|
|25|12/1/2024|day1 did not complete. Merge did not work.|Amin|it was related to moves stuffs which is not ran for 12/01/2024 for day2. I copied the related files to related directory of day1; then reran it.|12/1/2024|
|26|4/3/2024|MCIP for day1 (3/03/2024) and day2 (4/03/2024) and day3 (5/3/2024) didn't receive|Amin|I checked the rainier and the mcip results were not created by UW. This issue solved by airpact run's for next day. We will missed deposition images in our website for this month.|4/3/2024|
|27|1/5/2024|cctm of day2 did not run|Amin|I reran cctm; post and plot cctm for day2 and day3.|1/5/2024|
|28|26/5/2024|cctm of day1 and next scripts did not run|Amin|the mcip from uw received at 6 am instead of 10 pm so cctm of day1 was in the line to run after cctm of day3. I qdel cctm of day3 then cctm of day1 was run successful but we missed cctm of day2 and day3.|26/5/2024|
|29|15/6/2024|root emails did not receive|Amin|I notify vcea support and they solved it.|18/6/2024|
|30|26/7/2024|kfbc did not produce outputs|Amin|I emailed Nicole; it happened after I deleted 2020 data. It was related to expiration of a link.|21/8/2024|
|31|28/7/2024|airpact did not run from uw|Amin|I ran airpact from rainier. day2 and day3 ran first but I killed them. Day1 ran successfully|28/7/2024|
|32|12/8/2024|waccm files did not arrive|Amin|issue was solved next day|13/8/2024|
|33|14/8/2024|uw did not create wrf outputs|Amin|I emailed David and he reran Airpact|14/8/2024|
|34|18/8/2024|cctm day2 ran before cctm day1|Amin|I reran post cctm and plot cctm for day1; day2 and day3|18/8/2024|
|35|3/9/2024|website has fallen by wsu|Amin|vcea solved it.|4/9/2024|
|36|4/9/2024|hourly performance charts not working in the website.|Amin|I informed jen and she fixed it.|5/9/2024|
|37|22/9/2024|airpact did not run from uw|Amin|I ran airpact from rainier. day2 and day3 ran first but I killed them. Day1 ran successfully|22/9/2024|
|38|23/9/2024|cctm for day2 did not run.|Amin|I reran cctm; post and plot cctm for day2 and day3.|23/9/2024|
|39|9/11/2024|uw did not create wrf outputs|Amin|I emailed David and he reran Airpact|9/11/2024|
|40|25/11/2024|Aeolus power outage on 26/11/2025|Dave Anderson|I reran the Airpact from Rainier but rsync did not work. Then emailed the VCEA support to whitelist the Rainier. We didn't miss any outputs.|26/11/2025|
|41|19/12/2024|megan did not run for day3|Amin|I reran the megan and the next scripts|19/12/2024|
|42|4/1/2025|airpact did not run from uw|Amin|I ran airpact from rainier. day2 and day3 ran first but I killed them. Day1 ran successfully|4/1/2025|
|43|15/1/2025|waccm did not completely download for 15 and 16 January |Amin|so the waccm file did not create. I downloaded the waccm files for 15 and 16 January manually and reran precctm and next scripts.|21/1/2025|
|44|17/1/2025|cctm did not run for 17; 18; 19 and 20 January because the cgrid for the previous day was not available.|Amin|I put the cgrid in the ralated directory and changed the stdate and reran the cctm and next scripts. cctm for 17 and 18 January got a segmentation error because I think the waccm_forecast files were created with incomplete waccm downloaded files.|21/1/2025|
|45|2/2/2025|airpact did not run from uw|Amin|someone ran airpact from rainier. day3 ran first but I killed it. Day1, 2, and 3 ran successfully.|2/2/2025|
|46|16/2/2025|waccm files did not arrive because NCAR website was down.|Amin|I emailed Louisa Emmons and submited a request in https://www.acom.ucar.edu/waccm/register.shtml. They solved the issue of their website. the runs for 17, 18 , 19th February is based on the bcon file of 16th February.|19/2/2025|
|47|5/5/2025|Aeolus power outage for maintanance till 9/5/2025.|Dave Anderson|Aeolus came back on 9/5/2025 but we had issue to submit the job, then I email VCEA Support and they solved it. I successfully reran the Day1 for 5, 6 and 7/5/2025. I got the Segmentation fault during runnig the CCTM for 8, 9/5/2025. This was relted for the BCON file which created with incomplete downloaded WACCM file. I ran the BCON for 8, 9/5/2025 then successfully ran the Day1 for 8, 9/5/2025 as well. Then I successfully ran the Day1 for 10, 11/5/2025 too. So we don't miss any Day1 data in this period.|11/5/2025|
|48|17/6/2025|merge file for day3 got error|Amin|After checking the log files, I noticed that the merge file which merged from moves and non-moves scripts was incomplete (EMISSIONS_AIRPACT_04km_CB05_2014nw_2025169.ncf) due to the core dumped. I resubmit precctm-just-anthro and next scripts for day3.|17/6/2025|
