-- {{start_date}}
-- {{end_date}}
-- {{vendor_account_id}}
-- {{project_id}}
-- {{vendor_id}}
-- {{company_id}}
-- {{dim}}

<%

where ="";
if(isNotEmpty(vendor_account_id)){
    where = where + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else{
    where = where + " and cr.vendor_account_id =-1";
}

if(isNotEmpty(company_id)){
    where =  where + " and eva.company_id in ("+company_id+")";
}


if(isNotEmpty(project_id)){
    where =  where + " and dims.project_id  in ("+project_id+")";
}
if(isNotEmpty(vendor_id)){
    where =  where + " and cr.vendor_id in ("+vendor_id+")";
}

var dims = strutil.split(isEmpty(dim)?'':dim,",");

%>

select
${array.contain(dims,"cost")? "sum(cr.cost)/10000 as cost" :""}
${array.contain(dims,"cost_rebate")? ",sum((cr.cost/10000) / (1 + (eva.return_point/100)))  as cost_rebate" :""}
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
from makepolo.vendor_creative_report cr
	left join makepolo.creative_report_dims dims 
    				on dims.vendor_account_id = cr.vendor_account_id
					and dims.vendor_creative_id = cr.vendor_creative_id  ${isNotEmpty(company_id) ? " and dims.company_id in (" + company_id + ")" : ""}
    left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
where cr.date>='${start_date}' and cr.date<='${end_date}' ${where}

${__sort!}
