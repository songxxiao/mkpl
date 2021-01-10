-- {{start_date}}
-- {{end_date}}
-- {{vendor_id}}
-- {{project_id}}
-- {{params_vendor_account_id}}
-- {{vendor_account_id}}
-- {{jump_account_id}}
-- {{dim}}
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
    where_cr = where_cr + " and cr.vendor_account_id <0";
}

if(isNotEmpty(company_id)){
    where_cr =  where_cr + " and cr.company_id in ("+company_id+")";
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
    where_cr =  where_cr + " and cr.project_id in ("+project_id+")";
}

var dims = strutil.split(isEmpty(dim)?'':dim,",");

%>

select 
${array.contain(dims,"vendor_account")?"eva.vendor_account_name,":"au.name as optimizer_name,"} 
ifnull(ca.increase_ad,0) as increase_ad,
ifnull(cia.cnt_ad, 0) as impression_ad,
cr.creative_account_id as account_id,
'${queryInfo}' as query_info

${array.contain(dims,"cost")? ",cost" :""}
${array.contain(dims,"cost_rebate")? ",cost_rebate" :""}
${array.contain(dims,"impression")? ",impression" :""}
${array.contain(dims,"click")? ",click" :""}
${array.contain(dims,"content_impression")? ",content_impression" :""}
${array.contain(dims,"content_click")? ",content_click" :""}
${array.contain(dims,"click_rate")? ",click_rate" :""}
${array.contain(dims,"content_click_rate")? ",content_click_rate" :""}
${array.contain(dims,"impression_cost")? ",impression_cost" :""}
${array.contain(dims,"click_cost")? ",click_cost" :""}
${array.contain(dims,"content_click_cost")? ",content_click_cost" :""}
${array.contain(dims,"app_download_start")? ",app_download_start" :""}
${array.contain(dims,"app_download_complete")? ",app_download_complete" :""}
${array.contain(dims,"app_activation")? ",app_activation" :""}
${array.contain(dims,"app_activation_cost")? ",app_activation_cost" :""}
${array.contain(dims,"app_activation_rate")? ",app_activation_rate" :""}
${array.contain(dims,"app_register")? ",app_register" :""}
${array.contain(dims,"app_register_cost")? ",app_register_cost" :""}
${array.contain(dims,"app_register_rate")? ",app_register_rate" :""}
${array.contain(dims,"app_event_pay_amount")? ",app_event_pay_amount" :""}
${array.contain(dims,"app_event_next_day_stay_rate")? ",app_event_next_day_stay_rate" :""}
${array.contain(dims,"play_3s_rate")? ",play_3s_rate" :""}
${array.contain(dims,"event_pay_first_day")? ",event_pay_first_day" :""}
${array.contain(dims,"event_pay_purchase_amount_first_day")? ",event_pay_purchase_amount_first_day" :""}
${array.contain(dims,"first_day_roi")? ",first_day_roi" :""}
${array.contain(dims,"event_pay")? ",event_pay" :""}
${array.contain(dims,"event_pay_cost")? ",event_pay_cost" :""}
${array.contain(dims,"form_count")? ",form_count" :""}
${array.contain(dims,"form_count_click_rate")? ",form_count_click_rate" :""}
${array.contain(dims,"form_count_unit_price")? ",form_count_unit_price" :""}
from 
(
select 
${array.contain(dims,"vendor_account")?"eva.subordinate_account_id as creative_account_id ,cr.vendor_account_id":"eva.subordinate_account_id as creative_account_id"} 
${array.contain(dims,"cost")? ",sum(cr.cost)/10000 as cost" :""}
${array.contain(dims,"cost_rebate")? ",sum(cr.cost_rebate)/10000 as cost_rebate" :""}
${array.contain(dims,"impression")? ",sum(cr.impression) as impression" :""}
${array.contain(dims,"click")? ",sum(cr.click) as click" :""}
${array.contain(dims,"content_impression")? ",sum(cr.content_impression) as content_impression" :""}
${array.contain(dims,"content_click")? ",sum(cr.content_click) as content_click" :""}
${array.contain(dims,"click_rate")? ",if(sum(impression)!=0,sum(click)/sum(impression),0) as click_rate" :""}
${array.contain(dims,"content_click_rate")? ",if(sum(content_impression)!=0,sum(content_click)/sum(content_impression),0) as content_click_rate" :""}
${array.contain(dims,"impression_cost")? ",if(sum(impression)!=0,sum(cost)/sum(impression)*1000/10000,0) as impression_cost" :""}
${array.contain(dims,"click_cost")? ",if(sum(click)!=0,sum(cost)/sum(click)/10000,0) as click_cost" :""}
${array.contain(dims,"content_click_cost")? ",if(sum(content_click)!=0,sum(cost)/sum(content_click)/10000,0) as content_click_cost" :""}
${array.contain(dims,"app_download_start")? ",sum(cr.app_download_start) as app_download_start" :""}
${array.contain(dims,"app_download_complete")? ",sum(cr.app_download_complete) as app_download_complete" :""}
${array.contain(dims,"app_activation")? ",sum(cr.app_activation) as app_activation" :""}
${array.contain(dims,"app_activation_cost")? ",if(sum(app_activation)!=0,sum(cost)/sum(app_activation)/10000,0) as app_activation_cost" :""}
${array.contain(dims,"app_activation_rate")? ",if(sum(app_download_complete)!=0,sum(app_activation)/sum(app_download_complete),0) as app_activation_rate" :""}
${array.contain(dims,"app_register")? ",sum(cr.app_register) as app_register" :""}
${array.contain(dims,"app_register_cost")? ",if(sum(app_register)!=0,sum(cost)/sum(app_register)/10000,0) as app_register_cost" :""}
${array.contain(dims,"app_register_rate")? ",if(sum(app_activation)!=0,sum(app_register)/sum(app_activation),0) as app_register_rate" :""}
${array.contain(dims,"app_event_pay_amount")? ",sum(cr.app_event_pay_amount)/100 as app_event_pay_amount" :""}
${array.contain(dims,"app_event_next_day_stay_rate")? ",if(sum(app_activation)!=0,sum(app_event_next_day_stay)/sum(app_activation),0) as app_event_next_day_stay_rate" :""}
${array.contain(dims,"play_3s_rate")? ",if(sum(content_impression)!=0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate" :""}
${array.contain(dims,"event_pay_first_day")? ",sum(cr.event_pay_first_day) as event_pay_first_day" :""}
${array.contain(dims,"event_pay_purchase_amount_first_day")? ",sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day" :""}
${array.contain(dims,"first_day_roi")? ",if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi" :""}
${array.contain(dims,"event_pay")? ",sum(cr.event_pay) as event_pay" :""}
${array.contain(dims,"event_pay_cost")? ",if(sum(cr.event_pay)!=0,sum(cr.cost)/sum(cr.event_pay)/10000,0) as event_pay_cost" :""}
${array.contain(dims,"form_count")? ",sum(cr.form_count) as form_count" :""}
${array.contain(dims,"form_count_click_rate")? ",if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate" :""}
${array.contain(dims,"form_count_unit_price")? ",if(sum(cr.form_count)!=0,sum(cr.cost)/sum(cr.form_count)/10000,0) as form_count_unit_price" :""}
${array.contain(dims,"convert_count")? ",sum(cr.convert_count) as convert_count" :""}
${array.contain(dims,"convert_rate")? ",if(sum(cr.click)!=0,sum(cr.convert_count)/sum(cr.click),0) as convert_rate" :""}
${array.contain(dims,"convert_cost")? ",if(sum(cr.convert_count)!=0,sum(cr.cost)/sum(cr.convert_count)/10000,0) as convert_cost" :""}
from `creative_report` cr 
left join entity_vendor_account eva on cr.vendor_account_id=eva.id
where cr.date>='${start_date}' and cr.date<='${end_date}' ${where_cr}
group by ${array.contain(dims,"vendor_account")?"eva.subordinate_account_id,cr.vendor_account_id":"eva.subordinate_account_id"}
) cr
left join (
select 
    ${array.contain(dims,"vendor_account")?"eva.subordinate_account_id as creative_account_id ,cr.vendor_account_id":"eva.subordinate_account_id as creative_account_id"} 
    ,count(distinct cr.ad_unit_id) as cnt_ad
from `creative_report` cr
left join entity_vendor_account eva on cr.vendor_account_id=eva.id
where date>='${start_date}' and date<='${end_date}' and impression>0 ${where_cr}
group by ${array.contain(dims,"vendor_account")?"eva.subordinate_account_id,cr.vendor_account_id":"eva.subordinate_account_id"}
) cia on ${array.contain(dims,"vendor_account")?"cia.creative_account_id=cr.creative_account_id and cia.vendor_account_id=cr.vendor_account_id":"cia.creative_account_id=cr.creative_account_id"} 
left join (
select 
    ${array.contain(dims,"vendor_account")?"account_id,vendor_account_id":"account_id"} 
    ,count(1) as increase_ad
from ad_unit 
where create_time>='${start_date}' and create_time<='${end_date} 23:59:59' ${where}
group by ${array.contain(dims,"vendor_account")?"account_id,vendor_account_id":"account_id"} 
) ca on  ${array.contain(dims,"vendor_account")?"ca.account_id=cr.creative_account_id and ca.vendor_account_id=cr.vendor_account_id":"ca.account_id=cr.creative_account_id"} 
left join makepolo_common.account_user au on cr.creative_account_id = au.id
${array.contain(dims,"vendor_account")?"left join entity_vendor_account eva on eva.id=cr.vendor_account_id":""} 

${__sort!}

