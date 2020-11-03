

-- {{start_date}}
-- {{end_date}}
-- {{vendor_id}}
-- {{demand_id}}
-- {{company_id}}
-- {{order_id}}


select  
       material_video_id
     , vendor_id 
     , mkt_video.url           as video_url
     , mkt_video.cover_image_url as cover_img_url
-- 快手
      , content_impression -- 视频曝光数
      , play_5s_count
      , play_3s_count / content_impression as play_3s_rate -- 3秒播放率
      , play_5s_count / content_impression as play_5s_rate -- 5秒播放率
      , play_end_count / content_impression as play_end_rate  -- 完整播放率
      , click/content_impression as click_rate -- 点击率
      , share_count    -- 转
      , comment_count  -- 评
      , like_count     -- 赞
      , add_follower_count -- 新增关注
      , complain_count -- 举报
      , hate_count -- 拉黑
      , negative_count-- 减少此类作品数
      -- 头条
      , play_25_feed_break   / total_play as play_25_rate -- 25%进度播放率
      , play_50_feed_break   / total_play as play_50_rate -- 50%进度播放率
      , play_75_feed_break   / total_play as play_75_rate -- 75%进度播放率
      , play_100_feed_break  / total_play as play_100_rate  -- 99%进度播放率
      , play_end_count / total_play as play_end_rate       -- 100%进度播放率 完整播放率
      , play_3s_count / total_play as play_3s_rate     -- 3秒播放率 
      , play_5s_count / total_play as play_5s_rate     -- 5秒播放率
      , click / content_impression as click_rate         -- 点击率
      , valid_play / total_play  as valid_play_rate      -- 有效播放率
      , valid_play / cost as valid_play_cost                --  有效播放成本
      , play_duration_sum / total_play as  avg_play_duration               -- 平均播放时长(单位ms) 
from (
(select video.id as video_id
       , video.url as url
       , video.cover_image_url as cover_image_url
from ( select id from makepolo_common.account_user
  ${strutil.contain(demand_id!'-1', '-1') ? "":"where company_id in ( "+ demand_id +" )"}     ) user 
left join
(  select account_id, id as order_id 
 from makepolo.material_market_order  where owner_creator_id = ${company_id} ${strutil.contain(order_id!'-1', '-1') ? "":"and id in ( "+ order_id +" )"}  ) mkt_order on mkt_order.account_id = user.id
left join
(  select id, order_id from makepolo.material_market_video  ) video on video.order_id = mkt_order.order_id
where video.id is not null ) video_info left join 
(select material_video_id,
       vendor_id,
       sum(play_3s_count)        as play_3s_count,
       sum(play_5s_count)        as play_5s_count,
       sum(content_impression)   as content_impression,
       sum(play_25_feed_break)   as play_25_feed_break,
       sum(play_50_feed_break)   as play_50_feed_break,
       sum(play_75_feed_break)   as play_75_feed_break,
       sum(play_100_feed_break)  as play_100_feed_break,
       sum(play_duration_sum)    as play_duration_sum,
       sum(round(cost * 0.1, 0)) / 1000 as cost,
       sum(share_count)          as share_count,
       sum(comment_count)        as comment_count,
       sum(like_count)           as like_count,
       sum(hate_count)           as hate_count,
       sum(add_follower_count)   as add_follower_count,
       sum(complain_count)       as complain_count,
       sum(negative_count)       as negative_count,
       sum(total_play)           as total_play,
       sum(valid_play)           as valid_play,
       sum(click)                as click,
       sum(play_end_count)       as play_end_count
from makepolo.creative_report
where is_test_data = 0
     and vendor_id = {{vendor_id}}
     and date >= '{{start_date}}'
     and date <= '{{end_date}}'
group by material_video_id, vendor_id
order by material_video_id
) creative on creative.material_video_id = video_info.video_id
) all_dt














