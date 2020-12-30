-- {{company_id}}
-- {{vendor_id}}
-- {{team}}
select    concat(company.company_name, ' ', company.company_id) as '客户名称'
			 ,  company.company_id
             ,  sum(acc_balance.acc_cnt)                              as acc_cnt                          -- 绑定账户数
             ,  sum(acc_balance.balance)                              as balance                         -- 账户余额
   		     ,  avg(company.company_usetime)                   as company_usetime        -- 代理商创建天数
             ,  max(acc_balance.bind_time)                           as bind_time                     -- 代理商开始绑定天数
         --    ,  max(vdata.first_cost_date) as  first_cost_date
             ,  sum(if(vdata.first_cost_date>= 30, api_cost_30 / 30, api_cost_30 / vdata.first_cost_date )) as api_cost_30 -- 如果api消耗不足30天则有几天算几天
             ,  sum(if(vdata.first_cost_date>= 7, api_cost_7 / 7, api_cost_7 / vdata.first_cost_date )) as api_cost_7
             ,  sum(if(vdata.first_cost_date>= 1, api_cost_yesterday, 0 )) as api_cost_yesterday
from
( select id as company_id
        ,  company_name
        ,  datediff(curdate() , create_time)  as company_usetime      -- 代理商创建天数
    from makepolo_common.account_admin
    where status <> 2 -- and  company_type=${team}                         -- 剔除素材团队
    ${isNotEmpty(company_id) && company_id != '0' ? " and id in (" + company_id + ")" : ""}
) company 
left  join
(
    select company_id
      , count(distinct id) as acc_cnt                                   -- 绑定账户数
      , sum(account_balance) as balance                          -- 余额
     , max(datediff(curdate() , create_time)) as bind_time     -- 开始绑定账户时间
    from makepolo.entity_vendor_account
    where vendor_author_status = 3
      ${isNotEmpty(vendor_id) && vendor_id != '0'  ? " and vendor_id  in (" + vendor_id  + ")" : ""}
      ${isNotEmpty(company_id) && company_id != '0' ? " and company_id in (" + company_id + ")" : ""}
    group by 1
) acc_balance on company.company_id = acc_balance.company_id
left join 
(
  select company_id
     , sum( if( date>=date_sub(curdate(), interval  30 day)                                  -- 过去30天api消耗
                     and date<=date_sub(curdate(), interval  1 day) , ifnull(cost, 0), 0)) as api_cost_30
     , sum( if( date>=date_sub(curdate(), interval  7 day)  and date<=date_sub(curdate(), interval  1 day) , ifnull(cost, 0) , 0))   as api_cost_7 -- 过去7天api消耗
     , sum( if( date = date_sub(curdate(), interval  1 day)  , ifnull(cost, 0),  0 ))   as api_cost_yesterday -- 过去1天api消耗
     , datediff(curdate() , min(if(cost<>0, date, 0))) as first_cost_date                            -- 有api消耗天数
from (
           select date
                , company_id
                , if(create_channel is null, 0,create_channel) as create_channel
                , sum(cost /10000) as cost
         from makepolo.vendor_creative_report cr
         left join [shuffle] makepolo.creative_report_dims dims on dims.vendor_account_id = cr.vendor_account_id
                                        and dims.vendor_creative_id = cr.vendor_creative_id 
  										${isNotEmpty(company_id) && company_id != '0' ? "and dims.company_id in (" + company_id + ")" : ""}
                      where date>=date_sub(curdate(), interval 30 day)  -- 筛选过去30天
                        and date<= date_sub(curdate(), interval  1 day)
  						and  create_channel=1  
  						${isNotEmpty(company_id) && company_id != '0' ? "and company_id in (" + company_id + ")" : ""} 
                     ${isNotEmpty(vendor_id) && vendor_id != '0'  ? " and cr.vendor_id  in (" + vendor_id  + ")" : ""}
           group by 1,2,3
    ) a -- where create_channel=1 ${isNotEmpty(company_id) && company_id != '0' ? "and company_id in (" + company_id + ")" : ""} -- 通过api消耗
group by 1
) vdata on vdata.company_id = company.company_id 
group by 1, 2
order by company.company_id desc

