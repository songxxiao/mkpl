#/bin/bash

source /etc/profile
source ~/.bashrc

if [ $(echo $0 | grep '^/') ]; then
    cmd_path=$(dirname $0)
else
    cmd_path=$(pwd)/$(dirname $0)
fi

cd $cmd_path
cmd_path=$(pwd)

# 这里需要注意脚本文件在工程目录的具体位置，不然获取工程目录会出错
if [ "${PROJECT_HOME}"x = ""x ]; then
    export PROJECT_HOME=$(dirname $(dirname $cmd_path))
fi
# source ${PROJECT_HOME}/conf/global_conf.sh
# source ${PROJECT_HOME}/conf/global_func.sh

## 工程目录代码到此结束

#data_path=${PROJECT_DATA}/workers
#log_path=${PROJECT_LOG}/workers

partition_date=`date -d "-0 day" +%Y-%m-%d`
yesterday=`date -d "-0 day" +%Y-%m-%d`


function check_date(){
presto --execute "select * from dwd.qtt_user_profile where thisdate='${yesterday}' limit 1;" --output-format TSV > device_date

qtt_day=${yesterday}
until [ -s device_date ]
do
    qtt_day=`date -d"yesterday ${qtt_day}" +%Y-%m-%d`
    presto --execute "select * from dwd.qtt_user_profile where thisdate='${qtt_day}' limit 1;" --output-format TSV > device_date
done
}



function usage() {
    echo "
    Usage: sh ${0} -s start_date -e end_date -o order_path
    Excample: sh ${0} -s '2020-09-01' -e '2020-12-01' -o order_path

      -s start_date 开始日期
      -e end_date 结束日期
      -o 子订单的订单id文件地址
    " >&2
}


function check_opts(){
    if [ "${order_file}"x = ""x ] || [ ! -f ${order_file} ] || [ ! -s ${order_file} ]; then
        echo "传入的数据文件[${order_file}]不存在或者文件为空"
        usage
        exit 1
    fi
}

function load_temp_data(){
sql="
use rpt;
insert overwrite table base_nequal_bid_uid partition(thisdate='${data_date}')
select distinct case when seat_bid_custom_replace_device_id is null then fancy_user_id else seat_bid_custom_replace_device_id end 
from dwd.d_ad_ftx_response
where thisdate = '${data_date}'
and seat_bid_order_id in (${order_ids})
and seat_bid_resp_success =1;"
#echo $sql
hive -e"${sql}"
}

function load_data(){
partitions_info=`hdfs dfs -du -h /warehouse/rpt.db/base_nequal_uid_tags | tail -1`
uid_day=${partitions_info#*thisdate=}
partitions_info=`hdfs dfs -du -h /warehouse/rpt.db/base_all_tags | tail -1`
wb_day=${partitions_info#*thisdate=}
echo "上次洗数据日期是'${uid_day}',wb最新数据是'${wb_day}',qtt日期最新日期是'${qtt_day}'"
sql="
use rpt;
insert overwrite table base_nequal_uid_tags partition(thisdate='${partition_date}')
select uid,
    mz_gender,
    mz_age,
    case when q_gender is null then qtt_gender else q_gender end qtt_gender,
    case when w_gender is null then wb_gender else w_gender end  wb_gender
from (
    select table1.uid, mz_gender, mz_age, qtt_gender, wb_gender,tableqtt.q_gender,tablewb.w_gender
    from (
        select uid,
            min(mz_gender)  mz_gender,
            max(mz_age)     mz_age,
            max(qtt_gender) qtt_gender,
            max(wb_gender)  wb_gender
        from (
            select uid, mz_gender, mz_age, qtt_gender, wb_gender
            from rpt.base_nequal_uid_tags
            where thisdate = '${uid_day}'
            union
            select uid, '2500100020', '2600100002,2600100003,2600100004', null, null
            from rpt.base_nequal_bid_uid
            where thisdate >= '${start_date}'
            and thisdate <='${end_date}'
            ) union_table
        group by uid
        ) table1
        left join
        (
        select uid,
            case
            when gender = '1' then '2500100010'
            when gender = '2' then '2500100020'
            else '2500100030' end q_gender
        from dwd.qtt_user_profile
        where thisdate = '${qtt_day}'
        and gender in ('1', '2')
        ) tableqtt on table1.uid = tableqtt.uid
        left join
        (
        select fancy_id, fancy_gender w_gender
        from rpt.base_all_tags
        where thisdate = '${wb_day}'
        and source_id = '2'
        and fancy_gender in ('2500100010', '2500100020')
        ) tablewb on table1.uid = tablewb.fancy_id
    ) table2
"
hive -e"$sql"
}

while getopts 'hs:e:o:' OPT; do
    case $OPT in
        o) order_file=$OPTARG;;
        s) start_date=$OPTARG;;
        e) end_date=$OPTARG;;
        h) usage
           exit 0;;
        ?) usage
           exit 1;;
    esac
done

check_opts
order_ids=`cat $order_file`
check_date
data_date=${start_date}
while [[ ${data_date} < ${end_date} || "$data_date" == "$end_date" ]]
do 
  echo ${data_date}
  load_temp_data
  data_date=`date -d "tomorrow $data_date" +"%Y-%m-%d"`
done

load_data
