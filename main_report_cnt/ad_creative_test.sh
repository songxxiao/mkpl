#!/usr/bin/env bash
export ad_report_db_host="rm-2zed07gjleia95ml1.mysql.rds.aliyuncs.com"
export ad_report_db_user="report"
export ad_report_db_pwd="69PkFs7ty"
export doris_db_host="192.168.28.111"
export doris_db_user="wukong"
export doris_db_port="9030"
export doris_db_pwd="ryAwwsB2q"

basepath=$(cd `dirname $0`; pwd)
source /etc/profile

if [ -f ~/.bash_profile   ];
then
    . ~/.bash_profile
fi

function query_data(){
mysql -h${doris_db_host} -u${doris_db_user} -p${doris_db_pwd} -P${doris_db_port} -e "
 select dat
     , vendor_id
     , company_id
     , count(id) as ctv_cnt
     , count(distinct ad_unit_id) as ad_cnt
     , count(case when create_channel=1 then id end) as ctv_cnt_api
     , count(if(vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003) and create_channel=1,id,null)) as pass_cnt_api
     , count(if(vendor_status not in (0, 11, 41,10001, 10004, 10003) and create_channel=1,id,null)) as pass_cnt_api_div
     , count(if(vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003),id,null)) as pass_cnt
     , count(if(vendor_status not in (0, 11, 41,10001, 10004, 10003),id,null)) as pass_cnt_div
     , count(distinct if(sync_status=4, ad_unit_id,null)) as ad_fail_cnt
     , count(if(sync_status=4, id, null)) as ctv_fail_cnt
from (
 select date(create_time) as dat
     , id
     , ad_unit_id
     , vendor_id
     , company_id
     , create_channel
     , status
     , sync_status
     , vendor_status
from makepolo.ad_creative
where create_time >= '2020-11-15 00:00:00'
    and create_time <= '2020-12-05 23:59:59'
) a group by 1,2,3
"> /home/da/songxiao/mkpl_creative_test

}

function dump_data(){
mysql -h${ad_report_db_host} -u${ad_report_db_user} -p${ad_report_db_pwd} -e "
-- delete from rpt_fancy.mkpl_creative;
load data local infile '/home/da/songxiao/mkpl_creative_test' into table rpt_fancy.mkpl_creative ignore 1 lines;
"
}

starttime=`date +'%Y-%m-%d %H:%M:%S'`
query_data
dump_data
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "程序运行时间: "$((end_seconds-start_seconds))"s"





