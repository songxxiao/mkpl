-- {{start_date}}
-- {{end_date}}
-- {{vendor_account_id}}
-- {{params_account_id}}
-- {{company_id}}
-- {{project_id}}
-- {{vendor_id}}
-- {{display_dim}}



<%
where = "";
if(isNotEmpty(vendor_account_id)){
    where = where + " and a.vendor_account_id in ("+vendor_account_id+") or eva.id in ("+vendor_account_id+"))";
} else {
    where = where + " and a.vendor_account_id = -1";
}

if(isNotEmpty(company_id)){
    where =  where + " and a.company_id in ("+company_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and eva.subordinate_account_id in ("+params_account_id+")";
}

if(isNotEmpty(project_id)){
    where =  where + " and a.project_id  in ("+project_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and a.vendor_id in ("+vendor_id+")";
}


where_cr = "";
if(isNotEmpty(vendor_account_id)){
    where_cr = where_cr + " and cr.vendor_account_id in ("+vendor_account_id+")";
} 

if(isNotEmpty(company_id)){
    where_cr =  where_cr + " and (eva.company_id in ("+company_id+") or dims.company_id in ("+company_id+"))";
}

if(isNotEmpty(project_id)){
    where_cr =  where_cr + " and dims.project_id  in ("+project_id+")";
}

if(isNotEmpty(vendor_id)){
    where_cr = where_cr + " and cr.vendor_id in ("+vendor_id+")";
}

if(isNotEmpty(params_account_id)){
    where_cr =  where_cr + " and (eva.subordinate_account_id in ("+params_account_id+") or dims.creative_account_id in (" +params_account_id+"))";
}


%>

select au.name as '优化师名称'
    ${strutil.contain(display_dim!'1', '1')? ", ifnull(increase_ad, 0)       as value_count":" "} 
    ${strutil.contain(display_dim!'1', '2')? ", ifnull(increase_creative, 0) as value_count":" "}  
    ${strutil.contain(display_dim!'1', '3')? ", cost                         as value_count":" "}  
from (
    select eva.subordinate_account_id account_id
         , sum(cost) / 10000 cost
         , 0 increase_creative
         , 0 increase_ad
    from makepolo.vendor_creative_report cr
             left join makepolo.creative_report_dims dims on dims.vendor_account_id = cr.vendor_account_id
        				and dims.vendor_creative_id = cr.vendor_creative_id
             left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
    ${isNotEmpty(project_id)? "left join makepolo.project pro on pro.id = dims.project_id" :""} 
    ${isNotEmpty(project_id)? "left join (select max(project_id) as project_id, vendor_account_id, count(*) from makepolo.vendor_account_project where " + where_pj +" group by 2 having count(*)=1 ) p on eva.id= p.vendor_account_id" :""} 
    ${isNotEmpty(project_id)? "left join makepolo.project pj on pj.id = p.project_id" :""} 
    where cr.date >= '${start_date}'
      and cr.date <= '${end_date}' 
      ${where_cr}
    group by 1
    
    union all

    select eva.subordinate_account_id account_id
        , 0 cost
        , count(1) as increase_creative
        , 0 increase_ad
    from makepolo.ad_creative a
    left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
    where create_time >= '${start_date} 00:00:00'
      and create_time <= '${end_date} 23:59:59'  ${where}
    group by 1 

    union all

    select eva.subordinate_account_id account_id
        , 0 cost
        , 0 as increase_creative
        , count(1) as increase_ad
    from makepolo.ad_unit a
    left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
    where create_time >= '${start_date} 00:00:00'
      and create_time <= '${end_date} 23:59:59'  ${where}
    group by 1 

) cr left join makepolo_common.account_user au on au.id = cr.account_id
group by 1
order by 2 desc
limit 5













