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
*/


select
       replace_video_index
      , url as video_url -- 视频链接
      , video_title    -- 视频标题
      , vendor_id
      , name as demand_name --  需求方 ${company_type =='1' ? "'需求方'":"'创作团队'"}     
      , name as creator_name -- 创作团队
      , order_id
      , order_name
      , if(director_name is null,'_',director_name) as director_name
      , if(writer_name is null,'_',writer_name) as writer_name
      , if(camerist_name is null,'_',camerist_name) as camerist_name
      , if(late_name is null,'_',late_name) as late_name
      , cost -- 消耗金额
      , content_impression as content_impression_ks -- 素材曝光数 快手
      , impression as content_impression_tt -- 展示数 头条
      , if(content_impression=0, 0, play_3s_count / content_impression) as play_3s_rate_ks -- 3秒播放率快手
      , if(total_play=0, 0, (play_3s_count/100) / total_play) as play_3s_rate_tt -- 3秒播放率头条
      , if(content_impression=0, 0, play_5s_count / content_impression) as play_5s_rate_ks -- 5秒播放率快手
      , if(total_play=0, 0, (play_5s_count /100) / total_play) as play_5s_rate_tt -- 5秒播放率头条
      , if(content_impression=0, 0, play_end_count / content_impression) as play_end_rate_ks -- 完播率快手
      , if(total_play=0, 0, (play_end_count /100) / total_play) as play_end_rate_tt -- 完播率头条
      , share_count -- 分享数
      , comment_count -- 评论数
      , like_count -- 点赞数
      , add_follower_count -- 新增关注
      , complain_count -- 举报
      , negative_count -- 减少此类作品数
      , hate_count -- 拉黑数
      , cover_image_url -- 视频封面
      , total_play -- 播放数
      , valid_play -- 有效播放数
      , if(total_play=0, 0, play_25_feed_break / total_play) as play_25_rate -- 25%进度播放率
      , if(total_play=0, 0, play_50_feed_break   / total_play) as play_50_rate -- 50%进度播放率
      , if(total_play=0, 0, play_75_feed_break   / total_play) as play_75_rate -- 75%进度播放率
      , if(total_play=0, 0, play_100_feed_break  / total_play) as play_100_rate -- 99%进度播放率
      , click -- 点击数
      , if(content_impression=0, 0, click / content_impression) as click_rate_ks -- 点击率快手
      , if(impression=0, 0, click / impression) as click_rate_tt  -- 点击率头条
      , if(content_impression=0, 0, valid_play / content_impression)  as valid_play_rate_ks -- 有效播放率 快手
      , if(impression=0, 0, valid_play / impression)  as valid_play_rate_tt -- 有效播放率 头条
      , if(valid_play=0, 0, cost / valid_play) as valid_play_cost --  有效播放成本
      , if(total_play=0, 0, play_duration_sum / total_play) as avg_play_duration -- 平均播放时长
      , round(play_end_count / 100) as play_end_count -- 完整播放数
      , if(convert_count=0, 0, cost / convert_count) as convert_cost -- 转化成本
      , deep_convert_count -- 深度转化数
      , content_click  -- 行为数
      , if(content_impression=0, 0, content_click / content_impression) as content_rate -- 行为率
      , convert_count -- 转化数
      , if(click=0, 0, convert_count / click) as convert_rate -- 转化率 
      , if(click=0, 0, deep_convert_count / click) as deep_convert_rate -- 深度转化率
      , play_3s_count as play_3s_count1
      , play_5s_count as play_5s_count1
      , play_end_count as play_end_count1
      , convert_count as convert_count1
      , content_impression as content_impression1
      , deep_convert_count as deep_convert_count1
      , play_duration_sum as play_duration_sum1
      , total_play as total_play1
      , valid_play as valid_play1
      , play_25_feed_break as play_25_feed_break1
      , play_50_feed_break as play_50_feed_break1
      , play_75_feed_break as play_75_feed_break1
      , play_100_feed_break as play_100_feed_break1
