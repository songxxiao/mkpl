-- {{start_date}}
-- {{end_date}}
-- {{project_id}}
-- {{params_account_id}}
-- {{vendor_id}}
-- {{vendor_account_id}}
-- {{params_vendor_account_id}}
-- {{company_id}}
-- {{dim}}
<%
where ="";
if(isNotEmpty(vendor_account_id)){
    where = where + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else{
   where = where +  " and cr.vendor_account_id = -1";
 }

if(isNotEmpty(company_id)){
    where =  where + " and eva.company_id in ("+company_id+")";
} else {
   where = where + " and eva.company_id = -1";
}

if(isNotEmpty(project_id)){
    where =  where + " and (dims.project_id  in ("+project_id+") or pj.id in (" +project_id+") or pro.id in (" +project_id+"))";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and eva.subordinate_account_id in ("+params_account_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and cr.vendor_id in ("+vendor_id+")";
}

if(isNotEmpty(params_vendor_account_id)){
    where = where + " and eva.id in ("+params_vendor_account_id+")";
}

where_pj ="";
if(isNotEmpty(vendor_account_id)){
    where_pj = where_pj + "vendor_account_id in ("+vendor_account_id+")";
} else{
    where_pj = where_pj + "vendor_account_id = -1";
}


dimMap = {
"date":"cr.date as date",
"hour":"concat(lpad(cr.hour,2,0),':00') as hour",
"project_id":"if(pro.name is null or pro.name ='', pj.name, pro.name) as project_id",
"params_account_id":"au.name as params_account_id",
"vendor_id":"ev.name as vendor_id",
"params_vendor_account_id":"concat(eva.vendor_account_name,'(',eva.vendor_advertiser_id,')') as params_vendor_account_id"
};


dimStr = strutil.split("date,hour,project_id,params_account_id,vendor_id,params_vendor_account_id",",");

group_str="";
select_str="";
order_str="";

dimArray = strutil.split(dim, ',');
i=0;
for(dm in dimArray){
    if(array.contain(dimStr,dm)){
        i = i+1;
        if(i == 1){
            group_str = i;
            order_str = i;
            select_str = dimMap[dm];
        } else {
            group_str = group_str + "," + i;
            order_str = order_str + "," + i;
            select_str = select_str + "," + dimMap[dm];
        }
    }
}

%>

select ${select_str}

           ${array.contain(dimArray,"cost")? ",sum(cr.cost)/10000 as cost" :""} 
           ${array.contain(dimArray,"cost_rebate")? ",sum((cr.cost/10000) / (1 + (eva.return_point/100))) as cost_rebate" :""} 
           ${array.contain(dimArray,"impression")? ",sum(cr.impression) as impression" :""} 
           ${array.contain(dimArray,"click")? ",sum(cr.click) as click" :""}
           ${array.contain(dimArray,"click_rate")? ",if(sum(impression)<>0,sum(click)/sum(impression),0) as click_rate" :""} 
           ${array.contain(dimArray,"content_impression")? ",sum(cr.content_impression) as content_impression" :""}
           ${array.contain(dimArray,"content_click")? ",sum(cr.content_click) as content_click" :""}  
           ${array.contain(dimArray,"content_click_rate")? ",if(sum(content_impression)<>0,sum(content_click)/sum(content_impression),0) as content_click_rate" :""} 
           ${array.contain(dimArray,"impression_cost")? ",if(sum(impression)<>0,sum(cost /10000) / sum(impression/1000),0) as impression_cost" :""}  
           ${array.contain(dimArray,"click_cost")? ",if(sum(click)<>0,sum(cost)/sum(click)/10000,0) as click_cost" :""}   
           ${array.contain(dimArray,"content_click_cost")? ",if(sum(content_click)<>0,sum(cost)/sum(content_click)/10000,0) as content_click_cost" :""} 
           ${array.contain(dimArray,"play_3s_rate")? ",if(sum(content_impression)<>0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate" :""}  
           ${array.contain(dimArray,"play_5s_rate")? ",if(sum(content_impression)<>0,sum(play_5s_count)/sum(content_impression),0) as play_5s_rate" :""}  
           ${array.contain(dimArray,"play_end_rate")? ",if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as play_end_rate" :""}  
           ${array.contain(dimArray,"convert_count")? ",sum(cr.convert_count) as convert_count" :""} 
           ${array.contain(dimArray,"convert_rate")? ",if(sum(cr.click)<>0,sum(cr.convert_count)/sum(cr.click),0) as convert_rate" :""}  
           ${array.contain(dimArray,"convert_cost")? ",if(sum(cr.convert_count)<>0,sum(cr.cost /10000)/sum(cr.convert_count),0) as convert_cost" :""} 
           ${array.contain(dimArray,"deep_convert_count")? ",sum(cr.deep_convert_count) as deep_convert_count" :""} 
           ${array.contain(dimArray,"deep_convert_rate")? ",if(sum(cr.click)<>0,sum(cr.deep_convert_count)/sum(cr.click),0) as deep_convert_rate" :""}
           ${array.contain(dimArray,"deep_convert_cost")? ",if(sum(cr.deep_convert_count)!=0,sum(cr.cost /10000)/sum(cr.deep_convert_count),0) as deep_convert_cost" :""} 
           ${array.contain(dimArray,"app_download_start")? ",sum(cr.app_download_start) as app_download_start" :""}  
           ${array.contain(dimArray,"app_download_complete")? ",sum(cr.app_download_complete) as app_download_complete" :""} 
           ${array.contain(dimArray,"app_activation")? ",sum(cr.app_activation) as app_activation" :""}
           ${array.contain(dimArray,"app_activation_cost")? ",if(sum(app_activation)<>0,sum(cost / 10000)/sum(app_activation),0) as app_activation_cost" :""} 
           ${array.contain(dimArray,"app_activation_rate")? ",if(sum(click)<>0,sum(app_activation)/sum(click),0) as app_activation_rate" :""} 
           ${array.contain(dimArray,"app_register")? ",sum(cr.app_register) as app_register" :""}
           ${array.contain(dimArray,"app_register_cost")? ",if(sum(app_register)<>0,sum(cost /10000)/sum(app_register),0) as app_register_cost" :""}
           ${array.contain(dimArray,"app_register_rate")? ",if(sum(app_activation)<>0,sum(app_register)/sum(app_activation),0) as app_register_rate" :""}
           ${array.contain(dimArray,"app_event_pay_amount")? ",sum(cr.app_event_pay_amount)/10000 as app_event_pay_amount" :""}
           ${array.contain(dimArray,"app_event_next_day_stay_rate")? ",if(sum(next_day_active_count)!=0,sum(app_event_next_day_stay)/sum(next_day_active_count),0) as app_event_next_day_stay_rate" :""}
           ${array.contain(dimArray,"event_pay_first_day")? ",sum(cr.event_pay_first_day) as event_pay_first_day" :""}
           ${array.contain(dimArray,"event_pay_purchase_amount_first_day")? ",sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day" :""} 
           ${array.contain(dimArray,"first_day_roi")? ",if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi" :""} 
           ${array.contain(dimArray,"event_pay")? ",sum(cr.event_pay) as event_pay" :""} 
           ${array.contain(dimArray,"event_pay_cost")? ",if(sum(cr.event_pay)!=0,sum(cr.cost /10000 )/sum(cr.event_pay),0) as event_pay_cost" :""} 
           ${array.contain(dimArray,"form_count")? ",sum(cr.form_count) as form_count" :""} 
           ${array.contain(dimArray,"form_count_click_rate")? ",if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate" :""} 
           ${array.contain(dimArray,"form_count_unit_price")? ",if(sum(cr.form_count)!=0,sum(cr.cost /10000)/sum(cr.form_count),0) as form_count_unit_price" :""}
           ${array.contain(dimArray,"total_play")? ",sum(cr.total_play) as total_play" :""} 
           ${array.contain(dimArray,"valid_play")? ",sum(cr.valid_play) as valid_play" :""}
           ${array.contain(dimArray,"valid_play_rate")? ",if(sum(cr.total_play)!=0,sum(cr.valid_play)/sum(cr.total_play),0) as valid_play_rate" :""} 
           ${array.contain(dimArray,"valid_play_cost")? ",if(sum(cr.valid_play)!=0,sum(cr.cost /10000 )/sum(cr.valid_play),0) as valid_play_cost" :""} 
           ${array.contain(dimArray,"play_25_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_25_feed_break) /sum(cr.total_play)) as play_25_rate" :""} 
           ${array.contain(dimArray,"play_50_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_50_feed_break) /sum(cr.total_play))  as play_50_rate" :""} 
           ${array.contain(dimArray,"play_75_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_75_feed_break) /sum(cr.total_play))  as play_75_rate" :""} 
           ${array.contain(dimArray,"play_100_feed_break_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_100_feed_break) /sum(cr.total_play)) as play_100_feed_break_rate" :""} 
           ${array.contain(dimArray,"play_duration_per_play")? ",if(sum(cr.total_play)!=0,sum(cr.play_duration_sum)/sum(cr.total_play),0) as play_duration_per_play" :""}
           ${array.contain(dimArray,"wifi_play_rate")? ",if(sum(cr.total_play)!=0,sum(cr.wifi_play)/sum(cr.total_play),0) as wifi_play_rate" :""}
-------------
           ${array.contain(dimArray,"event_new_user_pay")? ",sum(event_new_user_pay) as event_new_user_pay" :""} -- 新增付费人数
           ${array.contain(dimArray,"event_new_user_pay_cost")? ",sum(cost/10000) / sum(event_new_user_pay) as event_new_user_pay_cost" :""} -- 新增付费人数成本
           ${array.contain(dimArray,"event_new_user_pay_ratio")? ",sum(event_new_user_pay) / sum(content_click) as event_new_user_pay_ratio" :""} -- 当日行为数
           ${array.contain(dimArray,"event_jin_jian_app")? ",sum(event_jin_jian_app) as event_jin_jian_app" :""} -- 完件数
           ${array.contain(dimArray,"event_jin_jian_app_cost")? ",sum(cost/10000) / sum(event_jin_jian_app) as event_jin_jian_app_cost" :""} -- 完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_app")? ",sum(event_new_user_jinjian_app) as event_new_user_jinjian_app" :""} -- 新增完件人数
           ${array.contain(dimArray,"event_new_user_jinjian_app_cost")? ",sum(cost/10000) / sum(event_new_user_jinjian_app) as event_new_user_jinjian_app_cost" :""} -- 新增完件人数成本
           ${array.contain(dimArray,"event_new_user_jinjian_app_roi")? ",sum(event_new_user_jinjian_app) / (sum(convert_count) + sum(form_count)) as event_new_user_jinjian_app_roi" :""} -- 新增完件人数率
           ${array.contain(dimArray,"event_credit_grant_app")? ",sum(event_credit_grant_app) as event_credit_grant_app" :""} -- 当日回传授信数
           ${array.contain(dimArray,"event_credit_grant_app_cost")? ",sum(cost/10000) / sum(event_credit_grant_app) as event_credit_grant_app_cost" :""} -- 授信成本
           ${array.contain(dimArray,"event_credit_grant_app_ratio")? ",sum(event_credit_grant_app)/sum(event_jin_jian_app) as event_credit_grant_app_ratio" :""} -- 授信率
           ${array.contain(dimArray,"event_new_user_credit_grant_app")? ",sum(event_new_user_credit_grant_app) as event_new_user_credit_grant_app" :""} -- 新增授信人数
           ${array.contain(dimArray,"event_new_user_credit_grant_app_cost")? ",sum(cost/10000) / sum(event_new_user_credit_grant_app) as event_new_user_credit_grant_app_cost" :""} -- 新增授信人数成本
           ${array.contain(dimArray,"event_new_user_credit_grant_app_roi")? ",sum(event_new_user_credit_grant_app) / (sum(convert_count) + sum(form_count)) as event_new_user_credit_grant_app_roi" :""} -- 新增授信人数率
           ${array.contain(dimArray,"event_order_paid")? ",sum(event_order_paid) as event_order_paid" :""} -- 订单支付数
           ${array.contain(dimArray,"event_order_paid_roi")? ",sum(event_order_paid) / sum(event_goods_view) as event_order_paid_roi" :""} -- 订单支付率
           ${array.contain(dimArray,"event_order_paid_cost")? ",sum(cost/10000) / sum(event_order_paid) as event_order_paid_cost" :""} -- 订单支付成本
           ${array.contain(dimArray,"event_valid_clues")? ",sum(event_valid_clues) as event_valid_clues" :""}  -- 有效线索数
           ${array.contain(dimArray,"event_valid_clues_cost")? ",sum(cost/10000) / sum(event_valid_clues) as event_valid_clues_cost" :""} -- 有效线索成本
           ${array.contain(dimArray,"merchant_reco_fans")? ",sum(merchant_reco_fans) as merchant_reco_fans" :""}  -- 涨粉量
           ${array.contain(dimArray,"merchant_reco_fans_cost")? ",sum(cost/10000) / sum(merchant_reco_fans) as merchant_reco_fans_cost" :""} -- 涨粉成本
           ${array.contain(dimArray,"event_goods_view")? ",sum(event_goods_view) as event_goods_view" :""} -- 商品访问数
           ${array.contain(dimArray,"event_goods_view_cost")? ",sum(cost/10000) / sum(event_goods_view) as event_goods_view_cost" :""} -- 商品访问成本
           ${array.contain(dimArray,"event_jin_jian_landing_page")? ",sum(event_jin_jian_landing_page) as event_jin_jian_landing_page" :""} -- 落地页完件数
           ${array.contain(dimArray,"event_jin_jian_landing_page_cost")? ",sum(cost/10000) / sum(event_jin_jian_landing_page) as event_jin_jian_landing_page_cost" :""} -- 落地页完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_page")? ",sum(event_new_user_jinjian_page) as event_new_user_jinjian_page" :""} -- 落地页新增完件数
           ${array.contain(dimArray,"event_new_user_jinjian_page_cost")? ",sum(cost/10000) / sum(event_new_user_jinjian_page) as event_new_user_jinjian_page_cost" :""} -- 落地页新增完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_page_roi")? ",sum(event_new_user_jinjian_page) / (sum(convert_count) + sum(form_count)) as event_new_user_jinjian_page_roi" :""} -- 落地页新增完件率
           ${array.contain(dimArray,"event_credit_grant_landing_page")? ",sum(event_credit_grant_landing_page) as event_credit_grant_landing_page" :""} -- 落地页授信数
           ${array.contain(dimArray,"event_credit_grant_landing_page_cost")? ",sum(cost/10000) / sum(event_credit_grant_landing_page) as event_credit_grant_landing_page_cost" :""} -- 落地页授信成本
           ${array.contain(dimArray,"event_credit_grant_landing_page_ratio")? ",sum(event_credit_grant_landing_page) / sum(event_jin_jian_landing_page) as event_credit_grant_landing_page_ratio" :""} -- 落地页授信率
           ${array.contain(dimArray,"event_new_user_credit_grant_page")? ",sum(event_new_user_credit_grant_page) as event_new_user_credit_grant_page" :""} -- 落地页新增授信数
           ${array.contain(dimArray,"event_new_user_credit_grant_page_cost")? ",sum(cost/10000) / sum(event_new_user_credit_grant_page) as event_new_user_credit_grant_page_cost" :""} -- 落地页新增授信成本
           ${array.contain(dimArray,"event_new_user_credit_grant_page_roi")? ",sum(event_new_user_credit_grant_page) / (sum(convert_count) + sum(form_count)) as event_new_user_credit_grant_page_roi" :""} -- 落地页新增授信率
           ${array.contain(dimArray,"event_button_click")? ",sum(event_button_click) as event_button_click" :""} -- 按钮点击数
           ${array.contain(dimArray,"event_button_click_rate")? ",sum(event_button_click) / sum(content_click) as event_button_click_rate" :""} -- 按钮点击率
           ${array.contain(dimArray,"event_button_click_cost")? ",sum(cost/10000) / sum(event_button_click) as event_button_click_cost" :""} -- 按钮点击成本
           ${array.contain(dimArray,"event_get_through")? ",sum(event_get_through) as event_get_through" :""} -- 智能电话-确认接通数
           ${array.contain(dimArray,"event_get_through_cost")? ",sum(cost/10000) / sum(event_get_through) as event_get_through_cost" :""} -- 智能电话-确认接通成本
           ${array.contain(dimArray,"event_get_through_ratio")? ",sum(event_get_through) / sum(content_click) as event_get_through_ratio" :""} -- 智能电话-确认接通率
           ${array.contain(dimArray,"share_count")? ",sum(share_count) as share_count" :""} -- 分享数
           ${array.contain(dimArray,"comment_count")? ",sum(comment_count) as comment_count" :""} -- 评论数
           ${array.contain(dimArray,"like_count")? ",sum(like_count) as like_count" :""} -- 点赞数
           ${array.contain(dimArray,"add_follower_count")? "sum(add_follower_count) as add_follower_count" :""} -- 新增关注数
           ${array.contain(dimArray,"complain_count")? "sum(complain_count) as complain_count" :""}  -- 举报数
           ${array.contain(dimArray,"hate_count")? "sum(hate_count) as hate_count" :""}  -- 拉黑数
           ${array.contain(dimArray,"negative_count")? "sum(negative_count) as negative_count" :""} -- 减少此类作品数
           ${array.contain(dimArray,"cancel_follow")? ",sum(cancel_follow) as cancel_follow" :""} -- 取消关注数
           ${array.contain(dimArray,"ad_product_cnt")? ",sum(ad_product_cnt) as ad_product_cnt" :""}  -- 商品成交数
           ${array.contain(dimArray,"event_add_wechat")? ",sum(event_add_wechat) as event_add_wechat" :""}
           ${array.contain(dimArray,"event_add_wechat_cost")? ",sum(cost/10000) /sum(ad_product_cnt) as event_add_wechat_cost" :""}
           ${array.contain(dimArray,"event_add_wechat_ratio")? ",sum(event_add_wechat) / sum(content_click) as event_add_wechat_ratio" :""}
           ${array.contain(dimArray,"app_event_next_day_stay")? ",sum(app_event_next_day_stay) as app_event_next_day_stay" :""}
           ${array.contain(dimArray,"app_event_next_day_stay_cost")? ",sum(cost/10000) / sum(app_event_next_day_stay) as app_event_next_day_stay_cost" :""}
           , sum(cr.cost)/10000 as cost1
           , sum(play_3s_count) as play_3s_count1
           , sum(play_5s_count) as play_5s_count1
           , sum(play_end_count) as play_end_count1
           , sum(content_impression) as content_impression1
           , sum(content_click) as content_click1
           , sum(cr.convert_count) as convert_count1
           , sum(deep_convert_count) as deep_convert_count1
           , sum(click) as click1
           , sum(impression) as impression1
           , sum(app_event_next_day_stay) as app_event_next_day_stay1
           , sum(app_activation) as app_activation1
           , sum(next_day_active_count) as next_day_active_count1
           , sum(app_register) as app_register1
           , sum(event_pay_purchase_amount_first_day) as event_pay_purchase_amount_first_day1
           , sum(event_pay) as event_pay1
           , sum(cr.form_count) as form_count1
           , sum(cr.wifi_play) as wifi_play1
           , sum(cr.total_play) as total_play1
           , sum(cr.valid_play) as valid_play1
           , sum(cr.play_duration_sum) as play_duration_sum1
           , sum(play_25_feed_break) as play_25_feed_break1
           , sum(play_50_feed_break) as play_50_feed_break1
           , sum(play_75_feed_break) as play_75_feed_break1
           , sum(play_100_feed_break) as play_100_feed_break1
from makepolo.vendor_creative_report cr
	left join makepolo.creative_report_dims dims on dims.vendor_account_id = cr.vendor_account_id
					and dims.vendor_creative_id = cr.vendor_creative_id
    left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
    ${array.contain(dimArray,"project_id") || isNotEmpty(project_id)? "left join makepolo.project pro on pro.id=dims.project_id" :""} 
    ${array.contain(dimArray,"project_id") || isNotEmpty(project_id)? "left join (select max(project_id) as project_id, vendor_account_id, count(*) from makepolo.vendor_account_project where " + where_pj +" group by 2 having count(*)=1 ) p on eva.id= p.vendor_account_id" :""} 
    ${array.contain(dimArray,"project_id") || isNotEmpty(project_id)? "left join makepolo.project pj on pj.id = p.project_id" :""} 
    ${array.contain(dimArray,"params_account_id")? "left join makepolo_common.account_user au on au.id=eva.subordinate_account_id" :""}
    ${array.contain(dimArray,"vendor_id")? "left join makepolo_common.vendor ev on ev.vendor_id=cr.vendor_id" :""}
where cr.date>='${start_date}' and cr.date<='${end_date}' and cr.vendor_creative_id <>'0' ${where}
group by ${group_str} ${!isEmpty(__sort!) ? __sort:"order by "+order_str}




