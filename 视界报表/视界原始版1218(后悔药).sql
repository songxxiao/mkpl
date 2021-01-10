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
-- {{dim}}


/*company_type = 1 素材团队
 company_type = 0 需求方
 role_type = 1 导演
 role_type = 2 编剧
 role_type = 3 摄像
 role_type = 4 后期
*/


select
       material_video_id
      , url           as video_url -- 视频链接
     , video_title    -- 视频标题
     , if(vendor_id=1,'快手','今日头条')  as vendor_id
      , name --  as  ${company_type =='1' ? "'需求方'":"'创作团队'"}     
      , if(director_name is null,'_',director_name) as director_name
      , if(writer_name is null,'_',writer_name) as writer_name
      , if(camerist_name is null,'_',camerist_name) as camerist_name
      , if(late_name is null,'_',late_name) as late_name
      
      ${strutil.contain(dim,"cost")? " , cost as consume_money" :""}  -- 消耗金额
     
      , content_impression -- 视频曝光数
      , play_3s_count / ${strutil.contain(vendor_id!'1', '1') ? "content_impression":"total_play"} as play_3s_rate -- 3秒播放率
      , play_5s_count / ${strutil.contain(vendor_id!'1', '1') ? "content_impression":"total_play"} as play_5s_rate -- 5秒播放率
      ,  ${strutil.contain(vendor_id!'1', '1') ? "play_end_count":"play_end_count /100"}  / ${strutil.contain(vendor_id!'1', '1') ? "content_impression":"total_play"} as play_end_rate  -- 完整播放率
      , share_count    -- 分享数
      , comment_count  -- 评论数
      , like_count     -- 点赞数
      , add_follower_count -- 新增关注
      , complain_count -- 举报
      , negative_count-- 减少此类作品数
      , hate_count -- 拉黑
      , cover_image_url as cover_img_url  -- 视频封面
      , total_play -- 播放数
      , valid_play -- 有效播放数
      , play_25_feed_break   / total_play as play_25_rate -- 25%进度播放率
      , play_50_feed_break   / total_play as play_50_rate -- 50%进度播放率
      , play_75_feed_break   / total_play as play_75_rate -- 75%进度播放率
      , play_100_feed_break  / total_play as play_100_rate  -- 99%进度播放率
      , click -- 点击数
      , click/content_impression as click_rate -- 点击率
      , valid_play / content_impression  as valid_play_rate      -- 有效播放率
      , cost / valid_play as valid_play_cost                --  有效播放成本
      , play_duration_sum / total_play as  avg_play_duration               -- 平均播放时长(单位ms)
      , play_end_count  -- 完整播放数
      , deep_convert_count
       ${strutil.contain(vendor_id!'1', '1') ? ", content_click":" "} -- 行为数
       ${strutil.contain(vendor_id!'1', '1') ? ", content_click/content_impression as content_rate":" "} -- 行为率
	   ${strutil.contain(vendor_id!'1', '2') ? ",  convert_count ":" "}  -- 转化数
       ${strutil.contain(vendor_id!'1', '2') ? ",  convert_count/click as convert_rate":" "}  -- 转化率 
       ${strutil.contain(vendor_id!'1', '2') ? ",  deep_convert_count/click as deep_convert_rate":" "}  -- 深度转化率
       , play_3s_count as play_3s_count1
       , play_5s_count as play_5s_count1
       , play_end_count as play_end_count1
       , content_impression as content_impression1
       , play_25_feed_break as play_25_feed_break1
       , play_50_feed_break as play_50_feed_break1
       , play_75_feed_break as play_75_feed_break1
       , play_100_feed_break as play_100_feed_break1
from (
select material_video_id,
       b.url,
       b.cover_image_url,
       vendor_id,
       b.name as video_title,
       e.name,
       max(director.name)  as director_name,
       max(writer.name) as writer_name,
       max(camerist.name) as camerist_name,
 	   max(late.name) as late_name,
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
       sum(play_end_count)       as play_end_count,
  	   sum(content_click)       as content_click ,
       sum(convert_count) as convert_count ,
  	   sum(deep_convert_count) as deep_convert_count
from makepolo.material_report a
    join makepolo.material_market_video b on a.material_video_id = b.id
    join makepolo.material_market_order c on b.order_id = c.id
    join makepolo_common.account_user d on d.id = c.account_id
    join makepolo_common.account_admin e on ${company_type =='1' ? "d.company_id = e.id":"c.owner_creator_id = e.id"}  
   left join makepolo.creator_role director on director.id = a.director_id and director.id > 0
   left join makepolo.creator_role writer on writer.id = a.writer_id and writer.id > 0
   left join  makepolo.creator_role camerist on camerist.id = a.camerist_id and camerist.id > 0
   left join makepolo.creator_role late on late.id = a.late_producer_id and late.id > 0
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
group by 1,2,3,4,5, 6
 ) creative




cnt_ad
cnt_creative
cost
cost_rebate
impression
click
click_rate
content_impression
content_click
content_click_rate
impression_cost
click_cost
content_click_cost
play_3s_rate
play_5s_rate
app_download_start
app_download_complete
app_activation
app_activation_rate
app_activation_cost
app_register
app_register_cost
app_register_rate
app_event_pay_amount
event_pay_first_day
event_pay_purchase_amount_first_day
first_day_roi
event_pay
event_pay_cost
app_event_next_day_stay_rate
form_count
form_count_unit_price
form_count_click_rate
convert_count
convert_rate
convert_cost
total_play
valid_play
valid_play_rate
valid_play_cost
play_25_rate
play_50_rate
play_75_rate
play_99_rate
play_duration_per_play
wifi_play_rate
deep_convert_count
deep_convert_cost
deep_convert_rate



cnt_ad,cnt_creative,cost,cost_rebate,impression,click,click_rate,content_impression,content_click,content_click_rate,impression_cost,click_cost,content_click_cost,play_3s_rate,play_5s_rate,app_download_start,app_download_complete,app_activation,app_activation_rate,app_activation_cost,app_register,app_register_cost,app_register_rate,app_event_pay_amount,event_pay_first_day,event_pay_purchase_amount_first_day,first_day_roi,event_pay,event_pay_cost,app_event_next_day_stay_rate,form_count,form_count_unit_price,form_count_click_rate,convert_count,convert_rate,convert_cost,total_play,valid_play,valid_play_rate,valid_play_cost,play_25_rate,play_50_rate,play_75_rate,play_99_rate,play_duration_per_play,wifi_play_rate,deep_convert_count,deep_convert_cost,deep_convert_rate




