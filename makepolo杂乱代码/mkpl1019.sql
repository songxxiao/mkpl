





select  dat
     ,  vendor_id
     ,  company_id
     ,  count(id) as creative_cnt
     ,  count(case when create_channel=1 then id end) as creative_cnt_api
from (
      select date_format(create_time,'%Y-%m-%d') as dat
           , id
           , vendor_id
           , company_id
           , create_channel
      from makepolo.ad_creative
      where create_time>= '2020-10-07 00:00:00' and create_time<='2020-10-14 23:59:59'
      group by 1,2,3,4,5
) a
group by 1,2,3



select dat
     , vendor_id
     , company_id
     ,  count(id) as creative_cnt
     ,  count(case when create_channel=1 then id end) as creative_cnt_api
from (
      select date_format(create_time,'%Y-%m-%d') as dat
           , id
           , vendor_id
           , company_id
           , create_channel
      from makepolo.ad_creative
      where create_time>= concat(date_format(date_sub(now(), interval 30 day), '%Y-%m-%d'),' 00:00:00')
        and create_time<=concat(date_format(date_sub(now(), interval 1 day), '%Y-%m-%d'),' 23:59:59')
      group by 1,2,3,4,5
) a
group by 1,2,3



















