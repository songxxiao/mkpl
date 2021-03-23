

-- KA用户明细数据
select company_name
      , ctv_cnt_api as 'api创建创意数'
      , api_cost as 'api消耗'
      , (ctv_cnt_api - last_ctv_api) / last_ctv_api as 'api创建创意数(环比)'
      , (ctv_cnt - last_ctv) / last_ctv as 'api创建创意数(环比)'
      , (api_cost - last_api_cost) / last_api_cost as 'api消耗(环比)'
from
(
select company_id
  		 , concat(max(b.name), ' ', max(b.id)) as company_name
		 , sum(if(date(dat)= date_sub(curdate(), interval 1 day),ctv_cnt,0)) as ctv_cnt
         , sum(if(date(dat)= date_sub(curdate(), interval 1 day),ctv_cnt_api,0)) as ctv_cnt_api
         , sum(if(date(dat)= date_sub(curdate(), interval 2 day),ctv_cnt,0)) as last_ctv
         , sum(if(date(dat)= date_sub(curdate(), interval 2 day),ctv_cnt_api,0)) as last_ctv_api
from rpt_fancy.mkpl_creative a
left join makepolo_common.account_admin b
		on b.id = a.company_id
 where date(dat) >= date_sub(curdate(), interval 2 day)
   and date(dat) <= date_sub(curdate(), interval 1 day)
   and b.company_type<>1
 group by 1
) a
left join (
		 select eva.company_id as company_id
              , sum(cost)/10000 as cost
              , sum(case when create_channel=1 and date = date_sub(curdate(), interval 1 day) then cost else 0 end)/10000 as api_cost
		      , sum(case when create_channel=1 and date = date_sub(curdate(), interval 2 day) then cost else 0 end)/10000 as last_api_cost
          from makepolo.vendor_creative_report cr
      			left join makepolo.creative_report_dims  dims
                		on dims.vendor_account_id = cr.vendor_account_id
               			 and dims.vendor_creative_id = cr.vendor_creative_id
  				left join makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
      	  where date >= date_sub(curdate(), interval 2 day)
      	    and date <= date_sub(curdate(), interval 1 day)
          group by 1
) c on c.company_id = a.company_id
where api_cost > 50000
order by 2 desc





















































