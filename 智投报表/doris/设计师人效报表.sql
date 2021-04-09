-- {{start_date}}
-- {{end_date}}
-- {{current_role}}
-- {{project_id}}
-- {{vendor_id}}
-- {{account_id}}
-- {{vendor_account_id}}
-- {{designer_account_id}}
-- {{company_id}}
-- {{is_dat}}

<%
where = "";

if(isNotEmpty(company_id)){
    where =  where + " and company_id in ("+company_id+")";
} else {
   where = where + " and company_id = -1";
}


if(isNotEmpty(designer_account_id)){
    where =  where + " and account_id in ("+designer_account_id+")";
}

if(isNotEmpty(account_id)){
    where =  where + " and account_id in ("+account_id+")";
}


where_dim = "";

if(current_role == '2' && isNotEmpty(account_id)){
    where_dim =  where_dim + " and m_dims.video_account_id in ("+account_id+")";
} 

if(isNotEmpty(designer_account_id)){
    where_dim =  where_dim + " and m_dims.video_account_id in ("+designer_account_id+")";
}

if(isNotEmpty(vendor_id)){
    where_dim =  where_dim + " and cr.vendor_id in ("+vendor_id+")";
}

where_all = "";
if(isNotEmpty(project_id)){
    where_all = where_all + "join makepolo.creative_report_dims dims on dims.vendor_account_id = cr.vendor_account_id and dims.vendor_creative_id = cr.vendor_creative_id and dims.company_id in (" + company_id + ") and project_id in ( " + project_id + ")";
}

%>

-- SET session exec_mem_limit = 10G;
select 
	${isNotEmpty(is_dat) && is_dat == '0'  ? "dat as date," : ""}
	if(name is null, '未知',name) as designer_name
   , cnt as cnt_video
   , impression_video as impression_video
   , cost / 10000 as cost
   , cost_rebate / 10000 as cost_rebate
   , impression as impression
   , click as click
   , if(impression=0, 0,  (cost / 10000) / (impression / 1000))  as cost_impression
   , if(click=0, 0, (cost / 10000) / click)  as click_cost
   , if(content_impression=0, 0, play_3s_count / content_impression) as play_3s_rate
   , ifnull(play_end_count / content_impression, 0) as play_end_rate
   , play_3s_count as play_3s_count1
   , play_end_count as play_end_count1
   , content_impression as content_impression1
from  (

    select  ${isNotEmpty(is_dat) && is_dat == '0'  ? "dat," : ""} 
        account_id
		, sum(cost) as cost
  		, sum(cost_rebate) as cost_rebate
		, sum(impression) as impression
 		, sum(if(vendor_id=1, content_impression, total_play)) as content_impression
        , sum(total_play) as total_play
		, sum(click) as click
		, sum(app_activation) as app_activation
		, sum(app_event_pay_amount)  as app_event_pay_amount
  	    , sum(play_3s_count) as play_3s_count
  		, sum(if(vendor_id=1, play_end_count, play_end_count / 100)) as play_end_count
		, sum(form_count) as form_count
  		, sum(impression_video) as impression_video
        , sum(cnt) as cnt
    from (
        select ${isNotEmpty(is_dat) && is_dat == '0'  ? "cr.date as dat," : ""} 
		    m_dims.video_account_id as account_id
           , cr.vendor_id as vendor_id 
		   , sum(cost) as cost
  		   , sum(cost/ (1+ (eva.return_point / 100))) as cost_rebate
		   , sum(impression) as impression
 		   , sum(content_impression) as content_impression
           , sum(total_play) as total_play
		   , sum(click) as click
		   , sum(app_activation) as app_activation
		   , sum(cr.app_event_pay_amount)  as app_event_pay_amount
  	       , sum(play_3s_count) as play_3s_count
  		   , sum(play_end_count) as play_end_count
		   , sum(cr.form_count) as form_count
  		   , count(distinct if(impression>0, m_dims.local_video_id, null)) as impression_video
           , 0 as cnt
	    from makepolo.vendor_creative_report  cr 
  	 		left join makepolo.creative_material_dims m_dims 
                       on m_dims.vendor_material_id = cr.photo_id
                       and m_dims.vendor_account_id = cr.vendor_account_id 
  					   and video_account_id <> '0' and video_account_id is not null  ${isNotEmpty(company_id)? " and m_dims.company_id in (" + company_id + ")" : ""}
  	        ${where_all}
            left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id 
            where cr.date>='${start_date}' and  cr.date<='${end_date}' 
          						and  cr.vendor_creative_id <> '0'
  								${isNotEmpty(company_id)? " and eva.company_id in (" + company_id + ")" : ""}
                                ${where_dim}
  		group by 1,2 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 3" : ""} 

        union all

        select ${isNotEmpty(is_dat) && is_dat == '0'  ? "date(create_time) as dat," : ""} 
  			account_id
            , 0 as vendor_id
            , 0 as cost
            , 0 as cost_rebate
            , 0 as impression
            , 0 as content_impression
            , 0 as total_play
            , 0 as click
            , 0 as app_activation
            , 0 as app_event_pay_amount
            , 0 as play_3s_count
            , 0 as play_end_count
            , 0 as form_count
            , 0 as impression_video
 		    , count(1) as cnt
        from makepolo.local_material_video
        where create_time>='${start_date} 00:00:00' 
            and create_time<='${end_date} 23:59:59' ${where}
        group by 1,2 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 3" : ""}

    ) a group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""}
) b
    left join makepolo_common.account_user au on b.account_id = au.id
    where name <> '' 
order by 1 desc

