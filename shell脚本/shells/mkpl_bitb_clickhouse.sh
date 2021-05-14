starttime=`date +'%Y-%m-%d %H:%M:%S'`

if [ -f "./mkpl_bitb_clickhouse" ]; then
  rm ./mkpl_bitb_clickhouse
  else
  echo "the file doesn't exit"
fi
clickhouse-client -h clickhouse.fancydsp.com --port 9900 -u wukong --password ryAwwsB2q -m --query "
select Dat dat
      , Account_id account_id
      , ifnull(Company_id, 0) company_id
      , ifnull(Vendor_id, 0) vendor_id
      , ifnull(Target_type, 0) target_type
      , ifnull(Create_channel, 0) create_channel
      , ifnull(Create_source, 1) create_source  -- 是否通过智能模板创建
      , ifnull(sum(Ctv_cnt), 0) ctv_cnt -- 创建创意数
      , ifnull(sum(Ad_cnt), 0) ad_cnt -- 创建广告数
      , ifnull(sum(Pass_cnt), 0) pass_cnt -- 过审创意数
      , ifnull(sum(Pass_cnt_div), 0) pass_cnt_div -- 同步成功创意数(用作过审率分母)
      , ifnull(sum(Ad_fail_cnt), 0) ad_fail_cnt -- 同步失败广告数
      , ifnull(sum(Ctv_fail_cnt), 0) ctv_fail_cnt -- 同步失败创意数
      , ifnull(sum(Cost), 0) cost              -- 消耗
      , ifnull(sum(Cnt_cost_ctv), 0) cnt_cost_ctv -- 有消耗创意数
      , ifnull(sum(Cnt_cost_ad), 0) cnt_cost_ad -- 有消耗广告数
from
(
    select toDate(cr.date) Dat
         , eva.subordinate_account_id Account_id
         , toInt32(ifnull(ifnull(dims.company_id, cp.company_id), eva.company_id)) Company_id
         , toInt32(ifnull(cr.vendor_id, eva.vendor_id)) Vendor_id
         , toInt32(ifnull(cp.target_type, 0)) Target_type
         , toInt32(ifnull(dims.create_channel, 0)) Create_channel
         , toInt32(ifnull(cp.create_source, 1)) Create_source
         , 0 Pass_cnt
         , 0 Pass_cnt_div
         , 0 Ad_fail_cnt
         , 0 Ctv_fail_cnt
         , 0 Ad_cnt
         , 0 Ctv_cnt
         , sum(cost) Cost
         , count(distinct if(cr.cost>0, dims.creative_id, null)) Cnt_cost_ctv
         , count(distinct if(cr.cost>0, dims.ad_unit_id, null))  Cnt_cost_ad
   from makepolo.vendor_creative_report cr final
   left join makepolo.creative_report_dims_local dims final
       on dims.vendor_account_id = cr.vendor_account_id
         and dims.vendor_creative_id = cr.vendor_creative_id
   left join makepolo.entity_vendor_account eva on eva.id = cr.vendor_account_id
   left join makepolo.campaign cp
       on cp.vendor_campaign_id = cr.vendor_campaign_id
        and toInt64(cp.vendor_account_id) = toInt64(cr.vendor_account_id)
        and cp.vendor_id = cr.vendor_id
   where cr.date >= '2021-04-01'
      and cr.date < '2021-04-26'
   group by Dat, Account_id, Company_id, Vendor_id, Target_type, Create_channel, Create_source

   union all

   select toDate(formatDateTime(a.create_time,'%Y-%m-%d')) Dat
         , eva.subordinate_account_id Account_id
         , a.company_id Company_id
         , ifnull(a.vendor_id, eva.vendor_id) Vendor_id
         , ifnull(cp.target_type, 0) Target_type
         , ifnull(a.create_channel, 0) Create_channel
         , ifnull(cp.create_source, 1) Create_source
         , count(if(a.vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003), a.id, null)) Pass_cnt
         , count(if(a.vendor_status not in (0, 11, 41,10001, 10004, 10003), a.id, null)) Pass_cnt_div
         , count(distinct if(a.sync_status=4, ad_unit_id,null)) Ad_fail_cnt
         , count(if(a.sync_status=4, a.id, null)) Ctv_fail_cnt
         , 0 Ad_cnt
         , count(distinct a.id) Ctv_cnt
         , 0 Cost
         , 0 Cnt_cost_ctv
         , 0 Cnt_cost_ad
   from (select * from makepolo.ad_creative final
               where create_time >= '2021-04-01'
                 and create_time < '2021-04-26') a
   left join makepolo.entity_vendor_account eva on toInt64(eva.id) = toInt64(a.vendor_account_id)
   left join makepolo.campaign cp on cp.vendor_account_id = a.vendor_account_id
                 and a.campaign_id = cp.id
                 and cp.vendor_id = a.vendor_id
   group by Dat, Account_id, Company_id, Vendor_id, Target_type, Create_channel, Create_source

   union all 

   select toDate(formatDateTime(a.create_time,'%Y-%m-%d')) Dat
         , eva.subordinate_account_id Account_id
         , a.company_id Company_id
         , ifnull(a.vendor_id, eva.vendor_id) Vendor_id
         , ifnull(cp.target_type, 0) Target_type
         , ifnull(a.create_channel, 0) Create_channel
         , ifnull(cp.create_source, 1) Create_source
         , 0 Pass_cnt
         , 0 Pass_cnt_div
         , 0 Ad_fail_cnt
         , 0 Ctv_fail_cnt
         , count(distinct a.id) Ad_cnt
         , 0 Ctv_cnt
         , 0 Cost
         , 0 Cnt_cost_ctv
         , 0 Cnt_cost_ad
   from (select * from makepolo.ad_unit final
         where create_time >= '2021-04-01'
           and create_time < '2021-04-26') a
   left join makepolo.entity_vendor_account eva on toInt64(eva.id) = toInt64(a.vendor_account_id)
   left join makepolo.campaign cp on cp.vendor_account_id = a.vendor_account_id
                 and a.campaign_id = cp.id
                 and cp.vendor_id = a. vendor_id
   group by Dat, Account_id, Company_id, Vendor_id, Target_type, Create_channel, Create_source
) b
group by dat, account_id, company_id, vendor_id, target_type, create_channel, create_source
INTO OUTFILE './mkpl_bitb_clickhouse'"
if [ $? -ne 0 ]; then
  echo "execute failed"
  exit -1
fi

time3=$(date -d "3 day ago" "+%Y-%m-%d")
time1=$(date -d "1 day ago" "+%Y-%m-%d")
clickhouse-client -h clickhouse.fancydsp.com --port 9900 -u makepolo_da --password ryAwwsB2q -m --query "
alter table makepolo_da.makepolo_bitb_local on cluster cluster_5s_2r delete where dat>= '${time3}' and dat<='${time1}'
" 
if [ $? -ne 0 ]; then
  echo "delete failed"
  exit 1
fi

clickhouse-client -h clickhouse.fancydsp.com --port 9900 -u makepolo_da --password ryAwwsB2q -m --query "
INSERT INTO makepolo_da.makepolo_bitb FORMAT TSV
" --max_insert_block_size=200000 --date_time_input_format best_effort --insert_distributed_sync 1 <./mkpl_bitb_clickhouse
if [ $? -ne 0 ]; then
  echo "clickhouse import failed"
  exit 1
fi

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "程序运行时间: "$((end_seconds-start_seconds))"s"