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

select sum(cost) cost -- 消耗
   , sum(cost_rebate) cost_rebate -- 返点后消耗
   , sum(click_rate) click_rate -- 点击率
   , sum(click_cost) click_cost -- 平均点击成本
   , sum(app_activation) app_activation -- 激活数
   , sum(app_activation_rate) app_activation_rate -- 激活率
   , sum(app_activation_cost) app_activation_cost -- 平均激活成本
   , sum(form_count) form_count -- 表单提交数
   , sum(form_count_unit_price) form_count_unit_price -- 表单提交单价
   , sum(chain_cost) chain_cost -- 总消耗(环比)
   , sum(chain_cost_rebate) chain_cost_rebate -- 返点后消耗(环比)
from(
      select
            sum(cr.cost)/10000 as cost
            ,sum((cr.cost/10000) / (1 + (eva.return_point/100)))  as cost_rebate
            ,if(sum(impression)!=0,sum(click)/sum(impression),0) as click_rate
            ,if(sum(click)!=0,sum(cost)/sum(click)/10000,0) as click_cost
            ,sum(cr.app_activation) as app_activation
            ,if(sum(app_download_complete)!=0,sum(app_activation)/sum(app_download_complete),0) as app_activation_rate
            ,if(sum(app_activation)!=0,sum(cost)/sum(app_activation)/10000,0) as app_activation_cost
            ,sum(cr.form_count) as form_count
            ,if(sum(cr.form_count)!=0,sum(cr.cost)/sum(cr.form_count)/10000,0) as form_count_unit_price
            , 0 as chain_cost
            , 0 as chain_cost_rebate
      from makepolo.vendor_creative_report cr
	      left join makepolo.creative_report_dims dims
    				on dims.vendor_account_id = cr.vendor_account_id
					and dims.vendor_creative_id = cr.vendor_creative_id and dims.company_id in (2)
      left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
      where cr.date>='${start_date}' and cr.date<='${end_date}' ${where}

      union all

      select 0 as cost
            , 0 as cost_rebate
            , 0 as click_rate
            , 0 as click_cost
            , 0 as app_activation
            , 0 as app_activation_rate
            , 0 as app_activation_cost
            , 0 as form_count
            , 0 as form_count_unit_price
            , (cost - last_period_cost) / last_period_cost as chain_cost
            , (cost_rebate - last_cost_rebate) / last_cost_rebate as chain_cost_rebate
      from (
                select sum(case
                   when date >= date_format(date_sub('${start_date}', interval datediff('${end_date}', '${start_date}') + 1 day),
                                        '%Y-%m-%d')
               and date < date_format(date_sub('${start_date}', interval 1 day), '%Y-%m-%d')
               or case
               when date = date_format(date_sub('${start_date}', interval 1 day), '%Y-%m-%d') then if(
                           date_format(curdate(), '%Y-%m-%d') = '${end_date}', hour <= hour(now()), true)
                          else false end
                   then cost
               else 0 end) as last_period_cost
                  , sum(case
               when date >= date_format(date_sub('${start_date}', interval datediff('${end_date}', '${start_date}') + 1 day),
                                        '%Y-%m-%d')
               and date < date_format(date_sub('${start_date}', interval 1 day), '%Y-%m-%d')
               or case
               when date = date_format(date_sub('${start_date}', interval 1 day), '%Y-%m-%d') then if(
                           date_format(curdate(), '%Y-%m-%d') = '${end_date}', hour <= hour(now()), true)
                          else false end
                   then cost / (1 + (eva.return_point/100))
               else 0 end) as last_cost_rebate
             , sum(if(date >= '${start_date}' and date <= '${end_date}', cost, 0)) as cost
             , sum(if(date >= '${start_date}' and date <= '${end_date}', cost / (1 + (eva.return_point/100)), 0)) as cost_rebate
      from makepolo.vendor_creative_report cr
         left join makepolo.creative_report_dims dims
              on dims.vendor_account_id = cr.vendor_account_id
              and dims.vendor_creative_id = cr.vendor_creative_id ${isNotEmpty(company_id)? " and dims.company_id in (" + company_id + ")" : ""}
         left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
      where date >= date_format(date_sub('${start_date}', interval datediff('${end_date}', '${start_date}') + 1 day), '%Y-%m-%d')
            and date <= '${end_date}'
      ${where}
    ) a
) b
