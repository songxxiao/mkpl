#!/usr/bin/env bash

# rpt_fancy.mkpl_creative中间表加字段。将ad_cnt_api字段导入中间表。

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
 select date(create_time) as dat
    , vendor_id
    , company_id
    , count(distinct if(create_channel=1, ad_unit_id,null)) as ad_cnt_api
from makepolo.ad_creative
where create_time >= '2020-09-14 00:00:00'
    and create_time <= '2020-12-25 23:59:59'
group by 1,2,3
"> /home/da/songxiao/mkpl_creative_ad_cnt

}

function dump_data(){
mysql -h${ad_report_db_host} -u${ad_report_db_user} -p${ad_report_db_pwd} -e "
-- delete from rpt_fancy.mkpl_creative;
load data local infile '/home/da/songxiao/mkpl_creative_ad_cnt' into table rpt_fancy.mkpl_creative_ad_cnt ignore 1 lines;
"
}

starttime=`date +'%Y-%m-%d %H:%M:%S'`
query_data
dump_data
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "程序运行时间: "$((end_seconds-start_seconds))"s"
