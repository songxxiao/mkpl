-- {{start_date}}
-- {{end_date}}
-- {{vendor_account_id}}
-- {{project_id}}
-- {{vendor_id}}
-- {{company_id}}
-- {{dim}}
-- {{campaign_id}} 
-- {{ad_unit_id}} 
-- {{creative_id}}
-- {{select_account_id}}

select
date
${strutil.contain(dim,"cost")? ",Cost as cost" :""}
${strutil.contain(dim,"cost_rebate")? ",Cost_rebate as cost_rebate" :""}
${strutil.contain(dim,"impression")? ",Impression as impression" :""}
${strutil.contain(dim,"click")? ",Click as click" :""}
${strutil.contain(dim,"content_impression")? ",Content_impression as content_impression" :""}
${strutil.contain(dim,"content_click")? ",Content_click as content_click" :""}
${strutil.contain(dim,"click_rate")? ",Click_rate as click_rate" :""}
${strutil.contain(dim,"content_click_rate")? ",Content_click_rate as content_click_rate" :""}
${strutil.contain(dim,"impression_cost")? ",Impression_cost as impression_cost" :""}
${strutil.contain(dim,"click_cost")? ",Click_cost as click_cost" :""}
${strutil.contain(dim,"content_click_cost")? ",Content_click_cost as content_click_cost" :""}
${strutil.contain(dim,"app_download_start")? ",App_download_start as app_download_start" :""}
${strutil.contain(dim,"app_download_complete")? ",App_download_complete as app_download_complete" :""}
${strutil.contain(dim,"app_activation")? ",App_activation as app_activation" :""}
${strutil.contain(dim,"app_activation_cost")? ",App_activation_cost as app_activation_cost" :""}
${strutil.contain(dim,"app_activation_rate")? ",App_activation_rate as app_activation_rate" :""}
${strutil.contain(dim,"app_register")? ",App_register as app_register" :""}
${strutil.contain(dim,"app_register_cost")? ",App_register_cost as app_register_cost" :""}
${strutil.contain(dim,"app_register_rate")? ",App_register_rate as app_register_rate" :""}
${strutil.contain(dim,"app_event_pay_amount")? ",App_event_pay_amount as app_event_pay_amount" :""}
${strutil.contain(dim,"app_event_next_day_stay_rate")? ",App_event_next_day_stay_rate as app_event_next_day_stay_rate" :""}
${strutil.contain(dim,"play_3s_rate")? ",Play_3s_rate as play_3s_rate" :""}
${strutil.contain(dim,"event_pay_first_day")? ",Event_pay_first_day as event_pay_first_day" :""}
${strutil.contain(dim,"event_pay_purchase_amount_first_day")? ",Event_pay_purchase_amount_first_day as event_pay_purchase_amount_first_day" :""}
${strutil.contain(dim,"first_day_roi")? ",First_day_roi as first_day_roi" :""}
${strutil.contain(dim,"event_pay")? ",Event_pay as event_pay" :""}
${strutil.contain(dim,"event_pay_cost")? ",Event_pay_cost as event_pay_cost" :""}
${strutil.contain(dim,"form_count")? ",Form_count as form_count" :""}
${strutil.contain(dim,"form_count_click_rate")? ",Form_count_click_rate as form_count_click_rate" :""}
${strutil.contain(dim,"form_count_unit_price")? ",Form_count_unit_price as form_count_unit_price" :""}

