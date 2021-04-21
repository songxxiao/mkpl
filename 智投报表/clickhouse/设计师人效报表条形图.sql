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

select au.name as designer_name
	${strutil.contain(display_dim!'1', '1')? ", ifnull(cnt, 0) as value_count":" "}
	${strutil.contain(display_dim!'1', '2')? ", cost as value_count":" "}
from 
(
      select account_id
          , sum(cost) as cost
          , sum(cnt) as cnt 
      from(
	    select m_dims.video_account_id as account_id
		   , sum(cost) / 10000 as cost
           , 0 as cnt
        from makepolo.vendor_creative_report  cr 
      <%if(isNotEmpty(project_id)) {%>
      left join
      (
        select vendor_account_id
            ,  vendor_creative_id
            ,  project_id
        from makepolo.creative_report_dims_local 
        where 1=1 
        ${isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
        ${isNotEmpty(company_id)? "and company_id in (" + company_id + ")" : ""}
        ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
      ) dims 
      on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
      <%}%>
      left join
      (
          select vendor_material_id
              , vendor_account_id
              , local_video_id, video_account_id
          from makepolo.creative_material_dims_local 
          where 1=1 
          ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and vendor_account_id in ("+vendor_account_id+")" : "and vendor_account_id =-1" }
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id 
      left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
      where cr.date < today() - 1  
        and cr.date>='${start_date}' and cr.date<='${end_date}' 
        and cr.vendor_creative_id <> '0'
  	    ${isNotEmpty(company_id)? " and eva.company_id in (" + company_id + ")" : "and eva.company_id = -1"}
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""} 
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      group by account_id
   
        union all

       select m_dims.video_account_id as account_id
		, sum(cost) / 10000 as cost
            , 0 as cnt
        from makepolo.vendor_creative_report  cr 
      <%if(isNotEmpty(project_id)) {%>
      left join
      (
        select vendor_account_id
            ,  vendor_creative_id
            ,  project_id
        from makepolo.creative_report_dims_local 
        where 1=1 
        ${isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
        ${isNotEmpty(company_id)? "and company_id in (" + company_id + ")" : ""}
        ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
      ) dims 
      on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
      <%}%>
      left join
      (
          select vendor_material_id
              , vendor_account_id
              , local_video_id, video_account_id
          from makepolo.creative_material_dims_local 
          where 1=1 
          ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and vendor_account_id in ("+vendor_account_id+")" : "and vendor_account_id =-1" }
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id 
      left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
      where cr.date < today() - 1  
        and cr.date>='${start_date}' and cr.date<='${end_date}' 
        and cr.vendor_creative_id <> '0'
  	    ${isNotEmpty(company_id)? " and eva.company_id in (" + company_id + ")" : "and eva.company_id = -1"}
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""} 
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      group by account_id
   
        union all
    
	select account_id
          , 0 as cost
 	  , count(1) as cnt
	from makepolo.local_material_video
	where create_time>='${start_date} 00:00:00' 
    	and create_time<='${end_date} 23:59:59' 
      ${isNotEmpty(company_id) ? "and company_id in (" + company_id + ")" : ""}    
      ${isNotEmpty(designer_account_id) ? "and account_id in (" + designer_account_id + ")" : ""}
      ${isNotEmpty(account_id) ? "and account_id in (" + account_id + ")" : ""}
      ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
      group by account_id
  ) a group by account_id
) b
left join makepolo_common.account_user au on b.account_id = au.id
where name <> '' 
order by value_count desc
limit 5


