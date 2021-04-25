--  {{settlement_interval}}
--  {{order_id}}
--  {{settlement_type}}
--  {{view}}



<%
var where_str="";
var where_str1="";
var type_str="";
var type_cost_str="";
var type_now_str="";
var is_outsource="";
var company_type="";
var proportion="";
var price="";
var col_str="";
var group_str1="";
var group_str2="";

if(order_id!""==''){
    	where_str+="";
	}else{
		where_str+=" and state.order_id = "+order_id;
}


if(view!""=='1'){
    type_cost_str="8";
    type_now_str="3";
    type_str="3,8";
    is_outsource="0";
    company_type="1";
    proportion="consume_proportion";
    price="price";
    
}else if(view!""=='2'){
	type_cost_str="7";
    type_now_str="5";
    type_str="5,7";
    is_outsource="0";
    company_type="2";
    proportion="consume_proportion";
    price="price";
    
}else if(view!""=='3'){
    type_cost_str="8";
    type_now_str="3";
    type_str="3,8";
    is_outsource="1";
    company_type="2";
    proportion="outsource_consume_proportion"; 
    price="outsource_price";
         
}else if(view!""=='4'){
    type_cost_str="7";
    type_now_str="5";
    type_str="5,7";
    is_outsource="1";
    company_type="2";
    proportion="outsource_consume_proportion"; 
    price="outsource_price";
}
%>


 <%
 if(settlement_type=='2'){
 %>



select t3.replace_video_index as replace_video_index
      , max(if(is_replace_video=0,t3.id,t1.video_id)) as id
      , max(if(is_replace_video=0,t3.url,null)) as url 
      , max(if(is_replace_video=0,t3.cover_image_url,null)) as cover_image_url
      , max(if(is_replace_video=0,t3.name,null)) as name
      , max(case when t3.is_free=1 then '是' else '否' end) as is_free
      , sum(case when money_type='now' then money else 0 end) as floor_price
      , max(settlement_interval) as settlement_date
      , sum(case when money_type = 'cost' then cost else 0 end) as cost
      , max(t2.${proportion}) as consume_proportion
      , sum(case when money_type='cost' then money else 0 end) as commission
      , sum(money) as money
from (
         select settlement_date
               , order_id
               , money_type
               , video_id
               , settlement_interval
               , sum(cost)  as cost
               , sum(money) as money
         from (
                  select b.order_id
                        , b.video_id
                        , 'cost'                                                         as money_type
                        , concat(min_date, '--', date_add(min_date, interval 29 day))    as settlement_interval
                        , date_format(max(date_add(min_date, interval 29 day)), '%Y-%m') as settlement_date
                        , sum(cost)                                                      as cost
                        , sum(money)                                                     as money
                  from (
                           select video_id
                                , min(state.date) as min_date
                           from makepolo.account_statement state
                                    left join makepolo.material_market_order od on state.order_id = od.id
                           where state.is_outsource = 0
                             and company_type = ${company_type}
                            ${where_str}
                             and type = ${type_cost_str}
                             and settlement_method = 2
                             and origin_consume > 0
                           group by 1
                       ) a
                           join (
                      select date
                             , video_id
                             , order_id
                             , origin_consume as cost
                             , money
                      from makepolo.account_statement state
                               left join makepolo.material_market_order od on state.order_id = od.id
                      where state.is_outsource =${ is_outsource}
                        ${where_str}
                        and company_type = ${company_type}
                        and type =${type_cost_str}
                        and settlement_method = 2
                  ) b on a.video_id = b.video_id
                      and a.min_date <= b.date
                      and b.date <= date_add(a.min_date, interval 29 day)
                  group by 1, 2, 3, 4
                  union all
                  select order_id
                        , video_id
                        , money_type
                        , case
                             when min_date = '2999-12-31' then '--'
                             else concat(min_date, '--', date_add(a.min_date, interval 29 day)) end as settlement_interval
                        , settlement_date
                        , cost
                        , settlement_money
                  from (
                           select order_id
                                 , video_id
                                 , 'now'                                                                             as money_type
                                 , min(date_format(case when type = ${type_now_str} then date else '2999-12-31' end, '%Y-%m')) as settlement_date
                                 , min(case when type = ${type_cost_str} then date else '2999-12-31' end)                          as min_date
                                 , min(type)                                                                         as type
                                 , sum(0)                                                                            as cost
                                 , sum(case when type =  ${type_now_str} then money else 0 end)                      as settlement_money
                           from makepolo.account_statement state
                                    left join makepolo.material_market_order od on state.order_id = od.id
                           where type in (${type_str})
                             ${where_str}
                             and state.is_outsource = ${ is_outsource}
                             and company_type = ${company_type}
                             and settlement_method = 2
                           group by 1, 2, 3
                       ) a
                  where type = ${type_now_str}
              ) t
         group by 1, 2, 3, 4, 5
     ) t1
         left join makepolo.material_market_order t2 on t1.order_id = t2.id
         left join makepolo.material_market_video t3 on t3.id = t1.video_id
where settlement_date = '${settlement_interval}'
group by 1
 <%
 }else{
 %>
 select replace_video_index
      , max(if(is_replace_video=0,mmv.id,null)) as id
      , max(if(is_replace_video=0,mmv.url,null)) as url 
      , max(if(is_replace_video=0,mmv.cover_image_url,null)) as cover_image_url
      , max(if(is_replace_video=0,mmv.name,null)) as name
      , max(${price}) / max(video_num) as now_price -- 一口价视频单价和结算金额相同
      , sum(money) as money
from makepolo.account_statement state
         left join makepolo.material_market_order od on state.order_id = od.id
         left join makepolo.material_market_video mmv on state.video_id = mmv.id
where type = ${type_now_str}
  and state.is_outsource = ${is_outsource}
  and mmv.is_outsource = 0
  and settlement_method = 1
  and od.status<>8
  and money<>0
  and company_type=${company_type}
  ${where_str}
  and date_format(state.date,'%Y-%m') = '${settlement_interval}'
group by 1
 <%
 }
 %>