from
(
    select ${start_date == end_date ? "if(hour<10,concat('0',cast(hour,'String'),':00'), concat(cast(hour,'String'),':00'))" : "cr.date"} as date
        ,  sum(cr.cost)/10000                                                                 as Cost
        ,  sum((cr.cost/10000) / (1 + (cr.return_point/100)))                                 as Cost_rebate
        ,  sum(cr.impression)                                                                 as Impression
        ,  sum(cr.click)                                                                      as Click
        ,  sum(cr.content_impression)                                                         as Content_impression
        ,  sum(cr.content_click)                                                              as Content_click
        ,  if(Impression != 0, Click/Impression, 0)                                           as Click_rate
        ,  if(Content_impression != 0, Content_click/Content_impression, 0)                   as Content_click_rate
        ,  if(Impression != 0, Cost/Impression*1000, 0)                                       as Impression_cost
        ,  if(Click != 0, Cost/Click, 0)                                                      as Click_cost
        ,  if(Content_click != 0, Cost/Content_click,0)                                       as Content_click_cost
        ,  sum(cr.app_download_start)                                                         as App_download_start
        ,  sum(cr.app_download_complete)                                                      as App_download_complete
        ,  sum(cr.app_activation)                                                             as App_activation
        ,  if(App_activation != 0, Cost/App_activation, 0)                                    as App_activation_cost
        ,  if(App_download_complete != 0, App_activation/App_download_complete, 0)            as App_activation_rate
        ,  sum(cr.app_register)                                                               as App_register
        ,  if(App_register != 0, Cost/App_register, 0)                                        as App_register_cost
        ,  if(App_activation != 0, App_register/App_activation, 0)                            as App_register_rate
        ,  sum(cr.app_event_pay_amount)/10000                                                   as App_event_pay_amount
        ,  sum(cr.app_event_next_day_stay)                                                    as App_event_next_day_stay
        ,  if(App_activation != 0, App_event_next_day_stay/App_activation, 0)                 as App_event_next_day_stay_rate
        ,  sum(cr.play_3s_count)                                                                 as Play_3s_count
        ,  if(Content_impression != 0, Play_3s_count/Content_impression, 0)                   as Play_3s_rate
        ,  sum(cr.event_pay_first_day)                                                        as Event_pay_first_day
        ,  sum(cr.event_pay_purchase_amount_first_day)/10000                                  as Event_pay_purchase_amount_first_day
        ,  if(Cost != 0, Event_pay_purchase_amount_first_day/Cost, 0)                         as First_day_roi
        ,  sum(cr.event_pay)                                                                  as Event_pay
        ,  if(Event_pay != 0, Cost/Event_pay, 0)                                              as Event_pay_cost
        ,  sum(cr.form_count)                                                                 as Form_count
        ,  if(Content_click != 0, Form_count/Content_click, 0)                                as Form_count_click_rate
        ,  if(Form_count != 0, Cost/Form_count, 0)                                            as Form_count_unit_price    
    from 
    (
        select date, hour, cost, impression, click, content_impression, content_click
            ,  app_download_start, app_download_complete, app_activation, app_register
            ,  app_event_pay_amount, app_event_next_day_stay, event_pay_first_day
            ,  event_pay_purchase_amount_first_day, event_pay, form_count, play_3s_count
            , ifNull(eva.return_point, 0) as return_point
        from makepolo.vendor_creative_report cr 
        <%if(isNotEmpty(project_id) || isNotEmpty(campaign_id) || isNotEmpty(ad_unit_id) || isNotEmpty(creative_id)) {%>
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
            ${isNotEmpty(campaign_id)? "and campaign_id in (" + campaign_id + ")" : ""}
            ${isNotEmpty(ad_unit_id)? "and ad_unit_id in (" + ad_unit_id + ")" : ""}
            ${isNotEmpty(creative_id)? "and creative_id in (" + creative_id + ")" : ""}
        )dims 
        on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
        <%}%>
        left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
        where  cr.date < today()-1 -- 两天前数据不使用final
          and cr.date >= '${start_date}' and cr.date <= '${end_date}'
          ${isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in (" + vendor_account_id + ")" : "and cr.vendor_account_id = -1"}
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}  
          ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}    
          ${isNotEmpty(campaign_id)? "and campaign_id in (" + campaign_id + ")" : ""}
          ${isNotEmpty(ad_unit_id)? "and ad_unit_id in (" + ad_unit_id + ")" : ""}
          ${isNotEmpty(creative_id)? "and creative_id in (" + creative_id + ")" : ""}
          ${isNotEmpty(select_account_id)? "and cr.vendor_account_id in (" + select_account_id + ")" : ""}
        union all      

        select date, hour, cost, impression, click, content_impression, content_click
            ,  app_download_start, app_download_complete, app_activation, app_register
            ,  app_event_pay_amount, app_event_next_day_stay, event_pay_first_day
            ,  event_pay_purchase_amount_first_day, event_pay, form_count, play_3s_count
            , ifNull(eva.return_point, 0) as return_point
        from makepolo.vendor_creative_report cr final
        <%if(isNotEmpty(project_id) || isNotEmpty(campaign_id) || isNotEmpty(ad_unit_id) || isNotEmpty(creative_id)) {%>
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
            ${isNotEmpty(campaign_id)? "and campaign_id in (" + campaign_id + ")" : ""}
            ${isNotEmpty(ad_unit_id)? "and ad_unit_id in (" + ad_unit_id + ")" : ""}
            ${isNotEmpty(creative_id)? "and creative_id in (" + creative_id + ")" : ""}
        )dims 
        on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
        <%}%>
        left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
        where cr.date >= today()-1 -- 最近两天数据使用final
          and cr.date >= '${start_date}' and cr.date <= '${end_date}'
          ${isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in (" + vendor_account_id + ")" : "and cr.vendor_account_id = -1"}
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}
          ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}
          ${isNotEmpty(campaign_id)? "and campaign_id in (" + campaign_id + ")" : ""}
          ${isNotEmpty(ad_unit_id)? "and ad_unit_id in (" + ad_unit_id + ")" : ""}
          ${isNotEmpty(creative_id)? "and creative_id in (" + creative_id + ")" : ""}
          ${isNotEmpty(select_account_id)? "and cr.vendor_account_id in (" + select_account_id + ")" : ""}
    ) cr
    group by ${start_date == end_date ? "cr.date, cr.hour":"cr.date"}
    order by date 
) aa
${__sort!}
