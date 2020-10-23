
-- http://easyreport.fancydsp.com/projects/4/queries/868/
select
       video_id as id,
       b.url,
       cover_image_url,
       cost,
       c.price/c.video_num as floor_price,
       0 as now_price,
       c.consume_proportion as proportion, -- 消耗占比
       money as commission, -- 金额                                                           -- status=9 订单确认
       case when c.cancel_order_money>0 then c.cancel_order_money/c.video_num else  case when c.status=9 then c.price/c.video_num else 0 end+money end as money
from         -- cancel_order_money: 撤单赔付金额 status: 订单状态
 (select video_id,
        sum(origin_consume) as cost, -- 原始消耗
        sum(money) as money          -- 金额
 from account_statement state
 where date >= '2020-10-01'
   and date <= '2020-10-22'
    and 1=1
   and type in (7)   -- 订单消耗收益
   and company_type = 2  -- 创作方账户
 group by 1) a
left join material_market_video b on a.video_id = b.id
left join material_market_order c on b.order_id = c.id
union all
select
       c.id,
       c.url,
       cover_image_url,
       cost as cost,
       0 as floor_price,
       b.price/b.video_num as now_price,
       0 as proportion,
       0 as commission,
      case when b.cancel_order_money>0 then b.cancel_order_money/b.video_num else b.price/b.video_num end as money
from
 (select order_id,
        sum(origin_consume) as cost,
        sum(money) as money
 from account_statement state
 where date >= '2020-10-01'
   and date <= '2020-10-22'
    and 1=1
   and type =5                      -- 收益，一口价或底价
   and company_type = 2             -- 创作方账户
 group by 1) a
left join material_market_order b on a.order_id = b.id
 join material_market_video c on b.id = c.order_id
 where b.settlement_method = 1      -- 结算方式 1 = 一口价
 union all
select c.id,
       c.url,
       cover_image_url,
       0 as cost,
       b.price / b.video_num as floor_price, -- 价格/视频数量
       0 as now_price,
       b.consume_proportion  as proportion,
       0 as commission,
       case when b.cancel_order_money>0 then b.cancel_order_money/b.video_num else b.price/b.video_num end as money
from (select order_id
      from account_statement state
      where  date>='2020-10-01'
        and date<='2020-10-22'
        and type = 5 -- 收益，一口价或底价
         and 1=1
        and company_type = 2
      group by 1) a
         left join
     (select order_id
      from account_statement state
      where  date >= '2020-10-01'
        and date <= '2020-10-22'
        and type = 7 -- 订单消耗收益
         and 1=1
        and company_type = 2 -- 底价 + 消耗
      group by 1) d on a.order_id = d.order_id
         left join material_market_order b on a.order_id = b.id
         join material_market_video c on b.id = c.order_id
where b.settlement_method = 2
  and d.order_id is null
 order by 1



 