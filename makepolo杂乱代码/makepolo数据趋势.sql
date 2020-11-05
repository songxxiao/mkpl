
-- {{start_date}}
-- {{end_date}}
-- {{time_slice}}
-- {{vendor_id}}
-- {{company_id}}

select date_format(date, '%Y-%m-%d %H') as dat
              ,  count(id) as  '创建创意数'
              ,  count(case when create_channel=1 then id end) as  '通过api创建创意数' 
              ,  count(case when create_channel=1 then id end) / count(id) as '通过api创建创意数占比'
from (
      select create_time as date
             , id
             , create_channel
      from makepolo.ad_creative
      where create_time>= '{{yesterday}} 00:00:00' and create_time<='{{yesterday}} 23:59:59'
      group by 1,2,3
) a
group by 1

select date_format(date, '%Y-%m-%d %H') as datetime
              ,  count(id) as creative_cnt
              ,  count(case when create_channel=1 then id end) as creative_cnt_api
from (
      select create_time as date
             , id
             , create_channel
      from makepolo.ad_creative
      where create_time>= '2020-10-21 00:00:00' and create_time<='2020-10-21 23:59:59'
      group by 1,2,3
) a
group by 1




date_format(date_add(concat(`date`, ' 00:00:00'), interval `hour` HOUR), '%Y-%m-%d %H') as datetime




















