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
}


if(isNotEmpty(designer_account_id)){
    where =  where + " and account_id in ("+designer_account_id+")";
}


where_dim = "";

if(current_role == '2' && isNotEmpty(account_id)){
    where_dim =  where_dim + " and video_account_id in ("+account_id+")";
} 

if(isNotEmpty(designer_account_id)){
    where_dim =  where_dim + " and video_account_id in ("+designer_account_id+")";
}

if(isNotEmpty(company_id)){
    where_dim =  where_dim + " and company_id in ("+company_id+")";
}

where_cr = "";
if(isNotEmpty(vendor_id)){
    where_cr =  where_cr + " and vendor_id  in ("+vendor_id+")";
}

where_end = "";
if(isNotEmpty(account_id)){
    where_end =  where_end + "where m_dims.video_account_id in ("+account_id+")";
}

where_all = "";
if(isNotEmpty(project_id)){
    where_all = where_all + "join (select * from makepolo.creative_report_dims where project_id in ( " + project_id + ")) dims on dims.vendor_account_id = cr.vendor_account_id and dims.vendor_creative_id = cr.vendor_creative_id";
}

%>

-- SET session exec_mem_limit = 10G;
select 
	${isNotEmpty(is_dat) && is_dat == '0'  ? "dat as date," : ""}  -- '日期'
	name as designer_name, -- '设计师名称'
	cnt as cnt_video, --  '上传视频数'
	impression_video as impression_video, --  '曝光素材数'
	cost / 10000 as cost, -- '消耗金额'
    cost_rebate / 10000 as cost_rebate,  -- '返点后消耗'
	impression as impression, -- '封面展示数'
	click as click,           --  '封面点击数'
    if(impression=0, 0,  (cost / 10000) / (impression / 1000))  as cost_impression,  -- '平均千次曝光费用' 
    if(click=0, 0, (cost / 10000) / click)  as click_cost,     -- '平均点击单价'
    if(content_impression=0, 0, play_3s_count / content_impression) as play_3s_rate,   -- '3秒播放率'
    if(content_impression=0, 0, play_end_count / content_impression) as play_end_rate,  --  '完播率'
    play_3s_count as play_3s_count1, 
    play_end_count as play_end_count1,
    content_impression as content_impression1
from  (
select 
	    ${isNotEmpty(is_dat) && is_dat == '0'  ? "cr.date as dat," : ""} 
		m_dims.video_account_id as account_id,
  		au.name,
  		sum(ifnull(cc.cnt,0)) as cnt,
		sum(cost) as cost,
  		sum(cost/ (1+ (eva.return_point / 100))) as cost_rebate,
		sum(impression) as impression,
 		sum(content_impression) as content_impression,
		sum(click) as click,
		sum(app_activation) as app_activation,
		sum(cr.app_event_pay_amount)  as app_event_pay_amount,
  	    sum(play_3s_count) as play_3s_count,
  		sum(play_end_count) as play_end_count,
		sum(cr.form_count) as form_count,
  		count(distinct if(impression>0, m_dims.local_video_id, null)) as impression_video
	from (select * from makepolo.vendor_creative_report 
          					where date>='${start_date}' 
          						and date<='${end_date}' 
          						and vendor_creative_id <> '0'
          ${where_cr} ) cr 
 	     ${where_all}
  	 left join (select * from makepolo.creative_material_dims 
                               where video_account_id <> '0' and company_id in (${company_id})
                           				and video_account_id is not null ${where_dim}) m_dims 
                       on m_dims.vendor_material_id = cr.photo_id
                       and m_dims.vendor_account_id = cr.vendor_account_id 
    left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
                 -- left join makepolo.local_material_video lmv on lmv.id = m_dims.local_video_id

    left join (
            select ${isNotEmpty(is_dat) && is_dat == '0'  ? "date(create_time) as date," : ""} 
  			        account_id
 		            ,count(1) as cnt
                from makepolo.local_material_video
            where create_time>='${start_date} 00:00:00' 
                and create_time<='${end_date} 23:59:59' ${where}
            group by 1 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 2" : ""} 
) cc on ${isNotEmpty(is_dat) && is_dat == '0'  ? " cc.date=cr.date and" : ""} cc.account_id=m_dims.video_account_id
    left join makepolo.account_user au on m_dims.video_account_id = au.id
  ${where_end}
        group by 1,2 ${isNotEmpty(is_dat) && is_dat == '0'  ? ", 3" : ""} 
) cq
where name <> '' 
order by 1 desc

