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
           
