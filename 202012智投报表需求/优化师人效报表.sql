-- {{start_date}}
-- {{end_date}}
-- {{vendor_account_id}}
-- {{params_account_id}}
-- {{company_id}}
-- {{is_dat}}

<%
where = "";
if(isNotEmpty(vendor_account_id)){
    where = where + " and vendor_account_id in ("+vendor_account_id+")";
} else {
    where = where + " and vendor_account_id < 0 ";
}

if(isNotEmpty(company_id)){
    where =  where + " and company_id in ("+company_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and account_id in ("+params_account_id+")";
}


where_cr = "";
if(isNotEmpty(vendor_account_id)){
    where_cr = where_cr + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else {
    where_cr = where_cr + " and cr.vendor_account_id < 0 ";
}

if(isNotEmpty(company_id)){
    where_cr =  where_cr + " and cr.company_id in ("+company_id+")";
}

if(isNotEmpty(params_account_id)){
    where_cr =  where_cr + " and eva.subordinate_account_id in ("+params_account_id+")";
}


%>



select cr.date                         as '日期',
       au.name                         as '优化师名称',
       ifnull(ca.increase_ad, 0)       as '新增广告数',
       ifnull(cc.increase_creative, 0) as '新增创意数',
       cia.cnt_ad                      as '曝光广告数',
       cia.cnt_creative                as '曝光创意数',
       cr.cost                         as '总消耗',
       cr.impression                   as '封面曝光数',
       cr.click                        as '封面点击数',
       cr.click_rate                   as '封面点击率',
       cr.app_activation               as '激活数',
       cr.app_activation_cost          as '激活成本',
       cr.app_event_pay_amount         as '付费',
       cr.play_3s_rate                 as '3秒视频播放率'

from (
         select date,
                eva.subordinate_account_id                                                        as creative_account_id,
                sum(cost) / 10000                                                                 as cost,
                sum(impression)                                                                   as impression,
                sum(click)                                                                        as click,
                if(sum(impression) <> 0, sum(click) / sum(impression), 0)                         as click_rate,
                sum(app_activation)                                                               as app_activation,
                if(sum(app_activation) <> 0, sum(cost) / sum(app_activation) / 10000,
                   0)                                                                             as app_activation_cost,
                sum(cr.app_event_pay_amount) / 100                                                as app_event_pay_amount,
                if(sum(content_impression) <> 0, sum(play_3s_count) / sum(content_impression), 0) as play_3s_rate
         from `creative_report` cr
                  left join entity_vendor_account eva on cr.vendor_account_id = eva.id
         where cr.date >= '${start_date}'
           and cr.date <= '${end_date}' ${where_cr}
         group by date, eva.subordinate_account_id
     ) cr
         left join (
    select date,
           eva.subordinate_account_id  as creative_account_id,
           count(distinct creative_id) as cnt_creative,
           count(distinct ad_unit_id)  as cnt_ad
    from `creative_report` cr
             left join entity_vendor_account eva on cr.vendor_account_id = eva.id
    where date >= '${start_date}'
      and date <= '${end_date}'
      and impression > 0 ${where_cr}
    group by date, eva.subordinate_account_id
) cia on cia.date = cr.date and cia.creative_account_id = cr.creative_account_id
         left join (
    select date(create_time) as dat, account_id, count(1) as increase_creative
    from ad_creative
    where create_time >= '${start_date}'
      and create_time <= '${end_date} 23:59:59' ${where}
    group by date(create_time), account_id
) cc on cc.dat = cr.date and cc.account_id = cr.creative_account_id
         left join (
    select date(create_time) as dat, account_id, count(1) as increase_ad
    from ad_unit
    where create_time >= '${start_date}'
      and create_time <= '${end_date} 23:59:59' ${where}
    group by date(create_time), account_id
) ca on ca.dat = cr.date and ca.account_id = cr.creative_account_id
         left join account_user au on cr.creative_account_id = au.id

---------------------------------------------------------------------------------------------

select cr.date                         as '日期',
       au.name                         as '优化师名称',
       ifnull(ca.increase_ad, 0)       as '新增广告数',
       ifnull(cc.increase_creative, 0) as '新增创意数',
       cr.cnt_ad                       as '曝光广告数',
       cr.cnt_creative                 as '曝光创意数',
       cr.cost                         as '总消耗',
       cr.impression                   as '封面曝光数',
       cr.click                        as '封面点击数',
       cr.click_rate                   as '封面点击率',
       cr.app_activation               as '激活数',
       cr.app_activation_cost          as '激活成本',
       cr.app_event_pay_amount         as '付费',
       cr.play_3s_rate                 as '3秒视频播放率'
from (
         select date,
                eva.subordinate_account_id                                                        as creative_account_id,
                sum(cost) / 10000                                                                 as cost,
                sum(impression)                                                                   as impression,
                sum(click)                                                                        as click,
                if(sum(impression) != 0, sum(click) / sum(impression), 0)                         as click_rate,
                sum(app_activation)                                                               as app_activation,
                if(sum(app_activation) != 0, sum(cost) / sum(app_activation) / 10000,
                   0)                                                                             as app_activation_cost,
                sum(cr.app_event_pay_amount) / 100                                                as app_event_pay_amount,
                if(sum(content_impression) != 0, sum(play_3s_count) / sum(content_impression), 0) as play_3s_rate,
                count(distinct creative_id)                                                       as cnt_creative,
                count(distinct ad_unit_id)                                                        as cnt_ad
         from makepolo.vendor_creative_report cr
                  left join makepolo.creative_report_dims dims on dims.vendor_account_id = cr.vendor_account_id
             and dims.vendor_creative_id = cr.vendor_creative_id
                  left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
         where cr.date >= '${start_date}'
           and cr.date <= '${end_date}' 
           and impression > 0 ${where}
         group by 1, 2
     ) cr
         left join (
    select date(create_time) as date
         , account_id
         , count(1)          as increase_creative
    from makepolo.ad_creative
    where create_time >= '${start_date} 00:00:00'
      and create_time <= '${end_date} 23:59:59' ${where}
    group by 1, 2
) cc on cc.date = cr.date and cc.account_id = cr.creative_account_id
         left join (
    select date(create_time) as date
         , account_id
         , count(1)          as increase_ad
    from makepolo.ad_unit
    where create_time >= '${start_date} 00:00:00'
      and create_time <= '${end_date} 23:59:59' ${where}
    group by 1, 2
) ca on ca.date = cr.date and ca.account_id = cr.creative_account_id
         left join makepolo.account_user au on cr.creative_account_id = au.id
 



 