-- {{start_date}}
-- {{end_date}}
-- {{current_role}}
-- {{project_id}}
-- {{vendor_id}}
-- {{account_id}}
-- {{vendor_account_id}}
-- {{designer_account_id}}
-- {{company_id}}
-- {{display_dim}} 

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

select au.name as '设计师名称'
	 ${strutil.contain(display_dim!'1', '1')? ", ifnull(cnt, 0) as value_count":" "}
	 ${strutil.contain(display_dim!'1', '2')? ", cost as value_count":" "}
from 
(
    select account_id
          , sum(cost) as cost
          , sum(cnt) as cnt 
    from(
	    select  m_dims.video_account_id as account_id
		   , sum(cost) / 10000 as cost
           , 0 as cnt
        from makepolo.vendor_creative_report  cr 
  			left join makepolo.creative_material_dims m_dims
  			           on m_dims.vendor_material_id = cr.photo_id
                       and m_dims.vendor_account_id = cr.vendor_account_id 
  	    and video_account_id <> '0' and video_account_id is not null  ${isNotEmpty(company_id)? " and m_dims.company_id in (" + company_id + ")" : ""}
        ${where_all}
        left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id 
         where cr.date>='${start_date}' and cr.date<='${end_date}' 
                and cr.vendor_creative_id <> '0'
  	     ${isNotEmpty(company_id)? " and eva.company_id in (" + company_id + ")" : ""}
          ${where_dim}
        group by 1
   
        union all
    
	    select  account_id
          , 0 as cost
 		  , count(1) as cnt
	    from makepolo.local_material_video
	    where create_time>='${start_date} 00:00:00' 
    	    and create_time<='${end_date} 23:59:59' ${where}
	    group by 1
  ) a group by 1
) b
left join makepolo_common.account_user au on b.account_id = au.id
where name <> '' 
order by 2 desc
limit 5


