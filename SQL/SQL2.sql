
;
--- ASF by BP segments
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
;
--- ASF by campaigns in Oriflame
select
floor(ca.campaign_id/100) as "Year",
count(case when ca.campaign_recr >= 0 and ca.campaign_recr <= 4 then '0-4'  end) as "0-4",
count(case when ca.campaign_recr >= 5 and ca.campaign_recr <= 8 then '5-8'  end) as "5-8",
count(case when ca.campaign_recr >= 9 and ca.campaign_recr <= 18 then '9-18'  end) as "9-18",
count(case when ca.campaign_recr >= 19 and ca.campaign_recr <= 36 then '19-36' end) as "19-36",         
count(case when ca.campaign_recr > 36 then '36' end) as "36+"   
from CDW.Consultants_activity ca
where ca.Country_Code = 'RO' 
and (ca.Campaign_Id between 202001 and 202004 or
        ca.Campaign_Id between 202101 and 202104 or
           ca.Campaign_Id between 202201 and 202204 or
              ca.Campaign_Id between 202301 and 202304) and ca.is_active = 1
group by floor(ca.campaign_id/100)
order by "Year"
;
--- ASF by BP PD
select
floor(ca.campaign_id/100) as "Year",
count(case when ca.discount_rate = 0 then '0%'end) as "0%",
count(case when ca.discount_rate >= 4 and ca.discount_rate <= 9 then '4-9%'end) as "4-9%",
count(case when ca.discount_rate >= 12 and ca.discount_rate <= 20 then '12-20%'end) as "12-20%",
count(case when ca.discount_rate > 20 then 'Senior'end) as "Senior"
from CDW.Consultants_activity ca
where ca.Country_Code = 'RO' 
and (ca.Campaign_Id between 202001 and 202004 or
        ca.Campaign_Id between 202101 and 202104 or
           ca.Campaign_Id between 202201 and 202204 or
              ca.Campaign_Id between 202301 and 202304) and ca.is_active = 1
group by floor(ca.campaign_id/100)
order by "Year"