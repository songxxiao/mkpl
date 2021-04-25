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
-- {{video_name}}

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
      , sum(Impression) as impression
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
  --    , round(play_end_count / 100) as play_end_count1
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
      , sum(Play_7s_count) as play_7s_count
      , sum(Play_end_count) as play_end_count
      , sum(Play_duration_sum) / 1000 as play_duration_sum
      , sum(Play_10_feed_break) as play_10_feed_break
      , sum(Play_25_feed_break) as play_25_feed_break
      , sum(Play_50_feed_break) as play_50_feed_break
      , sum(Play_75_feed_break) as play_75_feed_break
      , sum(Play_95_feed_break) as play_95_feed_break
      , sum(Play_100_feed_break) as play_100_feed_break
      , sum(Content_click) as valuable_click_count
      , ifNotFinite(valuable_click_count/impression, 0) as valuable_click_rate
      , sum(Forward_count)        forward_count
      , sum(Read_count)	         read_count
      , sum(From_follow_uv)       from_follow_uv
      , sum(Active_page_views)    active_page_views
      , sum(Active_page_viewers)  active_page_viewers
      , sum(Active_page_interaction_amount)  active_page_interaction_amount
      , sum(Active_page_interaction_users)   active_page_interaction_users
      , sum(Join_chat_group_amount)  join_chat_group_amount
      , sum(Video_play_count)     video_play_count
      , ifNotFinite(play_duration_sum / total_play, 0) video_outer_play_time_count -- 平均有效播放时长
      , sum(Video_outer_play_time_avg_rate) video_outer_play_time_avg_rate
      , ifNotFinite(valid_play / impression, 0)  as video_outer_play_rate -- 有效播放率
