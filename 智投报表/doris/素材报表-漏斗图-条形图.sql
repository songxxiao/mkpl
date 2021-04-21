-- {{start_date}}
-- {{end_date}}
-- {{project_id}}
-- {{params_account_id}}
-- {{designer_account_id}}
-- {{vendor_id}}
-- {{vendor_account_id}}
-- {{campaign_id}}
-- {{ad_unit_id}}
-- {{creative_id}}
-- {{video_id}}
-- {{current_role}}
-- {{dim}}
-- {{video_name}}
-- {{director}}
-- {{photographer}}
-- {{editor}}
-- {{category}}
-- {{account_id}}
-- {{company_id}}
-- {{create_source}}
-- {{material_market_creator_id}}
-- {{params_vendor_account_id}}
-- {{bar_chart}}
-- {{video_name}}

<%
where = "";

if(current_role == '2'){
    where =  where + " and video_account_id in ("+account_id+")";
} else{
    if(isNotEmpty(vendor_account_id)){
        where = where + " and cr.vendor_account_id in ("+vendor_account_id+")";
    } else{
        where = where + " and cr.vendor_account_id =-1";
    }
}

if(isNotEmpty(params_vendor_account_id)){
    where = where + " and dims.vendor_account_id in ("+params_vendor_account_id+")";
}

if(!isEmpty(video_name)){
    where = where + " and m_dims.video_name like '%"+video_name+"%'";
}

if(isNotEmpty(company_id)){
    where =  where + " and eva.company_id  in ("+company_id+")";
}

if(isNotEmpty(project_id)){
    where =  where + " and project_id  in ("+project_id+")";
}

if(isNotEmpty(params_account_id)){
    where =  where + " and creative_account_id in ("+params_account_id+")";
}

if(isNotEmpty(designer_account_id)){
    where =  where + " and video_account_id in ("+designer_account_id+")";
}

if(isNotEmpty(vendor_id)){
    where = where + " and ev.vendor_id in ("+vendor_id+")";
}

if(!isEmpty(campaign_id)){
    where = where + " and campaign_id in ("+campaign_id+")";
}

if(!isEmpty(ad_unit_id)){
    where = where + " and ad_unit_id in ("+ad_unit_id+")";
}

if(!isEmpty(creative_id)){
    where = where + " and creative_id in ("+creative_id+")";
}

if(!isEmpty(video_id)){
    where = where + " and local_video_id in ("+video_id+")";
}

if(!isEmpty(create_source)){
    where = where + " and create_source in ("+create_source+")";
}

if(!isEmpty(material_market_creator_id)){
    where = where + " and material_market_creator_id in ("+material_market_creator_id+")";
}

if(!isEmpty(director)){
    where = where + " and local_material_video_director like '%"+director+"%'";
}

if(!isEmpty(photographer)){
    where = where + " and local_material_video_photographer like '%"+photographer+"%'";
}

if(!isEmpty(editor)){
    where = where + " and local_material_video_editor like '%"+editor+"%'";
}

if(!isEmpty(category)){
    where = where + " and local_material_video_material_category_id in ("+category+")";
}
%>
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
select  label,
    case 
     when label = '3秒播放率' then round(sum(play_3s_rate) * 100, 2)  -- 比率改为百分比，但不加%符号
     when label = '5秒播放率' then round(sum(play_5s_rate) * 100, 2)
     when label = '完播率' then round(sum(play_end_rate) * 100, 2)
     when label = '25%播放率' then  round(sum(play_25_rate) * 100, 2)
     when label = '50%播放率' then  round(sum(play_50_rate) * 100, 2)
     when label = '75%播放率' then  round(sum(play_75_rate) * 100, 2)
     when label = '99%播放率' then  round(sum(play_99_rate) * 100, 2)
     when label = '分享数' then sum(share_count)
     when label = '评论数' then sum(comment_count)
     when label = '点赞数' then sum(like_count)
     when label = '新增关注数' then sum(add_follower_count)
     when label = '举报数' then sum(complain_count)
     when label = '拉黑数' then sum(hate_count)
     when label = '减少此类作品数' then sum(negative_count)
    end as value
    
    , case when label = '3秒播放率' then sum(play_3s_count)
    when label = '5秒播放率' then sum(play_5s_count)
    when label = '完播率' then sum(play_end_count)
    when label = '25%播放率' then sum(play_25_feed_break)
    when label = '50%播放率' then sum(play_50_feed_break) 
    when label = '75%播放率' then sum(play_75_feed_break) 
    when label = '99%播放率' then sum(play_99_feed_break)
    end as value_count
from
(
select      if(sum(content_impression)<>0, sum(play_3s_count)/sum(content_impression), 0)  as  play_3s_rate
                , if(sum(content_impression)<>0, sum(play_5s_count)/sum(content_impression), 0)  as  play_5s_rate
                , if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as play_end_rate
  			    , sum(play_3s_count) as play_3s_count
 				, sum(play_5s_count) as play_5s_count
  				, sum(play_end_count) as play_end_count
  
  				, sum(play_25_feed_break) as play_25_feed_break
  				, sum(play_50_feed_break) as play_50_feed_break
  				, sum(play_75_feed_break) as play_75_feed_break
  				, sum(play_100_feed_break) as play_99_feed_break
  
                , if(sum(total_play)<>0, sum(play_25_feed_break)/sum(total_play), 0)  as  play_25_rate
                , if(sum(total_play)<>0, sum(play_50_feed_break)/sum(total_play),0) as play_50_rate
                , if(sum(total_play)<>0, sum(play_75_feed_break)/sum(total_play), 0)  as  play_75_rate
                , if(sum(total_play)<>0, sum(play_100_feed_break)/sum(total_play),0) as play_99_rate
  
  			    , sum(comment_count) as comment_count
  				, sum(share_count) as share_count
  				, sum(like_count) as like_count 
  				, sum(add_follower_count) as add_follower_count
                , sum(complain_count) as complain_count
  				, sum(hate_count) as hate_count
  				, sum(negative_count) as negative_count
         from makepolo.vendor_creative_report cr
				left join makepolo.creative_report_dims dims  
                           on dims.vendor_account_id = cr.vendor_account_id
					      and dims.vendor_creative_id = cr.vendor_creative_id and dims.company_id in (${company_id})
  
               left join makepolo.creative_material_dims m_dims
                       on m_dims.vendor_material_id = cr.photo_id
                        and m_dims.vendor_account_id = cr.vendor_account_id  and m_dims.company_id in (${company_id})
               left join makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
  			   left join makepolo_common.entity_vendor ev on cr.vendor_id = ev.vendor_id
         where date >= '${start_date}'
           and date <= '${end_date}'
          ${where}
       --  group by 1, 2, 3, 4, 5, 6, 7, 8, 9
) a , 
(
  
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2') ? "select '3秒播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2') ? "select '5秒播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2')  ? "select  '完播率' as label  union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '25%播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '50%播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select  '75%播放率' as label  union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select  '99%播放率' as label  union all":" "}
  ${strutil.contain(bar_chart!'2', '1') ? "select  '分享数' as label  union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select  '评论数' as label  union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select  '点赞数' as label  union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select  '新增关注数' as label  union all":" "}  
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '举报数' as label  union all":" "} 
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '拉黑数' as label  union all":" "} 
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '减少此类作品数' as label  union all":" "} 
  select '' as label
) b
where label <> ''
group by 1
