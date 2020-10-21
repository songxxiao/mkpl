
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

function qtt_adx(){
mysql -h${doris_db_host} -u${doris_db_user} -p${doris_db_pwd} -P${doris_db_port} -e "
select dat
     , vendor_id
     , company_id
     ,  count(id) as creative_cnt
     ,  count(case when create_channel=1 then id end) as creative_cnt_api
from (
      select date_format(create_time,'%Y-%m-%d') as dat
           , id
           , vendor_id
           , company_id
           , create_channel
      from makepolo.ad_creative
      where create_time>= concat(date_format(date_sub(now(), interval 32 day), '%Y-%m-%d'),' 00:00:00')
        and create_time<=concat(date_format(date_sub(now(), interval 1 day), '%Y-%m-%d'),' 23:59:59')
      group by 1,2,3, 4,5
) a
group by 1,2,3
"> /home/da/songxiao/mkpl_creative

}

function db(){
mysql -h${ad_report_db_host} -u${ad_report_db_user} -p${ad_report_db_pwd} -e "
-- delete from rpt_fancy.mkpl_creative;
LOAD DATA LOCAL INFILE '/home/da/songxiao/mkpl_creative' INTO TABLE  rpt_fancy.mkpl_creative;
"
}

qtt_adx
db


