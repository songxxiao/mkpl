
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
     when label = '3秒播放率' then round(sum(Play_3s_rate) * 100, 2)  -- 比率改为百分比，但不加%符号
     when label = '5秒播放率' then round(sum(Play_5s_rate) * 100, 2)
     when label = '完播率' then round(sum(Play_end_rate) * 100, 2)
     when label = '25%播放率' then  round(sum(Play_25_rate) * 100, 2)
     when label = '50%播放率' then  round(sum(Play_50_rate) * 100, 2)
     when label = '75%播放率' then  round(sum(Play_75_rate) * 100, 2)
     when label = '99%播放率' then  round(sum(Play_99_rate) * 100, 2)
     when label = '分享数' then sum(Share_count)
     when label = '评论数' then sum(Comment_count)
     when label = '点赞数' then sum(Like_count)
     when label = '新增关注数' then sum(Add_follower_count)
     when label = '举报数' then sum(Complain_count)
     when label = '拉黑数' then sum(Hate_count)
     when label = '减少此类作品数' then sum(Negative_count)
    end as value
    
    , case when label = '3秒播放率' then sum(Play_3s_count)
    when label = '5秒播放率' then sum(Play_5s_count)
    when label = '完播率' then sum(Play_end_count)
    when label = '25%播放率' then sum(Play_25_feed_break)
    when label = '50%播放率' then sum(Play_50_feed_break) 
    when label = '75%播放率' then sum(Play_75_feed_break) 
    when label = '99%播放率' then sum(Play_99_feed_break)
    end as value_count
