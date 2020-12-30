-- {{start_date}}
-- {{end_date}}
-- {{project_id}}
-- {{params_account_id}}
-- {{vendor_id}}
-- {{vendor_account_id}}
-- {{params_vendor_account_id}}
-- {{dim}}
-- {{company_id}}

<%
where ="";
if(isNotEmpty(vendor_account_id)){
    where = where + " and cr.vendor_account_id in ("+vendor_account_id+")";
} else{
    where = where + " and cr.vendor_account_id <0";
}

if(isNotEmpty(company_id)){
    where =  where + " and cr.company_id in ("+company_id+")";
} else {
    where = where + " and cr.company_id <0";
}

if(isNotEmpty(project_id)){
    where =  where + " and cr.project_id  in ("+project_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and cr.creative_account_id in ("+params_account_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and cr.vendor_id in ("+vendor_id+")";
}

if(isNotEmpty(params_vendor_account_id)){
    where = where + " and cr.vendor_account_id in ("+params_vendor_account_id+")";
}


dimMap = {
"date":"cr.date as date",
"hour":"concat(lpad(cr.hour,2,0),':00') as hour",
"project_id":"pro.name as project_id",
"params_account_id":"au.name as params_account_id",
"vendor_id":"ev.name as vendor_id",
"params_vendor_account_id":"concat(eva.vendor_account_name,'(',cr.vendor_account_id,')') as params_vendor_account_id"
};


dimStr = strutil.split("date,hour,project_id,params_account_id,vendor_id,params_vendor_account_id",",");

group_str="";
select_str="";
order_str="";

dimArray = strutil.split(dim, ',');
i=0;
for(dm in dimArray){
    if(array.contain(dimStr,dm)){
        i = i+1;
        if(i == 1){
            group_str = i;
            order_str = i;
            select_str = dimMap[dm];
        } else {
            group_str = group_str + "," + i;
            order_str = order_str + "," + i;
            select_str = select_str + "," + dimMap[dm];
        }
    }
}

%>

select ${select_str}

           ${array.contain(dimArray,"cost")? ",sum(cr.cost)/10000 as cost" :""}
           ${array.contain(dimArray,"cost_rebate")? ",sum(cr.cost_rebate)/10000 as cost_rebate" :""}
           ${array.contain(dimArray,"impression")? ",sum(cr.impression) as impression" :""}
           ${array.contain(dimArray,"click")? ",sum(cr.click) as click" :""}
           ${array.contain(dimArray,"click_rate")? ",if(sum(impression)!=0,sum(click)/sum(impression),0) as click_rate" :""}
           ${array.contain(dimArray,"content_impression")? ",sum(cr.content_impression) as content_impression" :""}
           ${array.contain(dimArray,"content_click")? ",sum(cr.content_click) as content_click" :""}
           ${array.contain(dimArray,"content_click_rate")? ",if(sum(content_impression)!=0,sum(content_click)/sum(content_impression),0) as content_click_rate" :""}
           ${array.contain(dimArray,"impression_cost")? ",if(sum(impression)!=0,sum(cost)/sum(impression)*1000/10000,0) as impression_cost" :""}
           ${array.contain(dimArray,"click_cost")? ",if(sum(click)!=0,sum(cost)/sum(click)/10000,0) as click_cost" :""}
           ${array.contain(dimArray,"content_click_cost")? ",if(sum(content_click)!=0,sum(cost)/sum(content_click)/10000,0) as content_click_cost" :""}

           ${array.contain(dimArray,"play_3s_rate")? ",if(sum(content_impression)!=0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate" :""}
           ${array.contain(dimArray,"play_5s_rate")? ",if(sum(content_impression)!=0,sum(play_5s_count)/sum(content_impression),0) as play_5s_rate" :""}
           ${array.contain(dimArray,"play_end_rate")? ",if(sum(content_impression)!=0,sum(play_end_count)/sum(content_impression),0) as play_end_rate" :""}

           ${array.contain(dimArray,"convert_count")? ",sum(cr.convert_count) as convert_count" :""}
           ${array.contain(dimArray,"convert_rate")? ",if(sum(cr.click)!=0,sum(cr.convert_count)/sum(cr.click),0) as convert_rate" :""}
           ${array.contain(dimArray,"convert_cost")? ",if(sum(cr.convert_count)!=0,sum(cr.cost)/sum(cr.convert_count)/10000,0) as convert_cost" :""}

           ${array.contain(dimArray,"deep_convert_count")? ",sum(cr.deep_convert_count) as deep_convert_count" :""}
           ${array.contain(dimArray,"deep_convert_rate")? ",if(sum(cr.click)!=0,sum(cr.deep_convert_count)/sum(cr.click),0) as deep_convert_rate" :""}
           ${array.contain(dimArray,"deep_convert_cost")? ",if(sum(cr.deep_convert_count)!=0,sum(cr.cost)/sum(cr.deep_convert_count)/10000,0) as deep_convert_cost" :""}


           ${array.contain(dimArray,"app_download_start")? ",sum(cr.app_download_start) as app_download_start" :""}
           ${array.contain(dimArray,"app_download_complete")? ",sum(cr.app_download_complete) as app_download_complete" :""}
           ${array.contain(dimArray,"app_activation")? ",sum(cr.app_activation) as app_activation" :""}
           ${array.contain(dimArray,"app_activation_cost")? ",if(sum(app_activation)!=0,sum(cost)/sum(app_activation)/10000,0) as app_activation_cost" :""}
           ${array.contain(dimArray,"app_activation_rate")? ",if(sum(app_download_complete)!=0,sum(app_activation)/sum(app_download_complete),0) as app_activation_rate" :""}
           ${array.contain(dimArray,"app_register")? ",sum(cr.app_register) as app_register" :""}
           ${array.contain(dimArray,"app_register_cost")? ",if(sum(app_register)!=0,sum(cost)/sum(app_register)/10000,0) as app_register_cost" :""}
           ${array.contain(dimArray,"app_register_rate")? ",if(sum(app_activation)!=0,sum(app_register)/sum(app_activation),0) as app_register_rate" :""}
           ${array.contain(dimArray,"app_event_pay_amount")? ",sum(cr.app_event_pay_amount)/100 as app_event_pay_amount" :""}
           ${array.contain(dimArray,"app_event_next_day_stay_rate")? ",if(sum(app_activation)!=0,sum(app_event_next_day_stay)/sum(app_activation),0) as app_event_next_day_stay_rate" :""}
           ${array.contain(dimArray,"event_pay_first_day")? ",sum(cr.event_pay_first_day) as event_pay_first_day" :""}
           ${array.contain(dimArray,"event_pay_purchase_amount_first_day")? ",sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day" :""}
           ${array.contain(dimArray,"first_day_roi")? ",if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi" :""}
           ${array.contain(dimArray,"event_pay")? ",sum(cr.event_pay) as event_pay" :""}
           ${array.contain(dimArray,"event_pay_cost")? ",if(sum(cr.event_pay)!=0,sum(cr.cost)/sum(cr.event_pay)/10000,0) as event_pay_cost" :""}

           ${array.contain(dimArray,"form_count")? ",sum(cr.form_count) as form_count" :""}
           ${array.contain(dimArray,"form_count_click_rate")? ",if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate" :""}
           ${array.contain(dimArray,"form_count_unit_price")? ",if(sum(cr.form_count)!=0,sum(cr.cost)/sum(cr.form_count)/10000,0) as form_count_unit_price" :""}

           ${array.contain(dimArray,"total_play")? ",sum(cr.total_play) as total_play" :""}
           ${array.contain(dimArray,"valid_play")? ",sum(cr.valid_play) as valid_play" :""}
           ${array.contain(dimArray,"valid_play_rate")? ",if(sum(cr.total_play)!=0,sum(cr.valid_play)/sum(cr.total_play),0) as valid_play_rate" :""}
           ${array.contain(dimArray,"valid_play_cost")? ",if(sum(cr.valid_play)!=0,sum(cr.cost)/sum(cr.valid_play),0) as valid_play_cost" :""}

           ${array.contain(dimArray,"play_25_feed_break")? ",sum(cr.play_25_feed_break) as play_25_feed_break" :""}
           ${array.contain(dimArray,"play_50_feed_break")? ",sum(cr.play_50_feed_break) as play_50_feed_break" :""}
           ${array.contain(dimArray,"play_75_feed_break")? ",sum(cr.play_75_feed_break) as play_75_feed_break" :""}
           ${array.contain(dimArray,"play_100_feed_break")? ",sum(cr.play_100_feed_break) as play_100_feed_break" :""}
           ${array.contain(dimArray,"play_100_feed_break_rate")? ",if(sum(cr.total_play)!=0,sum(cr.play_100_feed_break)/sum(cr.total_play),0) as play_100_feed_break_rate" :""}
           ${array.contain(dimArray,"play_duration_per_play")? ",if(sum(cr.total_play)!=0,sum(cr.play_duration_sum)/sum(cr.total_play),0) as play_duration_per_play" :""}
           ${array.contain(dimArray,"wifi_play_rate")? ",if(sum(cr.total_play)!=0,sum(cr.wifi_play)/sum(cr.total_play),0) as wifi_play_rate" :""}

from makepolo.creative_report cr
    ${array.contain(dimArray,"project_id")? "left join makepolo.project pro on pro.id=cr.project_id" :""} 
    ${array.contain(dimArray,"params_account_id")? "left join makepolo.account_user au on au.id=cr.creative_account_id" :""}
    ${array.contain(dimArray,"vendor_id")? "left join makepolo.entity_vendor ev on ev.vendor_id=cr.vendor_id and ev.company_id=cr.company_id" :""}
    ${array.contain(dimArray,"params_vendor_account_id")? "left join makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id" :""}
where cr.date>='${start_date}' and cr.date<='${end_date}' ${where}
group by ${group_str} ${!isEmpty(__sort!) ? __sort:"order by "+order_str}




