
-- {{start_date}}
-- {{end_date}}
-- {{time_slice}}
-- {{vendor_id}}
-- {{company_id}}



from (
select date_format(create_time,'%Y-%m-%d') as dat
              ,  count(distinct id) as '昨日创建创意数'
              ,  count(distinct case when create_channel=1 then id end) as '昨日通过API创建创意数'
from makepolo.ad_creative
where create_time>= '{{start_date}} 00:00:00' and create_time<='{{end_date}} 23:59:59'
group by 1
) a

























