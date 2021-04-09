-- {{start_date}}
-- {{end_date}}
-- {{vendor_id}}
-- {{project_id}}
-- {{params_vendor_account_id}}
-- {{vendor_account_id}}
-- {{jump_account_id}}
-- {{company_id}}

<%

where ="";
if(isNotEmpty(vendor_account_id)){
    where = where + " and vendor_account_id in ("+vendor_account_id+")";
} else{
    where = where + " and vendor_account_id =-1";
}

if(isNotEmpty(company_id)){
    where =  where + " and company_id in ("+company_id+")";
}


queryInfo = "start_date="+start_date+"&end_date="+end_date;

if(isNotEmpty(jump_account_id)){
    where = where + " and account_id="+jump_account_id;
}

if(isNotEmpty(vendor_id)){
    where =  where + " and vendor_id in ("+vendor_id+")";
    queryInfo = queryInfo + "&vendor_id="+vendor_id;
}
if(isNotEmpty(params_vendor_account_id)){
    where =  where + " and vendor_account_id in ("+params_vendor_account_id+")";
    queryInfo = queryInfo + "&params_vendor_account_id="+params_vendor_account_id;
}
if(isNotEmpty(project_id)){
    where =  where + " and project_id in ("+project_id+")";
    queryInfo = queryInfo + "&project_id="+project_id;
}