from
(
select        if(sum(content_impression)<>0, sum(play_3s_count)/sum(content_impression), 0) as Play_3s_rate
            , if(sum(content_impression)<>0, sum(play_5s_count)/sum(content_impression), 0) as Play_5s_rate
            , if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as Play_end_rate
  		, sum(play_3s_count) as Play_3s_count
 		, sum(play_5s_count) as Play_5s_count
  		, sum(play_end_count) as Play_end_count
  		, sum(play_25_feed_break) as Play_25_feed_break
  		, sum(play_50_feed_break) as Play_50_feed_break
  		, sum(play_75_feed_break) as Play_75_feed_break
  		, sum(play_100_feed_break) as Play_99_feed_break
            , if(sum(total_play)<>0, sum(play_25_feed_break)/sum(total_play), 0) as Play_25_rate
            , if(sum(total_play)<>0, sum(play_50_feed_break)/sum(total_play),0)  as Play_50_rate
            , if(sum(total_play)<>0, sum(play_75_feed_break)/sum(total_play), 0) as Play_75_rate
            , if(sum(total_play)<>0, sum(play_100_feed_break)/sum(total_play),0) as Play_99_rate
  		, sum(comment_count) as Comment_count
  		, sum(share_count) as Share_count
  		, sum(like_count) as Like_count 
  		, sum(add_follower_count) as Add_follower_count
            , sum(complain_count) as Complain_count
  		, sum(hate_count) as Hate_count
  		, sum(negative_count) as Negative_count
         from makepolo.vendor_creative_report cr
         <%if(isNotEmpty(project_id)) {%>
         left join
         (
             select vendor_account_id
                 ,  vendor_creative_id
                 ,  project_id
             from makepolo.creative_report_dims_local 
             where 1=1 
             ${current_role!='2' && isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
             ${isNotEmpty(params_vendor_account_id) ? "and vendor_account_id in (" + params_vendor_account_id + ")" : ""}
             ${isNotEmpty(company_id)? "and company_id in (" + company_id + ")" : ""}
             ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
         ) dims 
         on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
         <%}%>
      left join
      (
          select vendor_material_id
              , vendor_account_id
              , local_video_id,  video_name, create_source, video_url
              , material_market_creator_id, local_material_video_director
              , local_material_video_photographer, local_material_video_editor
              , local_material_video_material_category_id, video_account_id
          from makepolo.creative_material_dims_local 
          where 1=1 
          ${current_role!='2' && isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : "and video_account_id in ("+account_id+")"}
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
          ${isNotEmpty(video_id) ? "and local_video_id in (" + video_id + ")" : ""}
          ${isNotEmpty(video_name)? "and video_name like '%" + video_name + "%'" : ""}
          ${isNotEmpty(create_source)? "and create_source in (" + create_source + ")" : ""}
          ${isNotEmpty(material_market_creator_id)? "and material_market_creator_id in (" + material_market_creator_id + ")" : ""}
          ${isNotEmpty(director)? "and local_material_video_director like '%" + director + "%'" : ""}
          ${isNotEmpty(photographer)? "and local_material_video_photographer like '%" + photographer + "%'" : ""}
          ${isNotEmpty(editor)? "and local_material_video_editor like '%" + editor + "%'" : ""}
          ${isNotEmpty(category)? "and local_material_video_material_category_id in (" + category + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id 
      left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
      where  cr.date < today() - 1 -- 两天前数据不使用final
        and cr.date >= '${start_date}' and cr.date <= '${end_date}' and cr.vendor_creative_id <> '0' -- and cr.video_account_id <> '0' and cr.video_account_id is not null and cr.vendor_creative_id <> '0'
          ${current_role == '2' ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}  
          ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}    
          ${isNotEmpty(params_vendor_account_id) ? "and cr.vendor_account_id in (" + params_vendor_account_id + ")" : ""}
          ${isNotEmpty(designer_account_id) ? "and m_dims.video_account_id in (" + designer_account_id + ")" : ""}
          ${isNotEmpty(video_id) ? "and m_dims.local_video_id in (" + video_id + ")" : ""}
          ${isNotEmpty(video_name)? "and m_dims.video_name like '%" + video_name + "%'" : ""}
          ${isNotEmpty(create_source)? "and m_dims.create_source in (" + create_source + ")" : ""}
          ${isNotEmpty(material_market_creator_id)? "and m_dims.material_market_creator_id in (" + material_market_creator_id + ")" : ""}
          ${isNotEmpty(director)? "and m_dims.local_material_video_director like '%" + director + "%'" : ""}
          ${isNotEmpty(photographer)? "and m_dims.local_material_video_photographer like '%" + photographer + "%'" : ""}
          ${isNotEmpty(editor)? "and m_dims.local_material_video_editor like '%" + editor + "%'" : ""}
          ${isNotEmpty(category)? "and m_dims.local_material_video_material_category_id in (" + category + ")" : ""}
          ${isNotEmpty(params_account_id) ? "and eva.subordinate_account_id in (" + params_account_id + ")" : ""}
      union all

      select  if(sum(content_impression)<>0, sum(play_3s_count)/sum(content_impression), 0) as Play_3s_rate
            , if(sum(content_impression)<>0, sum(play_5s_count)/sum(content_impression), 0) as Play_5s_rate
            , if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as Play_end_rate
  		, sum(play_3s_count) as Play_3s_count
 		, sum(play_5s_count) as Play_5s_count
  		, sum(play_end_count) as Play_end_count
  		, sum(play_25_feed_break) as Play_25_feed_break
  		, sum(play_50_feed_break) as Play_50_feed_break
  		, sum(play_75_feed_break) as Play_75_feed_break
  		, sum(play_100_feed_break) as Play_99_feed_break
            , if(sum(total_play)<>0, sum(play_25_feed_break)/sum(total_play), 0) as Play_25_rate
            , if(sum(total_play)<>0, sum(play_50_feed_break)/sum(total_play),0)  as Play_50_rate
            , if(sum(total_play)<>0, sum(play_75_feed_break)/sum(total_play), 0) as Play_75_rate
            , if(sum(total_play)<>0, sum(play_100_feed_break)/sum(total_play),0) as Play_99_rate
  		, sum(comment_count) as Comment_count
  		, sum(share_count) as Share_count
  		, sum(like_count) as Like_count 
  		, sum(add_follower_count) as Add_follower_count
            , sum(complain_count) as Complain_count
  		, sum(hate_count) as Hate_count
  		, sum(negative_count) as Negative_count
         from makepolo.vendor_creative_report cr final
         <%if(isNotEmpty(project_id)) {%>
         left join
         (
             select vendor_account_id
                 ,  vendor_creative_id
                 ,  project_id
             from makepolo.creative_report_dims_local 
             where 1=1 
             ${current_role!='2' && isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
             ${isNotEmpty(params_vendor_account_id) ? "and vendor_account_id in (" + params_vendor_account_id + ")" : ""}
             ${isNotEmpty(company_id)? "and company_id in (" + company_id + ")" : ""}
             ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
         ) dims 
         on cr.vendor_account_id = dims.vendor_account_id and cr.vendor_creative_id = dims.vendor_creative_id
         <%}%>
      left join
      (
          select vendor_material_id
              , vendor_account_id
              , local_video_id,  video_name, create_source, video_url
              , material_market_creator_id, local_material_video_director
              , local_material_video_photographer, local_material_video_editor
              , local_material_video_material_category_id, video_account_id
          from makepolo.creative_material_dims_local 
          where 1=1 
          ${current_role!='2' && isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : "and video_account_id in ("+account_id+")"}
          ${isNotEmpty(designer_account_id) ? "and video_account_id in (" + designer_account_id + ")" : ""}
          ${isNotEmpty(video_id) ? "and local_video_id in (" + video_id + ")" : ""}
          ${isNotEmpty(video_name)? "and video_name like '%" + video_name + "%'" : ""}
          ${isNotEmpty(create_source)? "and create_source in (" + create_source + ")" : ""}
          ${isNotEmpty(material_market_creator_id)? "and material_market_creator_id in (" + material_market_creator_id + ")" : ""}
          ${isNotEmpty(director)? "and local_material_video_director like '%" + director + "%'" : ""}
          ${isNotEmpty(photographer)? "and local_material_video_photographer like '%" + photographer + "%'" : ""}
          ${isNotEmpty(editor)? "and local_material_video_editor like '%" + editor + "%'" : ""}
          ${isNotEmpty(category)? "and local_material_video_material_category_id in (" + category + ")" : ""}
      ) m_dims 
      on m_dims.vendor_material_id = cr.photo_id and m_dims.vendor_account_id = cr.vendor_account_id 
      left join  makepolo.entity_vendor_account eva on eva.id=cr.vendor_account_id
      where  cr.date >= today() - 1
        and cr.date >= '${start_date}' and cr.date <= '${end_date}' and cr.vendor_creative_id <> '0' -- and cr.video_account_id <> '0' and cr.video_account_id is not null and cr.vendor_creative_id <> '0'
          ${current_role == '2' ? "and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
          ${isNotEmpty(vendor_id) ? "and cr.vendor_id in (" + vendor_id + ")" : ""}
          ${isNotEmpty(project_id) ? "and dims.project_id in (" + project_id + ")" : ""}  
          ${isNotEmpty(company_id) ? "and eva.company_id in (" + company_id + ")" : ""}    
          ${isNotEmpty(params_vendor_account_id) ? "and cr.vendor_account_id in (" + params_vendor_account_id + ")" : ""}
          ${isNotEmpty(designer_account_id) ? "and m_dims.video_account_id in (" + designer_account_id + ")" : ""}
          ${isNotEmpty(video_id) ? "and m_dims.local_video_id in (" + video_id + ")" : ""}
          ${isNotEmpty(video_name)? "and m_dims.video_name like '%" + video_name + "%'" : ""}
          ${isNotEmpty(create_source)? "and m_dims.create_source in (" + create_source + ")" : ""}
          ${isNotEmpty(material_market_creator_id)? "and m_dims.material_market_creator_id in (" + material_market_creator_id + ")" : ""}
          ${isNotEmpty(director)? "and m_dims.local_material_video_director like '%" + director + "%'" : ""}
          ${isNotEmpty(photographer)? "and m_dims.local_material_video_photographer like '%" + photographer + "%'" : ""}
          ${isNotEmpty(editor)? "and m_dims.local_material_video_editor like '%" + editor + "%'" : ""}
          ${isNotEmpty(category)? "and m_dims.local_material_video_material_category_id in (" + category + ")" : ""}
          ${isNotEmpty(params_account_id) ? "and eva.subordinate_account_id in (" + params_account_id + ")" : ""}
) a , 
(
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2') ? "select '3秒播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2') ? "select '5秒播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '2') ? "select '完播率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '25%播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '50%播放率' as label union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '75%播放率' as label  union all":" "}
  ${strutil.contain(vendor_id!'1', '2') && strutil.contain(bar_chart!'2', '2') ? "select '99%播放率' as label  union all":" "}
  ${strutil.contain(bar_chart!'2', '1') ? "select '分享数' as label union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select '评论数' as label union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select '点赞数' as label union all":" "} 
  ${strutil.contain(bar_chart!'2', '1') ? "select '新增关注数' as label union all":" "}  
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '举报数' as label  union all":" "} 
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '拉黑数' as label  union all":" "} 
  ${strutil.contain(vendor_id!'1', '1') && strutil.contain(bar_chart!'2', '1') ? "select  '减少此类作品数' as label  union all":" "} 
  select '' as label
) b
where label <> ''
group by label
