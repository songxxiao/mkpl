-- {{start_date}}
-- {{end_date}}
-- {{project_id}}
-- {{params_account_id}}
-- {{designer_account_id}}
-- {{vendor_id}}
-- {{vendor_account_id}}
-- {{video_id}}
-- {{current_role}}
-- {{account_id}}
-- {{company_id}}
-- {{create_source}}
-- {{material_market_creator_id}}
-- {{params_vendor_account_id}}
-- {{video_name}}
-- {{director}}
-- {{photographer}}
-- {{editor}}
-- {{category}}

<%
where = "";

if(current_role == '2'){
    where =  where + " and video_account_id in ("+account_id+")";
} else{
    if(isNotEmpty(vendor_account_id)){
        where = where + " and cr.vendor_account_id in ("+vendor_account_id+")";
    } else{
        where = where + " and cr.vendor_account_id = -1";
    }
}

if(isNotEmpty(params_vendor_account_id)){
    where = where + " and dims.vendor_account_id in ("+params_vendor_account_id+")";
}

if(isNotEmpty(company_id)){
    where =  where + " and eva.company_id  in ("+company_id+")";
} else {
   where = where + " and eva.company_id = -1";
}

if(isNotEmpty(project_id)){
    where =  where + " and project_id  in ("+project_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and eva.subordinate_account_id in ("+params_account_id+")";
}

if(isNotEmpty(designer_account_id)){
    where =  where + " and video_account_id in ("+designer_account_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and cr.vendor_id in ("+vendor_id+")";
}

if(!isEmpty(campaign_id)){
    where = where + " and campaign_id in ("+campaign_id+")";
}

if(!isEmpty(ad_unit_id)){
    where = where + " and ad_unit_id in ("+ad_unit_id+")";
}

if(!isEmpty(creative_id)){
    where = where + " and creative_id in ("+creative_id+")";
}

if(!isEmpty(video_id)){
    where = where + " and local_video_id in ("+video_id+")";
}

if(!isEmpty(video_name)){
    where = where + " and video_name like '%"+video_name+"%'";
}

if(!isEmpty(create_source)){
    where = where + " and create_source in ("+create_source+")";
}

if(!isEmpty(material_market_creator_id)){
    where = where + " and material_market_creator_id in ("+material_market_creator_id+")";
}

if(!isEmpty(director)){
    where = where + " and local_material_video_director like '%"+director+"%'";
}

if(!isEmpty(photographer)){
    where = where + " and local_material_video_photographer like '%"+photographer+"%'";
}

if(!isEmpty(editor)){
    where = where + " and local_material_video_editor like '%"+editor+"%'";
}

if(!isEmpty(category)){
    where = where + " and local_material_video_material_category_id in ("+category+")";
}

%>