from (
     select replace_video_index
             , max(if(is_replace_video=0, material_market_video_url, null)) Video_url
             , max(if(is_replace_video=0, cover_image_url, null)) Cover_image_url
             , max(if(is_replace_video=0, market_video_name, null))  Video_title
             , max(ev.name) Vendor_id
             , max(ad.company_name)  Company_name
        	   , max(order_name)            Order_name
        	   , max(order_id)              Order_id
             , max(director.name)     Director_name
             , max(writer.name)       Writer_name
             , max(camerist.name)     Camerist_name
          	 , max(late.name)             Late_name
             , sum(play_3s_count)         Play_3s_count
             , sum(play_5s_count)         Play_5s_count
             , sum(play_7s_count)         Play_7s_count
             , sum(content_impression)    Content_impression
         	   , sum(impression)            Impression
             , sum(play_10_feed_break)    Play_10_feed_break
             , sum(play_25_feed_break)    Play_25_feed_break
             , sum(play_50_feed_break)    Play_50_feed_break
             , sum(play_75_feed_break)    Play_75_feed_break
             , sum(play_95_feed_break)    Play_95_feed_break
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
             , sum(forward_count)        Forward_count
             , sum(read_count)	         Read_count
             , sum(from_follow_uv)       From_follow_uv
             , sum(active_page_views)    Active_page_views
             , sum(active_page_viewers)  Active_page_viewers
             , sum(active_page_interaction_amount)  Active_page_interaction_amount
             , sum(active_page_interaction_users)   Active_page_interaction_users
             , sum(join_chat_group_amount)  Join_chat_group_amount
             , sum(video_play_count)     Video_play_count
             , sum(video_outer_play_time_avg_rate) Video_outer_play_time_avg_rate
      from (
          select  mv.company_id                              as company_id
                , mv.account_id                              as account_id 
                , mv.local_video_id                          as local_video_id 
                , mv.material_video_id                       as material_video_id 
                , mv.creative_count                          as creative_count
                , mv.video_account_id                        as video_account_id 
                , mv.video_url                               as video_url 
                , mv.video_name                              as video_name
                , mv.create_source                           as create_source 
                , mv.material_market_creator_id              as material_market_creator_id 
                , mv.director_id                             as director_id 
                , mv.writer_id                               as writer_id 
                , mv.camerist_id                             as camerist_id 
                , mv.late_producer_id                        as late_producer_id 
                , mv.material_market_video_replace_video_index as replace_video_index
                , mv.material_market_video_is_replace_video as is_replace_video
                , mv.material_market_video_url              as material_market_video_url
                , mv.material_market_video_cover_image_url  as cover_image_url
                , mv.material_market_video_name             as market_video_name
                , mv.material_market_order_id               as order_id
                , mv.material_market_order_name             as order_name
                , vr.vendor_id          vendor_id
                , vr.play_3s_count          play_3s_count
                , vr.play_5s_count          play_5s_count
                , vr.play_7s_count          play_7s_count
                , vr.content_impression     content_impression
         	      , vr.impression             impression
                , vr.play_10_feed_break     play_10_feed_break
                , vr.play_25_feed_break     play_25_feed_break
                , vr.play_50_feed_break     play_50_feed_break
                , vr.play_75_feed_break     play_75_feed_break
                , vr.play_95_feed_break     play_95_feed_break
                , vr.play_100_feed_break    play_100_feed_break
                , vr.play_duration_sum      play_duration_sum
                , vr.cost                   cost
                , vr.share_count            share_count
                , vr.comment_count          comment_count
                , vr.like_count             like_count
                , vr.hate_count             hate_count
                , vr.add_follower_count     add_follower_count
                , vr.complain_count         complain_count
                , vr.negative_count         negative_count
                , vr.total_play             total_play
                , vr.valid_play             valid_play
                , vr.click                  click
                , vr.play_end_count         play_end_count
        	      , vr.content_click          content_click
                , vr.convert_count          convert_count
        	      , vr.deep_convert_count     deep_convert_count
                , vr.forward_count          forward_count
                , vr.read_count 	           read_count
                , vr.from_follow_uv         from_follow_uv
                , vr.active_page_views      active_page_views
                , vr.active_page_viewers    active_page_viewers
                , vr.active_page_interaction_amount   active_page_interaction_amount
                , vr.active_page_interaction_users    active_page_interaction_users
                , vr.join_chat_group_amount   join_chat_group_amount
                , vr.video_play_count      video_play_count
                , vr.video_outer_play_time_avg_rate  video_outer_play_time_avg_rate
           from makepolo.vendor_material_report vr
           left join (select * from makepolo.entity_vendor_account where 1=1 ${company_type =='1' ? "":"and company_id in ("+ company_id +" )"}) eva on eva.id = vr.vendor_account_id
           global left join (
                    select * 
                    from makepolo.market_video_dims 
                    where 1=1 
                    ${company_type =='1' ? "and material_market_creator_id in ("+ company_id +" )":"and company_id in ("+ company_id +" )"}
                    ${strutil.contain(demand_id!'-1', '-1') ? "":"and mv.company_id in ( "+ demand_id +" )"}
                    ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and material_market_creator_id in ( "+ owner_creator_id +" )"}
                    ${strutil.contain(order_id!'-1', '-1') ? "":"and material_market_order_id in ( "+ order_id +" )"}
                    ${strutil.contain(director_id!'-1', '-1') ? "":"and director_id in ( "+ director_id +" )"}  -- dims
                    ${strutil.contain(writer_id!'-1', '-1') ? "":"and writer_id in ( "+ writer_id +" )"}        -- dims
                    ${strutil.contain(camerist_id!'-1', '-1') ? "":"and camerist_id in ( "+ camerist_id +" )"}  -- dims
                    ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and late_producer_id in ( "+ late_producer_id +" )"} 
                    ${isNotEmpty(video_name)? "and material_market_video_name like '%" + video_name + "%'" : ""}
                ) mv on vr.photo_id = mv.vendor_material_id and toInt64(eva.company_id) = toInt64(mv.company_id)
            where vr.is_test_data = 0
              and vr.vendor_id = ${vendor_id}
              and vr.date < today() - 1 
              and vr.date >= '${start_date}'
              and vr.date <= '${end_date}'
         ${company_type =='1' ? "and mv.material_market_creator_id in ("+ company_id +" )":"and mv.company_id in ("+ company_id +" )"}
         ${strutil.contain(demand_id!'-1', '-1') ? "":"and mv.company_id in ( "+ demand_id +" )"}
         ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mv.material_market_creator_id in ( "+ owner_creator_id +" )"}
         ${strutil.contain(order_id!'-1', '-1') ? "":"and mv.material_market_order_id in ( "+ order_id +" )"}  -- 订单id
         ${strutil.contain(director_id!'-1', '-1') ? "":"and mv.director_id in ( "+ director_id +" )"}  -- dims
         ${strutil.contain(writer_id!'-1', '-1') ? "":"and mv.writer_id in ( "+ writer_id +" )"}        -- dims
         ${strutil.contain(camerist_id!'-1', '-1') ? "":"and mv.camerist_id in ( "+ camerist_id +" )"}  -- dims
         ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and mv.late_producer_id in ( "+ late_producer_id +" )"}  -- dims
         ${isNotEmpty(video_name)? "and market_video_name like '%" + video_name + "%'" : ""}
      ) a
        -- left join tidb_makepolo.material_market_video mmv on toInt64(a.material_video_id) = toInt64(mmv.id)
        -- left join tidb_makepolo.material_market_order mmo on mmv.order_id = mmo.id
        -- left join tidb_makepolo_common.account_user au on au.id = mmo.account_id
         left join tidb_makepolo_common.account_admin ad on ${company_type =='1' ? "toInt64(a.company_id) = toInt64(ad.id)":"toInt64(a.material_market_creator_id) = toInt64(ad.id)"}  
         left join (select id, name from tidb_makepolo.creator_role where id > 0) director on director.id = a.director_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) writer on writer.id = a.writer_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) camerist on camerist.id = a.camerist_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) late on late.id = a.late_producer_id
         left join tidb_makepolo_common.vendor ev on ev.vendor_id = a.vendor_id
     -- ${company_type =='1' ? "and mmo.owner_creator_id in ("+ company_id +" )":""}
     -- ${strutil.contain(demand_id!'-1', '-1') ? "":"and eva.company_id in ( "+ demand_id +" )"} -- 需求方id
     -- ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mmo.owner_creator_id in ( "+ owner_creator_id +" )"} -- 创作团队id
     -- ${strutil.contain(order_id!'-1', '-1') ? "":"and mmv.order_id in ( "+ order_id +" )"}  -- 订单id
      group by replace_video_index

      union all

     select replace_video_index
             , max(if(is_replace_video=0, material_market_video_url, null)) Video_url
             , max(if(is_replace_video=0, cover_image_url, null)) Cover_image_url
             , max(if(is_replace_video=0, market_video_name, null))  Video_title
             , max(ev.name) Vendor_id
             , max(ad.company_name)  Company_name
        	   , max(order_name)            Order_name
        	   , max(order_id)              Order_id
             , max(director.name)     Director_name
             , max(writer.name)       Writer_name
             , max(camerist.name)     Camerist_name
          	 , max(late.name)             Late_name
             , sum(play_3s_count)         Play_3s_count
             , sum(play_5s_count)         Play_5s_count
             , sum(play_7s_count)         Play_7s_count
             , sum(content_impression)    Content_impression
         	   , sum(impression)            Impression
             , sum(play_10_feed_break)    Play_10_feed_break
             , sum(play_25_feed_break)    Play_25_feed_break
             , sum(play_50_feed_break)    Play_50_feed_break
             , sum(play_75_feed_break)    Play_75_feed_break
             , sum(play_95_feed_break)    Play_95_feed_break
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
             , sum(forward_count)        Forward_count
             , sum(read_count)	         Read_count
             , sum(from_follow_uv)       From_follow_uv
             , sum(active_page_views)    Active_page_views
             , sum(active_page_viewers)  Active_page_viewers
             , sum(active_page_interaction_amount)  Active_page_interaction_amount
             , sum(active_page_interaction_users)   Active_page_interaction_users
             , sum(join_chat_group_amount)  Join_chat_group_amount
             , sum(video_play_count)     Video_play_count
             , sum(video_outer_play_time_avg_rate) Video_outer_play_time_avg_rate
      from (
          select  mv.company_id                              as company_id
                , mv.account_id                              as account_id 
                , mv.local_video_id                          as local_video_id 
                , mv.material_video_id                       as material_video_id 
                , mv.creative_count                          as creative_count
                , mv.video_account_id                        as video_account_id 
                , mv.video_url                               as video_url 
                , mv.video_name                              as video_name
                , mv.create_source                           as create_source 
                , mv.material_market_creator_id              as material_market_creator_id 
                , mv.director_id                             as director_id 
                , mv.writer_id                               as writer_id 
                , mv.camerist_id                             as camerist_id 
                , mv.late_producer_id                        as late_producer_id 
                , mv.material_market_video_replace_video_index as replace_video_index
                , mv.material_market_video_is_replace_video as is_replace_video
                , mv.material_market_video_url              as material_market_video_url
                , mv.material_market_video_cover_image_url  as cover_image_url
                , mv.material_market_video_name             as market_video_name
                , mv.material_market_order_id               as order_id
                , mv.material_market_order_name             as order_name
                , vr.vendor_id          vendor_id
                , vr.play_3s_count          play_3s_count
                , vr.play_5s_count          play_5s_count
                , vr.play_7s_count          play_7s_count
                , vr.content_impression     content_impression
         	      , vr.impression             impression
                , vr.play_10_feed_break     play_10_feed_break
                , vr.play_25_feed_break     play_25_feed_break
                , vr.play_50_feed_break     play_50_feed_break
                , vr.play_75_feed_break     play_75_feed_break
                , vr.play_95_feed_break     play_95_feed_break
                , vr.play_100_feed_break    play_100_feed_break
                , vr.play_duration_sum      play_duration_sum
                , vr.cost                   cost
                , vr.share_count            share_count
                , vr.comment_count          comment_count
                , vr.like_count             like_count
                , vr.hate_count             hate_count
                , vr.add_follower_count     add_follower_count
                , vr.complain_count         complain_count
                , vr.negative_count         negative_count
                , vr.total_play             total_play
                , vr.valid_play             valid_play
                , vr.click                  click
                , vr.play_end_count         play_end_count
        	      , vr.content_click          content_click
                , vr.convert_count          convert_count
        	      , vr.deep_convert_count     deep_convert_count
                , vr.forward_count          forward_count
                , vr.read_count 	           read_count
                , vr.from_follow_uv         from_follow_uv
                , vr.active_page_views      active_page_views
                , vr.active_page_viewers    active_page_viewers
                , vr.active_page_interaction_amount   active_page_interaction_amount
                , vr.active_page_interaction_users    active_page_interaction_users
                , vr.join_chat_group_amount   join_chat_group_amount
                , vr.video_play_count      video_play_count
                , vr.video_outer_play_time_avg_rate  video_outer_play_time_avg_rate
           from makepolo.vendor_material_report vr
           left join (select * from makepolo.entity_vendor_account where 1=1 ${company_type =='1' ? "":"and company_id in ("+ company_id +" )"}) eva on eva.id = vr.vendor_account_id
           global left join (
                    select * 
                    from makepolo.market_video_dims 
                    where 1=1 
                    ${company_type =='1' ? "and material_market_creator_id in ("+ company_id +" )":"and company_id in ("+ company_id +" )"}
                    ${strutil.contain(demand_id!'-1', '-1') ? "":"and mv.company_id in ( "+ demand_id +" )"}
                    ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and material_market_creator_id in ( "+ owner_creator_id +" )"}
                    ${strutil.contain(order_id!'-1', '-1') ? "":"and material_market_order_id in ( "+ order_id +" )"}
                    ${strutil.contain(director_id!'-1', '-1') ? "":"and director_id in ( "+ director_id +" )"}  -- dims
                    ${strutil.contain(writer_id!'-1', '-1') ? "":"and writer_id in ( "+ writer_id +" )"}        -- dims
                    ${strutil.contain(camerist_id!'-1', '-1') ? "":"and camerist_id in ( "+ camerist_id +" )"}  -- dims
                    ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and late_producer_id in ( "+ late_producer_id +" )"} 
                    ${isNotEmpty(video_name)? "and material_market_video_name like '%" + video_name + "%'" : ""}
                ) mv on vr.photo_id = mv.vendor_material_id and toInt64(eva.company_id) = toInt64(mv.company_id)
            where vr.is_test_data = 0
              and vr.vendor_id = ${vendor_id}
              and vr.date >= today() - 1 
              and vr.date >= '${start_date}'
              and vr.date <= '${end_date}'
         ${company_type =='1' ? "and mv.material_market_creator_id in ("+ company_id +" )":"and mv.company_id in ("+ company_id +" )"}
         ${strutil.contain(demand_id!'-1', '-1') ? "":"and mv.company_id in ( "+ demand_id +" )"}
         ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mv.material_market_creator_id in ( "+ owner_creator_id +" )"}
         ${strutil.contain(order_id!'-1', '-1') ? "":"and mv.material_market_order_id in ( "+ order_id +" )"}  -- 订单id
         ${strutil.contain(director_id!'-1', '-1') ? "":"and mv.director_id in ( "+ director_id +" )"}  -- dims
         ${strutil.contain(writer_id!'-1', '-1') ? "":"and mv.writer_id in ( "+ writer_id +" )"}        -- dims
         ${strutil.contain(camerist_id!'-1', '-1') ? "":"and mv.camerist_id in ( "+ camerist_id +" )"}  -- dims
         ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and mv.late_producer_id in ( "+ late_producer_id +" )"}  -- dims
         ${isNotEmpty(video_name)? "and market_video_name like '%" + video_name + "%'" : ""}
      ) a
        -- left join tidb_makepolo.material_market_video mmv on toInt64(a.material_video_id) = toInt64(mmv.id)
        -- left join tidb_makepolo.material_market_order mmo on mmv.order_id = mmo.id
        -- left join tidb_makepolo_common.account_user au on au.id = mmo.account_id
         left join tidb_makepolo_common.account_admin ad on ${company_type =='1' ? "toInt64(a.company_id) = toInt64(ad.id)":"toInt64(a.material_market_creator_id) = toInt64(ad.id)"}  
         left join (select id, name from tidb_makepolo.creator_role where id > 0) director on director.id = a.director_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) writer on writer.id = a.writer_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) camerist on camerist.id = a.camerist_id
         left join (select id, name from tidb_makepolo.creator_role where id > 0) late on late.id = a.late_producer_id
         left join tidb_makepolo_common.vendor ev on ev.vendor_id = a.vendor_id
     -- ${company_type =='1' ? "and mmo.owner_creator_id in ("+ company_id +" )":""}
     -- ${strutil.contain(demand_id!'-1', '-1') ? "":"and eva.company_id in ( "+ demand_id +" )"} -- 需求方id
     -- ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and mmo.owner_creator_id in ( "+ owner_creator_id +" )"} -- 创作团队id
     -- ${strutil.contain(order_id!'-1', '-1') ? "":"and mmv.order_id in ( "+ order_id +" )"}  -- 订单id
      group by replace_video_index
 ) creative
group by replace_video_index
order by cost desc