from (
      select  replace_video_index
             , max(if(is_replace_video=0, b.url, null))  url
             , max(if(is_replace_video=0, b.cover_image_url, null)) cover_image_url
             , max(ev.name) vendor_id
             , max(if(is_replace_video=0, b.name, null))  video_title
             , max(e.name)  name
        	 , max(c.name)            order_name
        	 , max(c.id)              order_id
             , max(director.name)     director_name
             , max(writer.name)       writer_name
             , max(camerist.name)     camerist_name
          	 , max(late.name)             late_name
             , sum(play_3s_count)         play_3s_count
             , sum(play_5s_count)         play_5s_count
             , sum(content_impression)    content_impression
         	 , sum(impression)            impression
             , sum(play_25_feed_break)    play_25_feed_break
             , sum(play_50_feed_break)    play_50_feed_break
             , sum(play_75_feed_break)    play_75_feed_break
             , sum(play_100_feed_break)   play_100_feed_break
             , sum(play_duration_sum ) / 1000    play_duration_sum
             , sum(cost) / 10000          cost
             , sum(share_count)           share_count
             , sum(comment_count)         comment_count
             , sum(like_count)            like_count
             , sum(hate_count)            hate_count
             , sum(add_follower_count)    add_follower_count
             , sum(complain_count)        complain_count
             , sum(negative_count)        negative_count
             , sum(total_play)            total_play
             , sum(valid_play)            valid_play
             , sum(click)                 click
             , sum(play_end_count)        play_end_count
        	 , sum(content_click)         content_click
             , sum(convert_count)         convert_count
        	 , sum(deep_convert_count)    deep_convert_count
      from makepolo.material_report a
          join makepolo.material_market_video b on a.material_video_id = b.id
          join makepolo.material_market_order c on b.order_id = c.id
          join makepolo_common.account_user d on d.id = c.account_id
        	-- join makepolo_common.account_user vau on a.video_account_id = vau.id
          join makepolo_common.account_admin e on ${company_type =='1' ? "d.company_id = e.id":"c.owner_creator_id = e.id"}  
         left join makepolo.creator_role director on director.id = a.director_id and director.id > 0
         left join makepolo.creator_role writer on writer.id = a.writer_id and writer.id > 0
         left join  makepolo.creator_role camerist on camerist.id = a.camerist_id and camerist.id > 0
         left join makepolo.creator_role late on late.id = a.late_producer_id and late.id > 0
         left join makepolo_common.vendor ev on ev.vendor_id=a.vendor_id
      where is_test_data = 0
         and ${company_type =='1' ? "c.owner_creator_id":"a.company_id"} = ${company_id} 
         and a.vendor_id = ${vendor_id}
        -- and d.company_type = ${company_type} 
         ${strutil.contain(demand_id!'-1', '-1') ? "":"and d.company_id in ( "+ demand_id +" )"}
         ${strutil.contain(owner_creator_id!'-1', '-1') ? "":"and c.owner_creator_id in ( "+ owner_creator_id +" )"}
         ${strutil.contain(order_id!'-1', '-1') ? "":"and b.order_id in ( "+ order_id +" )"}
         ${strutil.contain(director_id!'-1', '-1') ? "":"and a.director_id in ( "+ director_id +" )"} 
         ${strutil.contain(writer_id!'-1', '-1') ? "":"and a.writer_id in ( "+ writer_id +" )"} 
         ${strutil.contain(camerist_id!'-1', '-1') ? "":"and a.camerist_id in ( "+ camerist_id +" )"} 
         ${strutil.contain(late_producer_id!'-1', '-1') ? "":"and a.late_producer_id in ( "+ late_producer_id +" )"} 
        
         and a.date >= '{{start_date}}'
         and a.date <=  '{{end_date}}'
      group by 1
 ) creative
order by cost desc
