# 用来落中间表
#device_click_group
export doris_db_host="doris.fancydsp.com"
export doris_db_user="wukong"
export doris_db_port="3306"
export doris_db_pwd="ryAwwsB2q"

export mkpl_da_user="makepolo_da"

basepath=$(cd `dirname $0`; pwd)
source /etc/profile

if [ -f ~/.bash_profile   ];
then
    . ~/.bash_profile
fi

starttime=`date +'%Y-%m-%d %H:%M:%S'`

outputFile=/home/da/songxiao/mkpl_bitb
mysql -N -h${doris_db_host} -u${doris_db_user} -p${doris_db_pwd} -P${doris_db_port} -e"
select dat
      , account_id
      , ifnull(company_id, 0) company_id
      , ifnull(vendor_id, 0)
      , ifnull(target_type, 0) target_type
      , ifnull(create_channel, 0) create_channel
      , ifnull(create_source, 1) create_source  -- 是否通过智能模板创建
      , ifnull(sum(ctv_cnt), 0) ctv_cnt -- 创建创意数
      , ifnull(sum(ad_cnt), 0) ad_cnt -- 创建广告数
      , ifnull(sum(pass_cnt), 0) pass_cnt -- 过审创意数
      , ifnull(sum(pass_cnt_div), 0) pass_cnt_div -- 同步成功创意数(用作过审率分母)
      , ifnull(sum(ad_fail_cnt), 0) ad_fail_cnt -- 同步失败广告数
      , ifnull(sum(ctv_fail_cnt), 0) ctv_fail_cnt -- 同步失败创意数
      , ifnull(sum(cost), 0) cost              -- 消耗
      , ifnull(sum(cnt_cost_ctv), 0) cnt_cost_ctv -- 有消耗创意数
      , ifnull(sum(cnt_cost_ad), 0) cnt_cost_ad -- 有消耗广告数
from
(
    select cr.date dat
         , eva.subordinate_account_id account_id
         , ifnull(ifnull(dims.company_id, cp.company_id), eva.company_id) company_id
         , ifnull(cr.vendor_id, eva.vendor_id) vendor_id
         , ifnull(cp.target_type, 0) target_type
         , ifnull(dims.create_channel, 0) create_channel
         , ifnull(cp.create_source, 1) create_source
         , 0 pass_cnt
         , 0 pass_cnt_div
         , 0 ad_fail_cnt
         , 0 ctv_fail_cnt
         , 0 ad_cnt
         , 0 ctv_cnt
         , sum(cost) cost
         , count(distinct if(cr.cost>0, dims.creative_id, null)) cnt_cost_ctv
         , count(distinct if(cr.cost>0, dims.ad_unit_id, null)) cnt_cost_ad
   from makepolo.vendor_creative_report cr
   left join makepolo.creative_report_dims dims
       on dims.vendor_account_id = cr.vendor_account_id
         and dims.vendor_creative_id = cr.vendor_creative_id
   left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
   left join makepolo.campaign cp
       on cp.vendor_campaign_id = cr.vendor_campaign_id
        and cp.vendor_account_id = cr.vendor_account_id
        and cp.vendor_id = cr.vendor_id
   where cr.date >= '2021-01-01'
      and cr.date <= '2021-02-24'
   group by 1,2,3,4,5,6,7

   union all

   select date_format(a.create_time,'%Y-%m-%d') dat
         , eva.subordinate_account_id account_id
         , a.company_id company_id
         , ifnull(a.vendor_id, eva.vendor_id) vendor_id
         , ifnull(cp.target_type, 0) target_type
         , ifnull(a.create_channel, 0) create_channel
         , ifnull(cp.create_source, 1) create_source
         , count(if(a.vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003), a.id, null)) pass_cnt
         , count(if(a.vendor_status not in (0, 11, 41,10001, 10004, 10003), a.id, null)) pass_cnt_div
         , count(distinct if(a.sync_status=4, ad_unit_id,null)) ad_fail_cnt
         , count(if(a.sync_status=4, a.id, null)) ctv_fail_cnt
         , count(distinct ad_unit_id) ad_cnt
         , count(distinct a.id) ctv_cnt
         , 0 cost
         , 0 cnt_cost_ctv
         , 0 cnt_cost_ad
   from makepolo.ad_creative a
   left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
   left join makepolo.campaign cp on cp.vendor_account_id = a.vendor_account_id 
                 and a.campaign_id = cp.id 
                 and cp.vendor_id = a. vendor_id
   where a.create_time >= concat('2021-01-01',' 00:00:00')
     and a.create_time <= concat('2021-02-24',' 23:59:59')
   group by 1,2,3,4,5,6,7

   union all 

   select date_format(a.create_time,'%Y-%m-%d') dat
         , eva.subordinate_account_id account_id
         , a.company_id company_id
         , ifnull(a.vendor_id, eva.vendor_id) vendor_id
         , ifnull(cp.target_type, 0) target_type
         , ifnull(a.create_channel, 0) create_channel
         , ifnull(cp.create_source, 1)  create_source
         , 0 pass_cnt
         , 0 pass_cnt_div
         , 0 ad_fail_cnt
         , 0 ctv_fail_cnt
         , count(distinct a.id) ad_cnt
         , 0 ctv_cnt
         , 0 cost
         , 0 cnt_cost_ctv
         , 0 cnt_cost_ad
   from makepolo.ad_unit a
   left join makepolo.entity_vendor_account eva on eva.id = a.vendor_account_id
   left join makepolo.campaign cp on cp.vendor_account_id = a.vendor_account_id 
                 and a.campaign_id = cp.id 
                 and cp.vendor_id = a. vendor_id
   where a.create_time >= concat('2021-01-01',' 00:00:00')
     and a.create_time <= concat('2021-02-24',' 23:59:59')
   group by 1,2,3,4,5,6,7
) b
group by 1,2,3,4,5,6,7
 "> ${outputFile}
if [ $? -ne 0 ]; then
  echo "execute failed"
  exit -1
fi

label=bitb_`date +%Y%m%d%H%M`
resp=$(curl -s --location-trusted -u makepolo_da:ryAwwsB2q  -H "label:${label}"  -T "${outputFile}" http://doris.fancydsp.com:8830/api/makepolo_da/makepolo_bitb/_stream_load)
status=$(echo "${resp}"| jq .Status)
if [[ "$status" != "\"Success\"" ]]
then
  echo "Execute stream load failed.$outputFile"
  echo "${resp}"
  exit -1
fi

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "程序运行时间: "$((end_seconds-start_seconds))"s"




