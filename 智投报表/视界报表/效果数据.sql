-- {{start_date}}
-- {{end_date}}
-- {{vendor_id}}
-- {{demand_id}}
-- {{owner_creator_id}}
-- {{company_id}}
-- {{order_id}}
-- {{director_id}}
-- {{writer_id}}
-- {{camerist_id}}
-- {{late_producer_id}}
-- {{company_type}}


/*company_type = 1 素材团队
 company_type = 0 需求方
 role_type = 1 导演
 role_type = 2 编剧
 
 role_type = 3 摄像
 role_type = 4 后期
 
 --  需求方 ${company_type =='1' ? "'需求方'":"'创作团队'"}     
*/

select
        replace_video_index
      , max(Video_url) as video_url
      , max(Video_title) as video_title
      , max(Vendor_id) as vendor_id
      , max(Company_name) as demand_name
      , max(Company_name) as creator_name
      , max(Order_id) as order_id
      , max(Order_name) as order_name
      , if(max(Director_name) ='','_', max(Director_name)) as director_name
      , if(max(Writer_name) ='','_', max(Writer_name)) as writer_name
      , if(max(Camerist_name) ='','_', max(Camerist_name)) as camerist_name
      , if(max(Late_name) ='','_', max(Late_name)) as late_name
      , sum(Cost) / 10000 as cost
      , sum(Content_impression) as content_impression_ks
      , sum(Impression) as content_impression_tt
      , ifNotFinite(play_3s_count / content_impression_ks, 0) as play_3s_rate_ks
      , ifNotFinite((play_3s_count / 100) / total_play, 0) as play_3s_rate_tt
      , ifNotFinite(play_5s_count / content_impression_ks, 0) as play_5s_rate_ks
      , ifNotFinite((play_5s_count / 100) / total_play, 0) as play_5s_rate_tt
      , ifNotFinite(play_end_count / content_impression_ks, 0) as play_end_rate_ks
      , ifNotFinite((play_end_count / 100) / total_play, 0) as play_end_rate_tt
      , sum(Share_count) as share_count
      , sum(Comment_count) as comment_count
      , sum(Like_count) as like_count
      , sum(Add_follower_count) as add_follower_count
      , sum(Complain_count) as complain_count
      , sum(Negative_count) as negative_count
      , sum(Hate_count) as hate_count
      , max(Cover_image_url) as cover_image_url
      , sum(Total_play) as total_play
      , sum(Valid_play) as valid_play
      , ifNotFinite(play_25_feed_break  / total_play, 0) as play_25_rate
      , ifNotFinite(play_50_feed_break  / total_play, 0) as play_50_rate
      , ifNotFinite(play_75_feed_break  / total_play, 0) as play_75_rate
      , ifNotFinite(play_100_feed_break / total_play, 0) as play_100_rate
      , sum(Click) as click
      , ifNotFinite(click / content_impression_ks, 0) as click_rate_ks
      , ifNotFinite(click / content_impression_tt, 0) as click_rate_tt
      , ifNotFinite(valid_play / content_impression_ks, 0)  as valid_play_rate_ks
      , ifNotFinite(valid_play / content_impression_tt, 0)  as valid_play_rate_tt
      , ifNotFinite(cost / valid_play, 0) as valid_play_cost
      , ifNotFinite(play_duration_sum / total_play, 0) as avg_play_duration
      , round(play_end_count / 100) as play_end_count1
      , ifNotFinite(cost / convert_count, 0) as convert_cost
      , sum(Deep_convert_count) as deep_convert_count
      , sum(Content_click) as content_click
      , ifNotFinite(content_click / content_impression_ks, 0) as content_rate
      , sum(Convert_count) as convert_count
      , ifNotFinite(convert_count / click, 0) as convert_rate
      , ifNotFinite(deep_convert_count / click, 0) as deep_convert_rate
-- ----------------------
      , sum(Play_3s_count) as play_3s_count
      , sum(Play_5s_count) as play_5s_count
      , sum(Play_end_count) as play_end_count
      , sum(Play_duration_sum) / 1000 as play_duration_sum
      , sum(Play_25_feed_break) as play_25_feed_break
      , sum(Play_50_feed_break) as play_50_feed_break
      , sum(Play_75_feed_break) as play_75_feed_break
      , sum(Play_100_feed_break) as play_100_feed_break
