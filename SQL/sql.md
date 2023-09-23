## Examples of SQL scripts for solving some working task

**1. In the script below we extract data for newcomers and their steps in next marketing periods (similar to cohort analysis) for eleven markets. Here we are using only one tabel and can retrive data without joins**

    Result after query running:
<img src=SQL/Cohorts.png width=2000 height=50> 

```SQL
-- here we create CTE to get table without shift
WITH wp_wo_shift as (
SELECT ca.country_code
      ,ca.campaign_id
      ,SUM(ca.is_recruit) AS brp_recruits_in_campaign
      ,sum (case when ca.is_recruit = 1 and ca.is_wp_1 = 1 then 1 else 0 end) as Step_1_ver1
      ,sum (case when ca.campaign_recr = 1 and ca.is_wp_1 = 1 then 1 else 0 end ) as Step_1_ver2
      ,sum (case when ca.campaign_recr in (1,2) and ca.is_wp_2 = 1 then 1 else 0 end ) as Step_2
      ,sum (case when ca.campaign_recr in (3,4) and ca.is_wp_3 = 1 then 1 else 0 end ) as Step_3
      ,sum (case when ca.campaign_recr in (5,6) and ca.is_wp_4 = 1 then 1 else 0 end ) as Step_4
      ,sum (case when ca.campaign_recr in (7,8) and ca.is_wp_5 = 1 then 1 else 0 end ) as Step_5
      ,sum (case when ca.campaign_recr in (9,10) and ca.is_wp_6 = 1 then 1 else 0 end ) as Step_6
      ,sum (ca.is_wp_1) as cat_total_step_1
      ,sum (ca.is_wp_2) as cat_total_step_2
      ,sum (ca.is_wp_3) as cat_total_step_3
      ,sum (ca.is_wp_4) as cat_total_step_4
      ,sum (ca.is_wp_5) as cat_total_step_5
      ,sum (ca.is_wp_6) as cat_total_step_6
FROM cdw.consultants_activity ca
WHERE ca.country_code IN ('GE', 'RU', 'BL', 'UA', 'MD', 'AM', 'AZ', 'KZ', 'KG', 'MN', 'UZ')
   AND ca.campaign_id >= 202101
   AND ca.campaign_id between 202201 and 202204 -- we need two campaign id 'from' and 'to'
   AND ca.member_type = 'BRAND PARTNER'
GROUP BY ca.country_code
         ,ca.campaign_id
) -- now we can shift our data by one row up in each country
-- shifting because we get data which related with previous campaign not current  
SELECT wp.country_code
      ,wp.campaign_id
      ,wp.brp_recruits_in_campaign as recriuts
      ,wp.Step_1_ver1
      -- window function because we need to get shifting up
      ,lead(wp.Step_1_ver2, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_1_ver2
      ,wp.Step_1_ver1 + lead(wp.Step_1_ver2, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_1
      ,lead(wp.step_2, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_2
      ,lead(wp.step_3, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_3
      ,lead(wp.step_4, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_4
      ,lead(wp.step_5, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_5
      ,lead(wp.step_6, 1, 0) over (partition by wp.country_code order by wp.campaign_id) as step_6
      ,wp.cat_total_step_1 -- cat_total_step without shifting because its related with current campaign
      ,wp.cat_total_step_2
      ,wp.cat_total_step_3
      ,wp.cat_total_step_4
      ,wp.cat_total_step_5
      ,wp.cat_total_step_6
FROM wp_wo_shift wp
ORDER BY wp.country_code,
         wp.campaign_id 
```

**2. Simple segmentation task. Here we are counting quantity of active clients by sales splits**

```SQL
--- Active clients by sales segments in one country
select
    floor(ca.campaign_id/100) as "Year",
    count(case when ca.bp >= 0 and ca.bp < 50 then '0-50'end) as bp_0_50,
    count(case when ca.bp >= 50 and ca.bp < 100 then '50-100'end) as bp_50_100,
    count(case when ca.bp >= 100 and ca.bp < 150 then '100-150'end) as bp_100_150,
    count(case when ca.bp >= 150 then '150+'end) as bp_150
from CDW.Consultants_activity ca
where ca.Country_Code = 'RO' 
and (ca.Campaign_Id between 202001 and 202004 or
        ca.Campaign_Id between 202101 and 202104 or
           ca.Campaign_Id between 202201 and 202204 or
              ca.Campaign_Id between 202301 and 202304) and ca.is_active = 1
group by floor(ca.campaign_id/100)
order by "Year"
```       

**3. Here we need calculate how many people was qualified to some marketing programs. Then using this data we can make forecasts.**

    For that we need extract next data:
    
    - a. *country id* 
    - b. *client id* 
    - c. *period of marketing activity* 
    - d. *some KPIs related with client performance*         


```SQL
-- TAB = Part 1 - Report 1
WITH
Dists_list AS
(
SELECT b.Distributor_Number,
       b.Period_Id
  FROM Bonuses b
 WHERE b.Period_Id >= 12106
   AND b.Period_Id <= 12209
   AND b.New_Starts = 1
   AND EXISTS (SELECT 1
                 FROM Bonuses Bm
                WHERE Bm.Period_Id BETWEEN b.period_id AND ori_periods.PeriodIdAddPeriods(b.period_id,9)
                  AND Bm.Distributor_Number = b.Distributor_Number
                  AND Bm.Discount_Rate >= 12)
   AND EXISTS (SELECT 1
                 FROM bonuses bt
                WHERE bt.period_id = 12218
                  AND bt.distributor_number = b.distributor_number)
)
SELECT 'HU' AS market,
       b.period_id,
       d.distributor_number,
       d.period_id AS sign_up_period,
       b.discount_rate,
       b.pushed,
       (SELECT NVL(SUM(br.recruits),0)
          FROM (SELECT * FROM bonuses bl WHERE bl.period_id = b.period_id) br
         START WITH br.Distributor_Number = b.distributor_number
               CONNECT BY PRIOR br.Distributor_Number = br.Sponsor
                            AND br.discount_rate < 24) AS PG_recs,
       (SELECT NVL(SUM(brp.recruits),0)
          FROM bonuses brp
         WHERE brp.period_id = b.period_id
           AND brp.sponsor = b.distributor_number
           AND brp.recruits = 1) AS Pers_recs,
       (SELECT bd.director FROM bonuses bd WHERE bd.period_id = 12218 AND bd.distributor_number = b.distributor_number) AS director_id_12218,
       (SELECT bd.director FROM bonuses bd WHERE bd.period_id = d.period_id AND bd.distributor_number = b.distributor_number) AS director_id_start
  FROM Dists_List d
  LEFT JOIN bonuses b ON d.distributor_number = b.distributor_number
 WHERE b.period_id BETWEEN 12106 AND 12218
 ORDER BY 3,2
;
```       