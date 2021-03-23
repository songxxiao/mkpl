select a.company_id as company_id
     , a.vendor_id  as vendor_id
     , company_name
     , ctv_cnt -- 总创建创意
     , ctv_cnt_api -- api创建创意
     , last_ctv  -- 前日创建创意
     , last_ctv_api -- 前日api创建创意
     , create_time -- 创建时间
     , cst_ysd -- 昨日总消耗
     , api_cst -- 昨日api消耗
     , last_api_cst -- 前日api消耗
     , api_cst8 -- 8日前api消耗
     , api_cst7ds -- 连续7天api消耗
     , bind_acct -- 昨日绑定账户数
     , pro_num -- 昨日创建项目数
from
(
    select company_id
         , a.vendor_id as vendor_id
         , concat(max(b.name), ' ', max(b.id)) as company_name
         , sum(if(date(dat)= date_sub(curdate(), interval 1 day),cnt_creative,0)) as ctv_cnt
         , sum(if(date(dat)= date_sub(curdate(), interval 1 day) and create_channel = 1,cnt_creative,0)) as ctv_cnt_api
         , sum(if(date(dat)= date_sub(curdate(), interval 2 day),cnt_creative,0)) as last_ctv
         , sum(if(date(dat)= date_sub(curdate(), interval 2 day) and create_channel = 1,cnt_creative,0)) as last_ctv_api
         , max(date(b.create_time)) as create_time
    from makepolo.makepolo_creative_statistics a
    left join makepolo_common.account_admin b
        on b.id = a.company_id
     where date(dat) >= date_sub(curdate(), interval 8 day)
           and date(dat) <= date_sub(curdate(), interval 1 day)
           and b.company_type=0 and b.status = 1 and b.id not in (1, 122, 139, 178, 176, 175, 168, 199, 236, 256, 303, 150324)
     group by 1,2
) a
left join (
         select eva.company_id as company_id
              , cr.vendor_id as vendor_id
              , sum(case when date = date_sub(curdate(), 1) then cost else 0 end) / 10000 as cst_ysd
              , sum(case when create_channel=1 and date = date_sub(curdate(), 1) then cost else 0 end) / 10000 as api_cst
              , sum(case when create_channel=1 and date = date_sub(curdate(), 2) then cost else 0 end) / 10000 as last_api_cst
              , sum(case when create_channel=1 and date = date_sub(curdate(), 8) then cost else 0 end) / 10000 as api_cst8
              , sum(case when create_channel=1 and date >= date_sub(curdate(), 7)
                    and date <= date_sub(curdate(), 1) then cost else 0 end) / 10000 as api_cst7ds
              , count(distinct if(date(eva.create_time) = date_sub(curdate(),1), eva.id, 0)) as bind_acct
              , count(distinct if(date(pro.create_time) = date_sub(curdate(),1), pro.id, 0)) as pro_num
         from makepolo.vendor_creative_report cr
          left join makepolo.creative_report_dims dims
                    on dims.vendor_account_id = cr.vendor_account_id
                  and dims.vendor_creative_id = cr.vendor_creative_id
          left join makepolo.entity_vendor_account eva
              on eva.id = cr.vendor_account_id
          left join makepolo.project pro on dims.project_id = pro.id
          where date >= date_sub(curdate(), interval 8 day)
            and date <= date_sub(curdate(), interval 1 day)
          group by 1,2
) c on c.company_id = a.company_id and a.vendor_id = c.vendor_id

