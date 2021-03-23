      select cr.date
            , if(cr.vendor_id=1,'快手','头条') as vendor_id
            , dims.company_id
            , dims.project_id as project_id
           -- , max(pj.name) as project_name
            , if(sum(cr.cost)>0, count(distinct cr.vendor_account_id), 0) as cst_acct -- 消耗账户数
            , 0 as campaign_cnt
            , 0 as ctv_cnt
            , 0 as video_cnt 
            , count(distinct campaign_id) as campaign_toufang
            , count(distinct creative_id) as ctv_toufang
            , sum(cost) as cost -- 消耗金额
            , sum(cr.impression) as impression  -- 展示数
            , sum(cr.click) as click  -- 点击数
            , if(sum(impression)<>0,sum(click)/sum(impression),0) as click_rate -- 点击率
            , if(sum(click)<>0,sum(cost)/sum(click)/10000,0) as click_cost    -- 点击成本
            , sum(cr.app_activation) as app_activation  -- 激活数
            , if(sum(click)<>0,sum(app_activation)/sum(click),0) as app_activation_rate -- 激活率
            , if(sum(app_activation)<>0,sum(cost / 10000)/sum(app_activation),0) as app_activation_cost -- 激活成本
            , sum(app_event_next_day_stay) as app_event_next_day_stay -- 次留数
            , if(sum(next_day_active_count)!=0,sum(app_event_next_day_stay)/sum(next_day_active_count),0) as app_event_next_day_stay_rate -- 次日留存率
            , if(sum(next_day_active_count)<>0,sum(cost / 10000)/sum(next_day_active_count),0) as next_day_cost -- 次留成本
            , if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi -- 首日ROI
            , if(sum(content_impression)<>0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate  -- 3秒视频播放率
            , if(sum(content_impression)<>0,sum(play_5s_count)/sum(content_impression),0) as play_5s_rate  -- 5秒视频播放率
            , if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as play_end_rate  -- 完播率
            , sum(share_count) as share_count --  分享数
            , sum(like_count) as like_count -- 点赞数
            , sum(hate_count) as hate_count --  拉黑数
            , sum(complain_count) as complain_count --  举报数
    from makepolo.vendor_creative_report cr
    join (select *
	            from makepolo.creative_report_dims
	            where project_id in (select id
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
                                    or name like '%超颜相机%')
      ) dims on dims.vendor_account_id = cr.vendor_account_id 
      and dims.vendor_creative_id = cr.vendor_creative_id