from (
      select replace_video_index
             , max(if(mmv.is_replace_video=0, mmv.url, null)) Video_url
             , max(if(mmv.is_replace_video=0, mmv.cover_image_url, null)) Cover_image_url
             , max(if(mmv.is_replace_video=0, mmv.name, null))  Video_title
             , max(ev.name) Vendor_id
             , max(ad.company_name)  Company_name
        	    , max(mmo.name)            Order_name
        	    , max(mmo.id)              Order_id
             , max(director.name)     Director_name
             , max(writer.name)       Writer_name
             , max(camerist.name)     Camerist_name
          	 , max(late.name)             Late_name
             , sum(play_3s_count)         Play_3s_count
             , sum(play_5s_count)         Play_5s_count
             , sum(content_impression)    Content_impression
         	 , sum(impression)            Impression
             , sum(play_25_feed_break)    Play_25_feed_break
             , sum(play_50_feed_break)    Play_50_feed_break
             , sum(play_75_feed_break)    Play_75_feed_break
             , sum(play_100_feed_break)   Play_100_feed_break
             , sum(play_duration_sum)     Play_duration_sum
             , sum(cost)                  Cost
             , sum(share_count)           Share_count
             , sum(comment_count)         Comment_count
             , sum(like_count)            Like_count
             , sum(hate_count)            Hate_count
             , sum(add_follower_count)    Add_follower_count
             , sum(complain_count)        Complain_count
             , sum(negative_count)        Negative_count
             , sum(total_play)            Total_play
             , sum(valid_play)            Valid_play
             , sum(click)                 Click
             , sum(play_end_count)        Play_end_count
        	    , sum(content_click)         Content_click
             , sum(convert_count)         Convert_count
        	    , sum(deep_convert_count)    Deep_convert_count
      from (
SELECT vr.date                                    AS date,
             vr.hour                                    AS hour,
             mv.company_id                              AS company_id,
             vr.vendor_id                               AS vendor_id,
             vr.vendor_account_id                       AS vendor_account_id,
             mv.account_id                              AS account_id,
             mv.local_video_id                          AS local_video_id,
             mv.material_video_id                       AS material_video_id,
             mv.creative_count                          AS creative_count,
             vr.is_test_data                            AS is_test_data,
             mv.video_account_id                        AS video_account_id,
             mv.video_url                               AS video_url,
             mv.video_name                              AS video_name,
             vr.photo_id                                AS photo_id,
             vr.vendor_creative_id                      AS vendor_creative_id,
             vr.vendor_adunit_id                        AS vendor_adunit_id,
             vr.vendor_campaign_id                      AS vendor_campaign_id,
             vr.data_provider                           AS data_provider,
             mv.create_source                           AS create_source,
             mv.material_market_creator_id              AS material_market_creator_id,
             mv.director_id                             AS director_id,
             mv.writer_id                               AS writer_id,
             mv.camerist_id                             AS camerist_id,
             mv.late_producer_id                        AS late_producer_id,
             vr.cost                                    AS cost,
             vr.cost / (1 + eva.return_point / 100) AS cost_rebate,
             vr.impression                              AS impression,
             vr.click                                   AS click,
             vr.content_impression                      AS content_impression,
             vr.content_click                           AS content_click,
             vr.app_download_start                      AS app_download_start,
             vr.app_download_complete                   AS app_download_complete,
             vr.app_activation                          AS app_activation,
             vr.app_register                            AS app_register,
             vr.app_event_pay                           AS app_event_pay,
             vr.app_event_pay_amount                    AS app_event_pay_amount,
             vr.app_event_next_day_stay                 AS app_event_next_day_stay,
             vr.play_3s_count                           AS play_3s_count,
             vr.create_time                             AS create_time,
             vr.update_time                             AS update_time,
             vr.event_pay_first_day                     AS event_pay_first_day,
             vr.event_pay_purchase_amount_first_day     AS event_pay_purchase_amount_first_day,
             vr.event_pay                               AS event_pay,
             vr.form_count                              AS form_count,
             vr.play_5s_count                           AS play_5s_count,
             vr.play_end_count                          AS play_end_count,
             vr.share_count                             AS share_count,
             vr.comment_count                           AS comment_count,
             vr.like_count                              AS like_count,
             vr.hate_count                              AS hate_count,
             vr.add_follower_count                      AS add_follower_count,
             vr.complain_count                          AS complain_count,
             vr.negative_count                          AS negative_count,
             vr.convert_count                           AS convert_count,
             vr.deep_convert_count                      AS deep_convert_count,
             vr.total_play                              AS total_play,
             vr.valid_play                              AS valid_play,
             vr.play_25_feed_break                      AS play_25_feed_break,
             vr.play_50_feed_break                      AS play_50_feed_break,
             vr.play_75_feed_break                      AS play_75_feed_break,
             vr.play_100_feed_break                     AS play_100_feed_break,
             vr.play_duration_sum                       AS play_duration_sum,
             vr.wifi_play                               AS wifi_play
             FROM makepolo.vendor_material_report vr
               INNER JOIN makepolo.entity_vendor_account eva ON eva.id = vr.vendor_account_id
               LEFT OUTER JOIN makepolo.market_video_dims mv
                               ON vr.photo_id = mv.vendor_material_id AND toInt64(eva.company_id) = toInt64(mv.company_id)
            where vr.vendor_id = ${vendor_id}
              and vr.date < today() - 1 
              and vr.date >= '${start_date}'
              and vr.date <= '${end_date}'
              ${company_type =='1' ? "":"and eva.company_id in ("+ company_id +" )"}
         ${strutil.contain(director_id!'-1', '-1') ? "":"and mv.director_id in ( "+ director_id +" )"}  -- dims
         ${strutil.contain(writer_id!'-1', '-1') ? "":"and mv.writer_id in ( "+ writer_id +" )"}        -- dims
         ${strutil.contain(camerist_id!'-1', '-1') ? "":"and mv.camerist_id in ( "+ camerist_id +" )"}  -- dims
         ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and mv.late_producer_id in ( "+ late_producer_id +" )"}  -- dims
      ) a
         left join tidb_makepolo.material_market_video mmv on toInt64(a.material_video_id) = toInt64(mmv.id)
         left join tidb_makepolo.material_market_order mmo on mmv.order_id = mmo.id
         left join tidb_makepolo_common.account_user au on au.id = mmo.account_id
         left join tidb_makepolo_common.account_admin ad on ${company_type =='1' ? "au.company_id = ad.id":"mmo.owner_creator_id = ad.id"}  
         left join (select id, name from tidb_makepolo.creator_role where id > 0) director on director.id = a.director_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) writer on writer.id = a.writer_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) camerist on camerist.id = a.camerist_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) late on late.id = a.late_producer_id
         left join tidb_makepolo_common.vendor ev on ev.vendor_id=a.vendor_id
      where is_test_data = 0
         ${company_type =='1' ? "and mmo.owner_creator_id in ("+ company_id +" )":""}
         ${strutil.contain(demand_id!'-1', '-1') ? "":"and eva.company_id in ( "+ demand_id +" )"} -- 需求方id
         ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mmo.owner_creator_id in ( "+ owner_creator_id +" )"} -- 创作团队id
         ${strutil.contain(order_id!'-1', '-1') ? "":"and mmv.order_id in ( "+ order_id +" )"}  -- 订单id
      group by replace_video_index

      union all

      select replace_video_index
             , max(if(mmv.is_replace_video=0, mmv.url, null)) Video_url
             , max(if(mmv.is_replace_video=0, mmv.cover_image_url, null)) Cover_image_url
             , max(if(mmv.is_replace_video=0, mmv.name, null))  Video_title
             , max(ev.name) Vendor_id
             , max(ad.company_name)  Company_name
        	    , max(mmo.name)            Order_name
        	    , max(mmo.id)              Order_id
             , max(director.name)     Director_name
             , max(writer.name)       Writer_name
             , max(camerist.name)     Camerist_name
          	 , max(late.name)             Late_name
             , sum(play_3s_count)         Play_3s_count
             , sum(play_5s_count)         Play_5s_count
             , sum(content_impression)    Content_impression
         	 , sum(impression)            Impression
             , sum(play_25_feed_break)    Play_25_feed_break
             , sum(play_50_feed_break)    Play_50_feed_break
             , sum(play_75_feed_break)    Play_75_feed_break
             , sum(play_100_feed_break)   Play_100_feed_break
             , sum(play_duration_sum)     Play_duration_sum
             , sum(cost)                  Cost
             , sum(share_count)           Share_count
             , sum(comment_count)         Comment_count
             , sum(like_count)            Like_count
             , sum(hate_count)            Hate_count
             , sum(add_follower_count)    Add_follower_count
             , sum(complain_count)        Complain_count
             , sum(negative_count)        Negative_count
             , sum(total_play)            Total_play
             , sum(valid_play)            Valid_play
             , sum(click)                 Click
             , sum(play_end_count)        Play_end_count
        	    , sum(content_click)         Content_click
             , sum(convert_count)         Convert_count
        	    , sum(deep_convert_count)    Deep_convert_count
      from (
SELECT vr.date                                    AS date,
             vr.hour                                    AS hour,
             mv.company_id                              AS company_id,
             vr.vendor_id                               AS vendor_id,
             vr.vendor_account_id                       AS vendor_account_id,
             mv.account_id                              AS account_id,
             mv.local_video_id                          AS local_video_id,
             mv.material_video_id                       AS material_video_id,
             mv.creative_count                          AS creative_count,
             vr.is_test_data                            AS is_test_data,
             mv.video_account_id                        AS video_account_id,
             mv.video_url                               AS video_url,
             mv.video_name                              AS video_name,
             vr.photo_id                                AS photo_id,
             vr.vendor_creative_id                      AS vendor_creative_id,
             vr.vendor_adunit_id                        AS vendor_adunit_id,
             vr.vendor_campaign_id                      AS vendor_campaign_id,
             vr.data_provider                           AS data_provider,
             mv.create_source                           AS create_source,
             mv.material_market_creator_id              AS material_market_creator_id,
             mv.director_id                             AS director_id,
             mv.writer_id                               AS writer_id,
             mv.camerist_id                             AS camerist_id,
             mv.late_producer_id                        AS late_producer_id,
             vr.cost                                    AS cost,
             vr.cost / (1 + eva.return_point / 100) AS cost_rebate,
             vr.impression                              AS impression,
             vr.click                                   AS click,
             vr.content_impression                      AS content_impression,
             vr.content_click                           AS content_click,
             vr.app_download_start                      AS app_download_start,
             vr.app_download_complete                   AS app_download_complete,
             vr.app_activation                          AS app_activation,
             vr.app_register                            AS app_register,
             vr.app_event_pay                           AS app_event_pay,
             vr.app_event_pay_amount                    AS app_event_pay_amount,
             vr.app_event_next_day_stay                 AS app_event_next_day_stay,
             vr.play_3s_count                           AS play_3s_count,
             vr.create_time                             AS create_time,
             vr.update_time                             AS update_time,
             vr.event_pay_first_day                     AS event_pay_first_day,
             vr.event_pay_purchase_amount_first_day     AS event_pay_purchase_amount_first_day,
             vr.event_pay                               AS event_pay,
             vr.form_count                              AS form_count,
             vr.play_5s_count                           AS play_5s_count,
             vr.play_end_count                          AS play_end_count,
             vr.share_count                             AS share_count,
             vr.comment_count                           AS comment_count,
             vr.like_count                              AS like_count,
             vr.hate_count                              AS hate_count,
             vr.add_follower_count                      AS add_follower_count,
             vr.complain_count                          AS complain_count,
             vr.negative_count                          AS negative_count,
             vr.convert_count                           AS convert_count,
             vr.deep_convert_count                      AS deep_convert_count,
             vr.total_play                              AS total_play,
             vr.valid_play                              AS valid_play,
             vr.play_25_feed_break                      AS play_25_feed_break,
             vr.play_50_feed_break                      AS play_50_feed_break,
             vr.play_75_feed_break                      AS play_75_feed_break,
             vr.play_100_feed_break                     AS play_100_feed_break,
             vr.play_duration_sum                       AS play_duration_sum,
             vr.wifi_play                               AS wifi_play
             FROM makepolo.vendor_material_report vr
               INNER JOIN makepolo.entity_vendor_account eva ON eva.id = vr.vendor_account_id
               LEFT OUTER JOIN makepolo.market_video_dims_local mv
                               ON vr.photo_id = mv.vendor_material_id AND toInt64(eva.company_id) = toInt64(mv.company_id)
            where vr.vendor_id = ${vendor_id}
              and vr.date >= today() - 1 
              and vr.date >= '${start_date}'
              and vr.date <= '${end_date}'
              ${company_type =='1' ? "":"and eva.company_id in ("+ company_id +" )"}
         ${strutil.contain(director_id!'-1', '-1') ? "":"and mv.director_id in ( "+ director_id +" )"}  -- dims
         ${strutil.contain(writer_id!'-1', '-1') ? "":"and mv.writer_id in ( "+ writer_id +" )"}        -- dims
         ${strutil.contain(camerist_id!'-1', '-1') ? "":"and mv.camerist_id in ( "+ camerist_id +" )"}  -- dims
         ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and mv.late_producer_id in ( "+ late_producer_id +" )"}  -- dims
      ) a
         left join tidb_makepolo.material_market_video mmv on toInt64(a.material_video_id) = toInt64(mmv.id)
         left join tidb_makepolo.material_market_order mmo on mmv.order_id = mmo.id
         left join tidb_makepolo_common.account_user au on au.id = mmo.account_id
         left join tidb_makepolo_common.account_admin ad on ${company_type =='1' ? "au.company_id = ad.id":"mmo.owner_creator_id = ad.id"}  
         left join (select id, name from tidb_makepolo.creator_role where id > 0) director on director.id = a.director_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) writer on writer.id = a.writer_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) camerist on camerist.id = a.camerist_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) late on late.id = a.late_producer_id
         left join tidb_makepolo_common.vendor ev on ev.vendor_id=a.vendor_id
      where is_test_data = 0
         ${company_type =='1' ? "and mmo.owner_creator_id in ("+ company_id +" )":""}
         ${strutil.contain(demand_id!'-1', '-1') ? "":"and eva.company_id in ( "+ demand_id +" )"} -- 需求方id
         ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mmo.owner_creator_id in ( "+ owner_creator_id +" )"} -- 创作团队id
         ${strutil.contain(order_id!'-1', '-1') ? "":"and mmv.order_id in ( "+ order_id +" )"}  -- 订单id
      group by replace_video_index
 ) creative
group by replace_video_index
order by cost desc