select 
      if(video_url='' or video_url is null, '未知', video_url) as video_url
    , max(video_name) as video_name
    , max(pro.name) as project 
    , max(vau.name) as  video_designer 
    , max(au.name) as optimizer 
    , max(mcau.name) as  creator_crew  
    , sum(cr.cost) / 10000 as cost 
    , ifnull(sum((cost / 10000) / (1 + (eva.return_point / 100))), 0) / 10000 as cost_rebate
    , sum(cr.impression) as impression 
    , sum(cr.click) as click 
    , if(sum(impression)<>0, sum(cost / 10000) /  sum(impression / 1000) , 0) as impression_cost 
    , if(sum(click)<>0,sum(cost /10000) /sum(click) ,0) as click_cost 
    , if(sum(content_impression)<>0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate 
    , if(sum(content_impression)<>0,sum(play_5s_count)/sum(content_impression),0) as play_5s_rate
    , if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as play_end_rate 
    , if(sum(total_play)<>0,sum(play_25_feed_break)/sum(total_play),0) as play_25_rate 
    , if(sum(total_play)<>0,sum(play_50_feed_break)/sum(total_play),0) as play_50_rate 
    , if(sum(total_play)<>0,sum(play_75_feed_break)/sum(total_play),0) as play_75_rate 
    , if(sum(total_play)<>0,sum(play_100_feed_break)/sum(total_play),0) as play_99_rate 
    , if(sum(impression)<>0,sum(click)/sum(impression),0) as click_rate 
    , sum(cr.content_impression) as content_impression 
    , sum(cr.content_click) as content_click 
    , if(sum(content_impression)!=0,sum(content_click)/sum(content_impression),0) as content_click_rate
    , if(sum(click)<>0,sum(cost)/sum(click)/10000, 0) as click_cost  
    , if(sum(content_click)<>0,sum(cost)/sum(content_click)/10000,0) as content_click_cost 
    , sum(cr.app_download_start) as app_download_start
    , sum(cr.app_download_complete) as app_download_complete 
    , sum(cr.app_activation) as app_activation 
    , if(sum(app_activation)!=0,sum(cost)/sum(app_activation)/10000,0) as app_activation_cost 
    , if(sum(click)!=0,sum(app_activation)/sum(click),0) as app_activation_rate
    , sum(cr.app_register) as app_register 
    , if(sum(app_register)!=0,sum(cost)/sum(app_register)/10000,0) as app_register_cost 
    , if(sum(app_activation)!=0,sum(app_register)/sum(app_activation),0) as app_register_rate
    , sum(cr.app_event_pay_amount/10000) as app_event_pay_amount 
    , if(sum(next_day_active_count)!=0,sum(app_event_next_day_stay)/sum(next_day_active_count),0) as app_event_next_day_stay_rate 
    , sum(cr.event_pay_first_day) as event_pay_first_day
    , sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day 
    , if(sum(cr.cost)<>0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi 
    , sum(cr.event_pay) as event_pay
    , if(sum(cr.event_pay)!=0,sum(cr.cost /10000)/sum(cr.event_pay),0) as event_pay_cost
    , sum(cr.form_count) as form_count
    , if(sum(cr.form_count)!=0,sum(cr.cost)/sum(cr.form_count)/10000,0) as form_count_unit_price
    , if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate
    , sum(share_count) as share_count 
    , sum(comment_count) as comment_count 
    , sum(like_count) as like_count 
    , sum(add_follower_count) as add_follower_count
    , sum(complain_count) as complain_count
    , sum(hate_count) as hate_count
    , sum(negative_count) as negative_count 
    , sum(convert_count) as convert_count
    , if(sum(click)=0, 0, sum(convert_count)/sum(click)) as convert_rate 
    , if(sum(convert_count)=0, 0,sum(cost /10000)/sum(convert_count)) as convert_cost
    , sum(deep_convert_count) as deep_convert_count
    , if(sum(click)=0, 0,sum(deep_convert_count)/sum(click)) as deep_convert_rate 
    , if(sum(deep_convert_count)=0, 0,sum(cost /10000)/sum(deep_convert_count)) as deep_convert_cost 
    , if(sum(total_play)=0, 0,sum(play_duration_sum)/sum(total_play)) as play_duration_per_play
    , if(sum(total_play)=0, 0,sum(wifi_play)/sum(total_play)) as wifi_play_rate
    , sum(total_play) as total_play 
    , sum(valid_play) as valid_play
    , if(sum(total_play)=0, 0,sum(valid_play)/sum(total_play)) as valid_play_rate
    , if(sum(valid_play)=0, 0,sum(cost / 10000)/sum(valid_play)) as valid_play_cost
    , sum(cost) /10000 as cost1
    , sum(impression) as impression1
    , sum(click) as click1
    , sum(content_impression) as content_impression1
    , sum(play_3s_count) as play_3s_count1
    , sum(play_5s_count) as play_5s_count1
    , sum(play_end_count) as play_end_count1
    , sum(app_event_next_day_stay) as app_event_next_day_stay1
    , sum(content_click) as content_click1
    , sum(app_activation) as app_activation1
    , sum(next_day_active_count) as next_day_active_count1
    , sum(app_register) as app_register1
    , sum(app_event_next_day_stay) as app_event_next_day_stay1
    , sum(event_pay_purchase_amount_first_day) as event_pay_purchase_amount_first_day1
    , sum(event_pay) as event_pay1
    , sum(form_count) as form_count1
    , sum(play_25_feed_break) as play_25_feed_break1
    , sum(play_50_feed_break) as play_50_feed_break1
    , sum(play_75_feed_break) as play_75_feed_break1
    , sum(play_100_feed_break) as play_99_feed_break1
    , sum(total_play) as total_play1
    , sum(valid_play) as valid_play1
    , sum(convert_count) as convert_count1
    , sum(deep_convert_count) as deep_convert_count1
    , sum(play_duration_sum) as play_duration_sum1
    , sum(wifi_play) as wifi_play1
from makepolo.vendor_creative_report cr
	left join makepolo.creative_report_dims dims 
            on dims.vendor_account_id = cr.vendor_account_id
		and dims.vendor_creative_id = cr.vendor_creative_id 
      left join makepolo.creative_material_dims m_dims
            on m_dims.vendor_material_id = cr.photo_id
            and m_dims.vendor_account_id = cr.vendor_account_id 
      left join makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
      left join makepolo_common.vendor ev on cr.vendor_id = ev.vendor_id
      left join makepolo_common.account_user au on eva.subordinate_account_id = au.id
      left join makepolo_common.account_user vau on m_dims.video_account_id = vau.id
      left join makepolo_common.account_admin mcau on m_dims.material_market_creator_id = mcau.id
      left join makepolo.project pro on dims.project_id = pro.id
where date >= '${start_date}'
  and date <= '${end_date}'
  and cr.vendor_creative_id <>'0'
    ${where}
group by 1


-- ${isNotEmpty(company_id)? " and m_dims.company_id in (" + company_id + ")" : ""}