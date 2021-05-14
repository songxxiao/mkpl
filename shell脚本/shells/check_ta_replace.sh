#!/usr/bin/env bash
#dat:2019-04-09
#描述:检查ta包是否替换成功
#使用方式:sh check_ta_replace.sh 2019-04-08 2019-04-08 20545 631 mz

basepath=$(cd `dirname $0`;pwd)

source /etc/profile

if [ -f ~/.bash_profile  ];
    then
    . ~/.bash_profile
fi

start_dat=${1}
end_dat=${2}
adv=${3}
ta_id=${4}
part=${5}

function get_adm_device(){
sql="select case when length(device_id)=36 then regexp_extract_all(seat_bid_imp_monitor_urls,'((?<=,z)[0-9A-Fa-f-]*)')[1]
when length(device_id)=32 then regexp_extract_all(seat_bid_imp_monitor_urls,'((?<=0c)[0-9A-Fa-f]*)')[1] else '' end as device_id
from dwd.d_ad_ftx_response_dsp where dspid='1' and thisdate between '${start_dat}' and  '${end_dat}' and seat_bid_advertiser_id=${adv} 
and error_code=0 group by 1;"

    r=`presto --output-format TSV --execute "${sql}" > response_${ta_id}`
    if [ "${r}" ]
    then
        echo "Execute ${basepath}/$(basename $0) failed."
        echo "SQL:${sql}"
        exit 1
    fi

}


function get_mz_device(){
sql="select case when length(device_id)=36 then regexp_extract_all(seat_bid_imp_monitor_urls,'((?<=m5=)[0-9A-Fa-f-]*)')[1]
when length(device_id)=32 then regexp_extract_all(seat_bid_imp_monitor_urls,'((?<=m2=)[0-9A-Fa-f]*)')[1] else '' end as device_id
from dwd.d_ad_ftx_response_dsp where dspid='1' and thisdate between '${start_dat}' and  '${end_dat}' and seat_bid_advertiser_id=${adv} 
and error_code=0 group by 1;"

    r=`presto --output-format TSV --execute "${sql}" > response_${ta_id}`
    if [ "${r}" ]
    then
        echo "Execute ${basepath}/$(basename $0) failed."
        echo "SQL:${sql}"
        exit 1
    fi

}

function check_ta(){
: '这里有一点需要注意，在我们重复推ta包的情况下或者有多个ta包的同时使用情况下
，我们需要把正在挂的ta包的device全部load到${ta_id}中,这部分需要花一分钟手工执行下面第一条命令(注意用awk命令去操作)
,然后我们再执行check_ta函数，如果只有一个ta包，可以直接运行check_ta函数'

cat /home/da/push_ta/dummy_device/${ta_id}* | awk -F'\t' '{print $1}' >> ${ta_id} 

count_ta=`sort ${ta_id} | uniq | wc -l`
echo "TA包条数：$count_ta"

count_sql=`cat response_${ta_id} | wc -l`
echo "查询条数: $count_sql"

success=`awk '{if(ARGIND==1) {val[$0]}else{if($0 in val) print $0}}' ${ta_id} response_${ta_id} | wc -l`
echo "替换成功数: $success"

rate=`awk 'BEGIN{printf "%.2f%\n",('$success'/'$count_sql')*100}'`
echo "成功率: $rate"

}



function main(){
    cd $basepath
    if [ $part == 'adm'  ];then
        get_adm_device
    else
        get_mz_device
    fi
#    check_ta

}
main
