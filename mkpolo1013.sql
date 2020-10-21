/* API消耗问题分析 */


from (select date
             , create_channel
             , sum(cost) as cost
     from  makepolo.creative_report
     group by 1, 2
    ) a




