where_cr =  "";
if(isNotEmpty(vendor_account_id)){
    where_cr = where_cr + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else{
    where_cr = where_cr + " and cr.vendor_account_id =-1";
}

if(isNotEmpty(company_id)){
    where_cr =  where_cr + " and eva.company_id in ("+company_id+")";
}


if(isNotEmpty(jump_account_id)){
    where_cr = where_cr + " and eva.subordinate_account_id="+jump_account_id;
}
if(isNotEmpty(vendor_id)){
    where_cr =  where_cr + " and cr.vendor_id in ("+vendor_id+")";
}
if(isNotEmpty(params_vendor_account_id)){
    where_cr =  where_cr + " and cr.vendor_account_id in ("+params_vendor_account_id+")";
}
if(isNotEmpty(project_id)){
    where_cr =  where_cr + " and dims.project_id in ("+project_id+")";
}

var dims = strutil.split(isEmpty(dim)?'':dim,",");

%>

select 
${array.contain(dims,"vendor_account")?"eva.vendor_account_name,":"au.name as optimizer_name,"} 
ifnull(ca.increase_ad,0) as increase_ad,
ifnull(cr.cnt_ad, 0) as impression_ad,
cr.creative_account_id as account_id,
'${queryInfo}' as query_info
    , sum(cost) cost
    , sum(cost_rebate) cost_rebate 
    , sum(impression) impression
    , sum(click) click
    , sum(content_impression) content_impression
    , sum(content_click) content_click 
    , sum(click_rate) click_rate
    , sum(content_click_rate) content_click_rate 
    , sum(impression_cost) impression_cost
    , sum(click_cost) click_cost
    , sum(content_click_cost) content_click_cost 
    , sum(app_download_start) app_download_start
    , sum(app_download_complete) app_download_complete
    , sum(app_activation) app_activation
    , sum(app_activation_cost) app_activation_cost
    , sum(app_activation_rate) app_activation_rate
    , sum(app_register) app_register
    , sum(app_register_cost) app_register_cost 
    , sum(app_register_rate) app_register_rate 
    , sum(app_event_pay_amount) app_event_pay_amount
    , sum(app_event_next_day_stay_rate) app_event_next_day_stay_rate
    , sum(play_3s_rate) play_3s_rate
    , sum(event_pay_first_day) event_pay_first_day
    , sum(event_pay_purchase_amount_first_day) event_pay_purchase_amount_first_day
    , sum(first_day_roi) first_day_roi
    , sum(event_pay) event_pay
    , sum(event_pay_cost) event_pay_cost
    , sum(form_count) form_count
    , sum(form_count_click_rate) form_count_click_rate
    , sum(form_count_unit_price) form_count_unit_price
from 
(
    select 
       eva.subordinate_account_id as creative_account_id
       , sum(cr.cost)/10000 as cost
       , sum(cost / (1+ (return_point / 100 ))) / 10000 as cost_rebate
       , sum(cr.impression) as impression
       , sum(cr.click) as click
       , sum(cr.content_impression) as content_impression
       , sum(cr.content_click) as content_click
       , if(sum(impression)!=0,sum(click)/sum(impression),0) as click_rate
       , if(sum(content_impression)!=0,sum(content_click)/sum(content_impression),0) as content_click_rate
       , if(sum(impression)!=0,sum(cost)/sum(impression)*1000/10000,0) as impression_cost
       , if(sum(click)!=0,sum(cost)/sum(click)/10000,0) as click_cost
       , if(sum(content_click)!=0,sum(cost)/sum(content_click)/10000,0) as content_click_cost
       , sum(cr.app_download_start) as app_download_start
       , sum(cr.app_download_complete) as app_download_complete
       , sum(cr.app_activation) as app_activation
       , if(sum(app_activation)!=0,sum(cost)/sum(app_activation)/10000,0) as app_activation_cost
       , if(sum(app_download_complete)!=0,sum(app_activation)/sum(click),0) as app_activation_rate
       , sum(cr.app_register) as app_register
       , if(sum(app_register)!=0,sum(cost)/sum(app_register)/10000,0) as app_register_cost
       , if(sum(app_activation)!=0,sum(app_register)/sum(app_activation),0) as app_register_rate
       , sum(cr.app_event_pay_amount)/100 as app_event_pay_amount
       , if(sum(app_activation)!=0,sum(app_event_next_day_stay)/sum(app_activation),0) as app_event_next_day_stay_rate
       , if(sum(content_impression)!=0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate
       , sum(cr.event_pay_first_day) as event_pay_first_day
       , sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day
       , if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi
       , sum(cr.event_pay) as event_pay
       , if(sum(cr.event_pay)!=0,sum(cr.cost)/sum(cr.event_pay)/10000,0) as event_pay_cost
       , sum(cr.form_count) as form_count
       , if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate
       , if(sum(cr.form_count)!=0,sum(cr.cost)/sum(cr.form_count)/10000,0) as form_count_unit_price
       , sum(cr.convert_count) as convert_count
       , if(sum(cr.click)!=0,sum(cr.convert_count)/sum(cr.click),0) as convert_rate
       , if(sum(cr.convert_count)!=0,sum(cr.cost)/sum(cr.convert_count)/10000,0) as convert_cost
       , count(distinct if(impression>0, ad_unit_id, null)) as cnt_ad
       , 0 as increase_ad
    from makepolo.vendor_creative_report cr
    left join makepolo.creative_report_dims dims 
    	on dims.vendor_account_id = cr.vendor_account_id
		and dims.vendor_creative_id = cr.vendor_creative_id ${isNotEmpty(company_id) ? " and dims.company_id in (" + company_id + ")" : ""}
    left join makepolo.entity_vendor_account eva on cr.vendor_account_id=eva.id
    where cr.date>='${start_date}' and cr.date<='${end_date}' ${where_cr}
    group by ${array.contain(dims,"vendor_account")?"eva.subordinate_account_id,cr.vendor_account_id":"eva.subordinate_account_id"}
    
    union all

    select ${array.contain(dims,"vendor_account")?"account_id,vendor_account_id":"account_id"} 
        , 0 as cost
        , 0 as cost_rebate
        , 0 as impression
        , 0 as click
        , 0 as content_impression
        , 0 as content_click
        , 0 as click_rate
        , 0 as content_click_rate
        , 0 as impression_cost
        , 0 as click_cost
        , 0 as content_click_cost
        , 0 as app_download_start
        , 0 as app_download_complete
        , 0 as app_activation
        , 0 as app_activation_cost
        , 0 as app_activation_rate
        , 0 as app_register
        , 0 as app_register_cost
        , 0 as app_register_rate
        , 0 as app_event_pay_amount
        , 0 as app_event_next_day_stay_rate
        , 0 as play_3s_rate
        , 0 as event_pay_first_day
        , 0 as event_pay_purchase_amount_first_day
        , 0 as first_day_roi
        , 0 as event_pay
        , 0 as event_pay_cost
        , 0 as form_count
        , 0 as form_count_click_rate
        , 0 as form_count_unit_price
        , 0 as convert_count
        , 0 as convert_rate
        , 0 as convert_cost
        , 0 as cnt_ad
        , count(1) as increase_ad
    from ad_unit 
    where create_time>='${start_date}' and create_time<='${end_date} 23:59:59' ${where}
    group by ${array.contain(dims,"vendor_account")?"account_id,vendor_account_id":"account_id"} 
) ca on  ${array.contain(dims,"vendor_account")?"ca.account_id=cr.creative_account_id and ca.vendor_account_id=cr.vendor_account_id":"ca.account_id=cr.creative_account_id"} 
left join makepolo_common.account_user au on cr.creative_account_id = au.id
${array.contain(dims,"vendor_account")?"left join entity_vendor_account eva on eva.id=cr.vendor_account_id":""} 

${__sort!}