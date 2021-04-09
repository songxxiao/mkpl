-- {{start_date}}
-- {{end_date}}
-- {{vendor_account_id}}
-- {{params_account_id}}
-- {{project_id}}
-- {{vendor_id}}
-- {{company_id}}
-- {{is_dat}}
<%
where = "";
if(isNotEmpty(vendor_account_id)){
    where = where + " and ( a.vendor_account_id in ("+vendor_account_id+") or eva.id in ("+vendor_account_id+"))";
} else {
    where = where + " and vendor_account_id = -1";
}

if(isNotEmpty(company_id)){
    where =  where + " and a.company_id in ("+company_id+")";
} else {
   where = where + " and a.company_id = -1";
}

if(isNotEmpty(project_id)){
    where =  where + " and project_id in ("+project_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and a.vendor_id in ("+vendor_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and eva.subordinate_account_id in ("+params_account_id+")";
}

where_cr = "";
if(isNotEmpty(vendor_account_id)){
    where_cr = where_cr + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else {
    where_cr = where_cr + " and cr.vendor_account_id = -1 ";
}

if(isNotEmpty(project_id)){
    where_cr =  where_cr + " and (dims.project_id in ("+project_id+") or pj.id in (" +project_id+") or pro.id in (" +project_id+"))";
}

if(isNotEmpty(vendor_id)){
    where_cr = where_cr + " and cr.vendor_id in ("+vendor_id+")";
}

if(isNotEmpty(company_id)){
    where_cr =  where_cr + " and (eva.company_id in ("+company_id+") or dims.company_id in ("+company_id+"))";
}

if(isNotEmpty(params_account_id)){
    where_cr =  where_cr + " and (eva.subordinate_account_id in ("+params_account_id+") or dims.creative_account_id in (" +params_account_id+"))";
}

where_pj ="";
if(isNotEmpty(vendor_account_id)){
    where_pj = where_pj + "vendor_account_id in ("+vendor_account_id+")";
} else{
    where_pj = where_pj + "vendor_account_id = -1";
}

%>

-- 	    , sum(cost / (1+ (sum(return_point) / 100 ))) / 10000 as cost_rebate
select ${isNotEmpty(is_dat) && is_dat == '0'  ?   日期
        au.name as  optimizer_name -- 优化师名称
      , ifnull(sum(increase_ad), 0) as increase_ad --  新增广告数
      , ifnull(sum(increase_creative), 0) as increase_creative -- 新增创意数
      , sum(cnt_ad) as cnt_ad -- 曝光广告数
      , sum(cnt_creative) as cnt_creative --  '曝光创意数'
      , sum(cost) / 10000 as cost -- '总消耗
      , sum((cost/10000) / (1 + (cr.return_point/100))) as cost_rebate -- 返点后消耗
      , sum(impression) as impression -- 封面曝光数
      , sum(click) as click -- 封面点击数
      , if(sum(impression)=0, 0, sum(click) / sum(impression)) as click_rate --  封面点击率
      , sum(content_impression) as content_impression -- 素材曝光数
      , sum(content_click) as content_click -- 行为数 
      , if(sum(content_impression)=0, 0, sum(content_click) / sum(content_impression)) as content_click_rate -- 行为率
      , if(sum(impression)=0, 0, sum(cost) / sum(impression) * 1000) as impression_cost -- 平均千次封面曝光花费
      , if(sum(click)=0, 0,  sum(cost) / sum(click)) as click_cost -- 平均点击单价
      , if(sum(content_click)=0, 0,  sum(cost) / sum(content_click)) as content_click_cost -- 平均行为单价
      , if(sum(content_impression)=0, 0,  sum(play_3s_count) / sum(content_impression)) as play_3s_rate -- 3秒视频播放率
      , if(sum(content_impression)=0, 0,  sum(play_5s_count) / sum(content_impression)) as play_5s_rate -- 5秒视频播放率
      , sum(app_download_start) app_download_start -- 安卓下载开始数
      , sum(app_download_complete) app_download_complete -- 安卓下载完成数
      , sum(app_activation) as app_activation -- 激活数
      , if(sum(app_download_complete)=0, 0, sum(app_activation) / sum(click)) as app_activation_rate -- 激活率
      , if(sum(app_activation)=0, 0, sum(cost) / sum(app_activation)) as app_activation_cost -- 激活成本
      , sum(app_register) app_register -- 注册数 
      , if(sum(app_register)=0, 0, sum(cost) / sum(app_register)) as app_register_cost -- 注册成本 
      , if(sum(app_activation)=0, 0, sum(app_register) / sum(app_activation)) as app_register_rate -- 注册率
      , sum(app_event_pay_amount) / 10000 as app_event_pay_amount -- 付费金额
      , sum(event_pay_first_day) as event_pay_first_day -- 首日付费次数 
      , sum(event_pay_purchase_amount_first_day) -- 首日付费金额
      , sum(event_pay_purchase_amount_first_day) / sum(cost) as first_day_roi -- 首日ROI
      , sum(event_pay) as event_pay --  付费次数
      , if(sum(event_pay)=0, 0, sum(cost) / sum(event_pay)) as event_pay_cost -- 付费次数成本
      , if(sum(next_day_active_count)=0, 0, sum(app_event_next_day_stay) / sum(next_day_active_count)) as app_event_next_day_stay_rate -- 次日留存率
      , sum(form_count) as form_count -- 表单提交数
      , if(sum(form_count)=0, 0, sum(cost) / sum(form_count)) as form_count_unit_pr2ce -- 表单提交单价
      , if(sum(content_click)=0, 0, sum(form_count) / sum(content_click)) as form_count_click_rate -- 表单提交点击率
      , sum(convert_count)  convert_count-- 转化数 
      , if(sum(click)=0, 0, sum(convert_count) / sum(click)) as convert_rate -- 转化率
      , if(sum(convert_count)=0, 0, sum(cost) / sum(convert_count)) as convert_cost -- 转化成本
      , sum(total_play) total_play -- 播放数
      , sum(valid_play) valid_play -- 有效播放数
      , if(sum(total_play)=0, 0, sum(valid_play) / sum(total_play)) as valid_play_rate -- 有效播放率
      , if(sum(valid_play)=0, 0, sum(cost) / sum(valid_play)) as valid_play_cost -- 有效播放成本
      , if(sum(total_play)=0, 0, sum(play_25_feed_break) / sum(total_play)) as play_25_rate --  25%进度播放率
      , if(sum(total_play)=0, 0, sum(play_50_feed_break) / sum(total_play)) as play_50_rate -- 50%进度播放率
      , if(sum(total_play)=0, 0, sum(play_75_feed_break) / sum(total_play)) as play_75_rate -- 75%进度播放率
      , if(sum(total_play)=0, 0, sum(play_100_feed_break) / sum(total_play)) as play_99_rate -- 99%进度播放率 
      , if(sum(total_play)=0, 0, sum(play_duration_sum)   / sum(total_play)) as play_duration_per_play -- 平均单次播放时长
      , if(sum(total_play)=0, 0, sum(wifi_play) / sum(total_play)) as wifi_play_rate -- WIFI播放占比  
      , sum(deep_convert_count) deep_convert_count --  深度转化次数 
      , if(sum(deep_convert_count)=0, 0, sum(cost) / sum(deep_convert_count)) as deep_convert_cost --  深度转化成本 
      , if(sum(deep_convert_count)=0, 0, sum(deep_convert_count) / sum(click)) as deep_convert_rate --  深度转化率
     -- ----------------------------------------------------------------------------------------------
      , sum(click) as click1
      , sum(impression) as impression1
      , sum(content_impression) as content_impression1
      , sum(cost) as cost1
      , sum(app_activation) as app_activation1
      , sum(next_day_active_count) as next_day_active_count1
      , sum(app_register) as app_register1
      , sum(event_pay) as event_pay1
      , sum(app_event_next_day_stay) as app_event_next_day_stay1
      , sum(event_pay_purchase_amount_first_day) as event_pay_purchase_amount_first_day1
      , sum(form_count) as form_count1
      , sum(content_click) as content_click1
      , sum(play_3s_count) as play_3s_count1
      , sum(play_5s_count) as play_5s_count1
      , sum(deep_convert_count) as deep_convert_count1
      , sum(play_25_feed_break) as play_25_feed_break1
      , sum(play_50_feed_break) as play_50_feed_break1
      , sum(play_75_feed_break) as play_75_feed_break1
      , sum(play_100_feed_break) as play_100_feed_break1
      , sum(total_play) as total_play1
      , sum(valid_play) as valid_play1
      , sum(wifi_play) as wifi_play1
      , sum(play_duration_sum) as play_duration_sum1
      , sum(convert_count) as convert_count1
from (
      select eva.subordinate_account_id account_id
      ${isNotEmpty(is_dat) && is_dat == '0'  ? ", date" : ""} 
      , sum(cost) as cost
	    , sum(eva.return_point) as return_point
      , sum(impression)  as impression
	    , sum(content_impression)  as content_impression
      , sum(click) as click
      , sum(app_activation)  as app_activation
	    , sum(next_day_active_count)  as next_day_active_count
      , sum(app_event_pay_amount) as app_event_pay_amount
	    , sum(event_pay)  as event_pay
	    , sum(play_3s_count)  as play_3s_count
	    , sum(play_5s_count)  as play_5s_count
	    , sum(form_count) as form_count
      , count(distinct if(impression>0, creative_id, null)) as cnt_creative
      , count(distinct if(impression>0, ad_unit_id,  null))  as cnt_ad
	    , sum(app_event_next_day_stay) as app_event_next_day_stay
	    , sum(content_click) as content_click
	    , sum(app_download_start) as app_download_start
	    , sum(app_download_complete) as app_download_complete
	    , sum(app_register) as app_register
	    , sum(event_pay_first_day) as event_pay_first_day
	    , sum(event_pay_purchase_amount_first_day) as event_pay_purchase_amount_first_day
      , sum(convert_count) as convert_count
		  , sum(deep_convert_count) as deep_convert_count
		  , sum(total_play) as total_play
		  , sum(valid_play) as valid_play
		  , sum(wifi_play) as wifi_play
		  , sum(play_25_feed_break) as play_25_feed_break
		  , sum(play_50_feed_break) as play_50_feed_break 
		  , sum(play_75_feed_break) as play_75_feed_break
		  , sum(play_100_feed_break) as play_100_feed_break
		  , sum(play_duration_sum) as play_duration_sum
      , 0 increase_creative
      , 0 increase_ad
      from makepolo.vendor_creative_report cr 
        left join makepolo.creative_report_dims dims 
			on dims.vendor_account_id = cr.vendor_account_id
          		and dims.vendor_creative_id = cr.vendor_creative_id -- ${isNotEmpty(company_id)? " and dims.company_id in (" + company_id + ")" : ""}
        left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
    ${isNotEmpty(project_id)? "left join makepolo.project pro on pro.id=dims.project_id" :""} 
    ${isNotEmpty(project_id)? "left join (select max(project_id) as project_id, vendor_account_id, count(*) from makepolo.vendor_account_project where " + where_pj +" group by 2 having count(*)=1 ) p on eva.id= p.vendor_account_id" :""} 
    ${isNotEmpty(project_id)? "left join makepolo.project pj on pj.id = p.project_id" :""} 
      where cr.date >= '${start_date}'
        and cr.date <= '${end_date}' 
        and cr.vendor_creative_id <> '0'
        ${where_cr}
      group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""} 

      union all
 
      select eva.subordinate_account_id account_id
            ${isNotEmpty(is_dat) && is_dat == '0'  ? ", date_format(create_time,'%Y-%m-%d') as date" : ""} 
        , 0 cost
	      , 0 return_point
        , 0 impression
	      , 0 content_impression
        , 0 click
        , 0 app_activation
	      , 0 next_day_active_count
        , 0 app_event_pay_amount
	      , 0 event_pay
	      , 0 play_3s_count
	      , 0 play_5s_count
	      , 0 form_count
        , 0 cnt_creative
        , 0 cnt_ad
	      , 0 app_event_next_day_stay
	      , 0 content_click
	      , 0 app_download_start
	      , 0 app_download_complete
	      , 0 app_register
	      , 0 event_pay_first_day
	      , 0 event_pay_purchase_amount_first_day
        , 0 convert_count
		    , 0 deep_convert_count
		    , 0 total_play
		    , 0 valid_play
		    , 0 wifi_play
		    , 0 play_25_feed_break
		    , 0 play_50_feed_break 
		    , 0 play_75_feed_break
		    , 0 play_100_feed_break
		    , 0 play_duration_sum
        , count(1) as increase_creative
        , 0 increase_ad
      from makepolo.ad_creative a
      left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
      where a.create_time >= '${start_date} 00:00:00'
        and a.create_time <= '${end_date} 23:59:59'  ${where}
      group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""} 
         
     union all

      select eva.subordinate_account_id account_id
           ${isNotEmpty(is_dat) && is_dat == '0'  ? ", date_format(create_time,'%Y-%m-%d') as date" : ""} 
        , 0 cost
	      , 0 return_point
        , 0 impression
	      , 0 content_impression
        , 0 click
        , 0 app_activation
	      , 0 next_day_active_count
        , 0 app_event_pay_amount
	      , 0 event_pay
	      , 0 play_3s_count
	      , 0 play_5s_count
	      , 0 form_count
        , 0 cnt_creative
        , 0 cnt_ad
	      , 0 app_event_next_day_stay
	      , 0 content_click
	      , 0 app_download_start
	      , 0 app_download_complete
	      , 0 app_register
	      , 0 event_pay_first_day
	      , 0 event_pay_purchase_amount_first_day
        , 0 convert_count
		    , 0 deep_convert_count
		    , 0 total_play
		    , 0 valid_play
		    , 0 wifi_play
		    , 0 play_25_feed_break
		    , 0 play_50_feed_break 
		    , 0 play_75_feed_break
		    , 0 play_100_feed_break
		    , 0 play_duration_sum
        , 0 increase_creative
        , count(1) as increase_ad
      from makepolo.ad_unit a
      left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
      where a.create_time >= '${start_date} 00:00:00'
        and a.create_time <= '${end_date} 23:59:59' ${where}
      group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""} 
) cr
left join makepolo_common.account_user au on au.id = cr.account_id
group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""} 
order by 1 desc





