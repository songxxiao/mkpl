select dat as '日期'
       , if(create_channel=1, 'API','官方后台') as '创建平台'
       , sum(cost) / sum(day_budget) as '消耗/日预算'
from (
select a.ad_unit_id
      , a.date as dat
      , budget_type
      , cost
      , day_budget
      , cost / day_budget as '消耗/预算'
      , create_channel
from (
select date
     , ad_unit_id
     , create_channel
     , sum(cost) as cost
from  makepolo.creative_report
where date>='2020-10-01' and date<='2020-10-20'
group by 1,2,3
) a left join (
select id as ad_unit_id
     , day_budget
     , budget_type
from makepolo.ad_unit
where day_budget>0 and day_budget<4000000000
)budget on a.ad_unit_id = budget.ad_unit_id
where budget_type =3
    ) b group by 1, 2
order by 1 desc,2