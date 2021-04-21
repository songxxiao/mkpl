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

select 
        ${isNotEmpty(is_dat) && is_dat == '0'  ? "dat as date, " : ""} 
        if(name is null, '未知',name) as designer_name
        , sum(Cnt) as cnt_video
        , sum(Impression_video) as impression_video
	  , sum(Cost) / 10000 as cost
  	  , sum(Cost_rebate) / 10000 as cost_rebate
	  , sum(Impression) as impression
        , sum(Click) as Click
        , if(sum(Impression)=0, 0,  sum(Cost / 10000) / sum(Impression / 1000))  as cost_impression
        , if(sum(Click)=0, 0, sum(Cost / 10000) / sum(Click))  as click_cost
        , if(sum(Content_impression)=0, 0, sum(Play_3s_count) / sum(Content_impression)) as play_3s_rate
 	  , sum(if(Vendor_id=1, Play_end_count, Play_end_count / 100)) / sum(if(vendor_id=1, Content_impression, Total_play)) as play_end_rate
        , sum(Play_3s_count) as play_3s_count1
        , sum(Play_end_count) as play_end_count1
        , sum(Content_impression) as content_impression1
from (
      select m_dims.video_account_id as account_id
            ${isNotEmpty(is_dat) && is_dat == '0'  ? ", cr.date as dat" : ""}  
            , cr.vendor_id as vendor_id 
            , eva.id as vendor_account_id
		, sum(cost) as Cost
  		, sum(cost/ (1+(eva.return_point / 100))) as Cost_rebate
		, sum(impression) as Impression
 		, sum(content_impression) as Content_impression
            , sum(total_play) as Total_play
		, sum(click) as Click
		, sum(app_activation) as App_activation
		, sum(app_event_pay_amount)  as App_event_pay_amount
  	      , sum(play_3s_count) as Play_3s_count
  		, sum(play_end_count) as Play_end_count
		, sum(form_count) as Form_count
  		, count(distinct if(impression>0, m_dims.local_video_id, null)) as Impression_video
            , 0 as Cnt
	from makepolo.vendor_creative_report cr 
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
          ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
          ${isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id 
      left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id 
      where cr.date < today()-1  
        and cr.date>='${start_date}' and cr.date<='${end_date}' 
        and cr.video_account_id <> '0' and cr.video_account_id is not null and cr.vendor_creative_id <> '0'
        ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
        ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
        ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}  
        ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}    
        ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}

      group by account_id, vendor_id ${isNotEmpty(is_dat) && is_dat == '0'  ? ", dat" : ""} 

      union all

     select m_dims.video_account_id as account_id
            ${isNotEmpty(is_dat) && is_dat == '0'  ? ", cr.date as dat" : ""}  
            , cr.vendor_id as vendor_id 
            , eva.id as vendor_account_id
		, sum(cost) as Cost
  		, sum(cost/ (1+(eva.return_point / 100))) as Cost_rebate
		, sum(impression) as Impression
 		, sum(content_impression) as Content_impression
            , sum(total_play) as Total_play
		, sum(click) as Click
		, sum(app_activation) as App_activation
		, sum(app_event_pay_amount)  as App_event_pay_amount
  	      , sum(play_3s_count) as Play_3s_count
  		, sum(play_end_count) as Play_end_count
		, sum(form_count) as Form_count
  		, count(distinct if(impression>0, m_dims.local_video_id, null)) as Impression_video
            , 0 as Cnt
	from makepolo.vendor_creative_report cr final
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
          ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
          ${isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id and video_account_id <> '0' and video_account_id is not null
      left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id 
      where cr.date >= today()-1  
        and cr.date>='${start_date}' and cr.date<='${end_date}' 
        and cr.video_account_id <> '0' and cr.video_account_id is not null and cr.vendor_creative_id <> '0'
        ${current_role == '2' && isNotEmpty(account_id) ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
        ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
        ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}  
        ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}    
        ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}

      group by account_id, vendor_id ${isNotEmpty(is_dat) && is_dat == '0'  ? ", dat" : ""}

      union all

      select account_id
           ${isNotEmpty(is_dat) && is_dat == '0'  ? ", toDate(create_time) as dat" : ""} 
          , 0 as vendor_id
          , 0 as vendor_account_id
          , 0 as Cost
          , 0 as Cost_rebate
          , 0 as Impression
          , 0 as Content_impression
          , 0 as Total_play
          , 0 as Click
          , 0 as App_activation
          , 0 as App_event_pay_amount
          , 0 as Play_3s_count
          , 0 as Play_end_count
          , 0 as Form_count
          , 0 as Impression_video
          , count(1) as Cnt
      from makepolo.local_material_video
      where create_time>='${start_date} 00:00:00' 
          and create_time<='${end_date} 23:59:59'
      group by account_id, vendor_id ${isNotEmpty(is_dat) && is_dat == '0'  ? ", dat" : ""}

) a left join makepolo_common.account_user au on b.account_id = au.id
where name <> '' 
group by account_id ${isNotEmpty(is_dat) && is_dat == '0'  ? ", date" : ""}
${isNotEmpty(is_dat) && is_dat == '0'  ? "order by date desc" : ""}



