with xn_projects as (
    select id
    , case
        when name like '%即刻天气极速版%'  then '即刻天气极速版'
        when name like '%即刻天气%'     then '即刻天气'
        when name like '%即刻万年历%'    then '即刻万年历'
        when name like '%时刻天气%'      then '时刻天气'
        when name like '%诸葛天气极速版%' then '诸葛天气极速版'
        when name like '%诸葛天气%'      then '诸葛天气'
        when name like '%诸葛万年历%'    then '诸葛万年历'
        when name like '%365天气管家%'    then '365天气管家'
        when name like '%365天气%'      then '365天气'
        when name like '%知心天气极速版%' then '知心天气极速版'
        when name like '%知心天气%'      then '知心天气'
        when name like '%知心万年历%'    then '知心万年历'
        when name like '%清理管家极速版%' then '清理管家极速版'
        when name like '%一键清理管家%'   then '一键清理管家'
        when name like '%早晚天气极速版%' then '早晚天气极速版'
        when name like '%早晚天气%' then '早晚天气'
        when name like '%葫芦音乐%' then '葫芦音乐'
        when name like '%今时天气%' then '今时天气'
        when name like '%飞鱼清理%' then '飞鱼清理'
        when name like '%悟空清理%' then '悟空清理'
        when name like '%开心超市%' then '开心超市'
        when name like '%熊猫清理%' then '熊猫清理'
        when name like '%及时天气%' then '及时天气'
        when name like '%哪吒清理%' then '哪吒清理'
        when name like '%海鸥天气%' then '海鸥天气'
        when name like '%大圣清理%' then '大圣清理'
        when name like '%祥云天气%' then '祥云天气'
        when name like '%超颜相机%' then '超颜相机'
        end as project_name
    from makepolo.project
    where name like '%即刻天气%'
       or name like '%诸葛万年历%'
       or name like '%365天气%'
       or name like '%知心天气%'
       or name like '%一键清理管家%'
       or name like '%早晚天气%'
       or name like '%葫芦音乐%'
       or name like '%今时天气%'
       or name like '%飞鱼清理%'
       or name like '%诸葛天气%'
       or name like '%365天气管家%'
       or name like '%悟空清理%'
       or name like '%即刻天气极速版%'
       or name like '%时刻天气%'
       or name like '%知心万年历%'
       or name like '%开心超市%'
       or name like '%熊猫清理%'
       or name like '%清理管家极速版%'
       or name like '%知心天气极速版%'
       or name like '%及时天气%'
       or name like '%哪吒清理%'
       or name like '%海鸥天气%'
       or name like '%早晚天气极速版%'
       or name like '%即刻万年历%'
       or name like '%大圣清理%'
       or name like '%祥云天气%'
       or name like '%诸葛天气极速版%'
       or name like '%超颜相机%'
)

select dat, vendor, company, project_name
    , sum(ncampain_cnt) as ncampain_cnt
    , sum(nctv_cnt) as nctv_cnt
    , sum(cost_accounts) as cost_accounts
    , sum(cost_campaigns) as cost_campaigns
    , sum(cost_creatives) as cost_creatives
    , sum(cost)                         as cost
    , sum(imps)                   as imps
    , sum(clks)                        as clks
    , sum(actives)               as actives
    , sum(nxt_day_stay)      as nxt_day_stay
    , sum(yst_day_actives)        as yst_day_actives
    , sum(content_impression)           as content_impression
    , sum(play_3s_count)                as play_3s_count
    , sum(play_5s_count)                as play_5s_count
    , sum(play_end_count)               as play_end_count
    , sum(share_count)                  as share_count
    , sum(like_count)                   as like_count
    , sum(hate_count)                   as hate_count
    , sum(complain_count)               as complain_count
from (
    select creport.date as dat
        , if(creport.vendor_id = 1, '快手', '头条') as vendor
        , company.name as company
        , xn_projects.project_name as project_name
        , 0 as ncampain_cnt
        , 0 as nctv_cnt
        , count(distinct creport.vendor_account_id) as cost_accounts
        , count(distinct cdims.campaign_id) as cost_campaigns
        , count(distinct cdims.creative_id) as cost_creatives
        , sum(cost)                         as cost
        , sum(creport.impression)           as imps
        , sum(creport.click)                as clks
        , sum(creport.app_activation)       as actives          -- 激活数
        , sum(app_event_next_day_stay)      as nxt_day_stay     -- 次留数
        , sum(next_day_active_count)        as yst_day_actives  -- 昨日激活数
        , sum(content_impression)           as content_impression
        , sum(play_3s_count)                as play_3s_count
        , sum(play_5s_count)                as play_5s_count
        , sum(play_end_count)               as play_end_count
        , sum(share_count)                  as share_count
        , sum(like_count)                   as like_count
        , sum(hate_count)                   as hate_count
        , sum(complain_count)               as complain_count
    from makepolo.vendor_creative_report creport
    join makepolo.creative_report_dims cdims
    on creport.vendor_account_id = cdims.vendor_account_id and creport.vendor_creative_id = cdims.vendor_creative_id
    join xn_projects on cdims.project_id = xn_projects.id
    join makepolo_common.account_admin company
    on cdims.company_id = company.id
    where date>='2021-01-01'
        and date<='2021-02-04'
    group by 1, 2, 3, 4

    union all

    select dat
        , vendor
        , company.name as company
        , xn_projects.project_name as project_name
        , count(distinct creative.campaign_id) as ncampain_cnt
        , count(distinct creative.id)          as nctv_cnt
        , 0 as cost_accounts
        , 0 as cost_campaigns
        , 0 as cost_creatives
        , 0 as cost
        , 0 as imps
        , 0 as clks
        , 0 as actives
        , 0 as nxt_day_stay
        , 0 as yst_day_actives
        , 0 as content_impression
        , 0 as play_3s_count
        , 0 as play_5s_count
        , 0 as play_end_count
        , 0 as share_count
        , 0 as like_count
        , 0 as hate_count
        , 0 as complain_count
    from (
    	select date_format(create_time,'%Y-%m-%d') as dat
    	       , id
               , project_id
               , company_id
               , if(vendor_id=1,'快手','头条') as vendor
               , campaign_id
        from makepolo.ad_creative
        where create_time >='2021-01-01 00:00:00'
        and create_time <='2021-02-04 23:59:59'
    ) creative
    join xn_projects on creative.project_id = xn_projects.id
    join makepolo_common.account_admin company
    on creative.company_id = company.id
    group by 1, 2, 3, 4
    ) a
group by 1, 2, 3, 4

-- desc makepolo_common.account_admin



