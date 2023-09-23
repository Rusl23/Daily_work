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