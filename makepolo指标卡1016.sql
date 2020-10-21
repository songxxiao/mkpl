 -- {{channel_api}} 
 -- {{dim}} 
 -- dim为1时取7天， dim为0时取昨天
 
 <%
var start_time0 = 0;
var end_time0 = 0;
var start_time = 0;
var end_time = 0;

if(dim=="1"){
start_time0 = 14
end_time0 = 8
start_time = 7
end_time = 1
}else{ 
start_time0 = 2
end_time0 = 2
start_time = 1
end_time = 1
}
%>

select this_period                               as '绝对值'
      ,(this_period - last_period) / last_period as '环比'
from(
select  sum(if(${strutil.contain(channel!'1', '1') ? "create_channel=1 and":""} date=date_format(date_sub(now(), interval ${start_time0} day), '%Y-%m-%d')
             and date<=date_format(date_sub(now(), interval ${end_time0} day), '%Y-%m-%d'), a.cost, 0))/10000 as last_period
      , sum(if(strutil.contain(channel!'1', '1') ? "create_channel=1 and":""} date>=date_format(date_sub(now(), interval ${start_time} day), '%Y-%m-%d')
             and date<=date_format(date_sub(now(), interval ${start_time} day), '%Y-%m-%d'), a.cost, 0))/10000 as this_period
from (select date       -- 日期
           , create_channel -- api
           , sum(cost) as cost
        from  makepolo.creative_report
        where date>= date_format(date_sub(now(), interval ${start_time0} day), '%Y-%m-%d')                                  
                     and date<=date_format(date_sub(now(), interval ${end_time} day), '%Y-%m-%d')
        group by 1, 2
    ) a
) b








select date_format(create_time,'%Y-%m-%d') as dat
              ,  count(distinct id) as '昨日创建创意数'
              ,  count(distinct case when create_channel=1 then id end) as '昨日通过API创建创意数'
from makepolo.ad_creative
where create_time>= '{{yesterday}} 00:00:00' and create_time<='{{yesterday}} 23:59:59'
group by 1




