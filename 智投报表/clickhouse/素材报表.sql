-- {{start_date}}
-- {{end_date}}
-- {{project_id}}
-- {{params_account_id}}
-- {{designer_account_id}}
-- {{vendor_id}}
-- {{vendor_account_id}}
-- {{video_id}}
-- {{current_role}}
-- {{account_id}}
-- {{company_id}}
-- {{create_source}}
-- {{material_market_creator_id}}
-- {{params_vendor_account_id}}
-- {{video_name}}
-- {{director}}
-- {{photographer}}
-- {{editor}}
-- {{category}}

select Video_url as video_url
    , max(Video_name) as video_name
    , if(Video_url='未知', '未知',max(ev.name))   as vendor
    ${isNotEmpty(project_id) ? ", if(Video_url='未知', '未知', max(pro.name)) as project" : ""}
    , if(Video_url='未知', '未知', max(vau.name)) as  video_designer
    , if(Video_url='未知', '未知', max(au.name)) as optimizer
    , if(Video_url='未知', '未知', max(mcau.name)) as  creator_crew
    , sum(Cost)/10000 as cost  
    , sum(Cost_rebate)/10000 as cost_rebate  
    , sum(Impression) as impression  
    , sum(Click) as click  
    , if(sum(Impression)<>0, sum(Cost / 10000) /  sum(Impression / 1000) , 0) as impression_cost  
    , if(sum(Click)<>0,sum(Cost / 10000) /sum(Click) ,0) as click_cost  
    , if(sum(Content_impression)<>0,sum(Play_3s_count)/ sum(Content_impression),0) as play_3s_rate  
    , if(sum(Content_impression)<>0,sum(Play_5s_count)/ sum(Content_impression),0) as play_5s_rate  
    , if(sum(Content_impression)<>0,sum(Play_end_count)/sum(Content_impression),0) as play_end_rate  
    , if(sum(Total_play)<>0,sum(Play_25_feed_break)/ sum(Total_play),0) as play_25_rate  
    , if(sum(Total_play)<>0,sum(Play_50_feed_break)/ sum(Total_play),0) as play_50_rate  
    , if(sum(Total_play)<>0,sum(Play_75_feed_break)/ sum(Total_play),0) as play_75_rate  
    , if(sum(Total_play)<>0,sum(Play_100_feed_break)/sum(Total_play),0) as play_99_rate  
    , if(sum(Impression)<>0,sum(Click)/sum(Impression),0) as click_rate  
    , sum(Content_impression) as content_impression  
    , sum(Content_click) as content_click  
    , if(sum(Content_impression)!=0,sum(Content_click)/sum(Content_impression),0) as content_click_rate  
    , if(sum(Content_click)<>0,sum(Cost)/sum(Content_click)/10000,0) as content_click_cost  
    , sum(App_download_start) as app_download_start  
    , sum(App_download_complete) as app_download_complete  
    , sum(App_activation) as app_activation  
    , if(sum(App_activation)!=0,sum(Cost)/sum(App_activation)/10000,0) as app_activation_cost  
    , if(sum(Click)!=0,sum(App_activation)/sum(Click),0) as app_activation_rate  
    , sum(App_register) as app_register  
    , if(sum(App_register)!=0,sum(Cost)/sum(App_register)/10000,0) as app_register_cost  
    , if(sum(App_activation)!=0,sum(App_register)/sum(App_activation),0) as app_register_rate  
    , sum(App_event_pay_amount/10000) as app_event_pay_amount  
    , if(sum(Next_day_active_count)!=0,sum(App_event_next_day_stay)/sum(Next_day_active_count),0) as app_event_next_day_stay_rate  
    , sum(Event_pay_first_day) as event_pay_first_day  
    , sum(Event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day  
    , if(sum(Cost)<>0,sum(Event_pay_purchase_amount_first_day)/sum(Cost),0) as first_day_roi  
    , sum(Event_pay) as event_pay  
    , if(sum(Event_pay)!=0,sum(Cost /10000)/sum(Event_pay),0) as event_pay_cost  
    , sum(Form_count) as form_count  
    , if(sum(Form_count)!=0,sum(Cost)/sum(Form_count)/10000,0) as form_count_unit_price  
    , if(sum(Content_click)!=0,sum(Form_count)/sum(Content_click),0) as form_count_click_rate  
    , sum(Share_count) as share_count  
    , sum(Comment_count) as comment_count  
    , sum(Like_count) as like_count  
    , sum(Add_follower_count) as add_follower_count  
    , sum(Complain_count) as complain_count  
    , sum(Hate_count) as hate_count  
    , sum(Negative_count) as negative_count  
    , sum(Convert_count) as convert_count  
    , if(sum(Click)=0, 0, sum(Convert_count)/sum(Click)) as convert_rate  
    , if(sum(Convert_count)=0, 0,sum(Cost /10000)/sum(Convert_count)) as convert_cost  
    , sum(Deep_convert_count) as deep_convert_count  
    , if(sum(Click)=0, 0,sum(Deep_convert_count)/sum(Click)) as deep_convert_rate  
    , if(sum(Deep_convert_count)=0, 0,sum(Cost /10000)/sum(Deep_convert_count)) as deep_convert_cost  
    , if(sum(Total_play)=0, 0,sum(Play_duration_sum)/sum(Total_play)) as play_duration_per_play  
    , if(sum(Total_play)=0, 0,sum(Wifi_play)/sum(Total_play)) as wifi_play_rate  
    , sum(Total_play) as total_play  
    , sum(Valid_play) as valid_play  
    , if(sum(Total_play)=0, 0,sum(Valid_play)/sum(Total_play)) as valid_play_rate 
    , if(sum(Valid_play)=0, 0,sum(Cost / 10000)/sum(Valid_play)) as valid_play_cost 
    , sum(Cost) /10000 as cost1
    , sum(Impression) as impression1
    , sum(Click) as click1
    , sum(Content_impression) as content_impression1
    , sum(Play_3s_count) as play_3s_count1
    , sum(Play_5s_count) as play_5s_count1
    , sum(Play_end_count) as play_end_count1
    , sum(App_event_next_day_stay) as app_event_next_day_stay1
    , sum(Content_click) as content_click1
    , sum(App_activation) as app_activation1
    , sum(Next_day_active_count) as next_day_active_count1
    , sum(App_register) as app_register1
    , sum(App_event_next_day_stay) as app_event_next_day_stay1
    , sum(Event_pay_purchase_amount_first_day) as event_pay_purchase_amount_first_day1
    , sum(Event_pay) as event_pay1
    , sum(Form_count) as form_count1
    , sum(Play_25_feed_break) as play_25_feed_break1
    , sum(Play_50_feed_break) as play_50_feed_break1
    , sum(Play_75_feed_break) as play_75_feed_break1
    , sum(Play_100_feed_break) as play_99_feed_break1
    , sum(Total_play) as total_play1
    , sum(Valid_play) as valid_play1
    , sum(Convert_count) as convert_count1
    , sum(Deep_convert_count) as deep_convert_count1
    , sum(Play_duration_sum) as play_duration_sum1
    , sum(Wifi_play) as wifi_play1
from (
      select date
       , Company_id
       , Vendor_id
       , Video_account_id
       , Subordinate_account_id
       , if(toUInt8(Video_url='' or Video_url is null), '未知' , Video_url) Video_url
       , if(toUInt8(Video_name='' or Video_name is null), '未知' , Video_name) Video_name
       , Material_market_creator_id
       , Vendor_account_id
       ${isNotEmpty(project_id) ? ", Project_id" : ""}
       , sum(cost)                                as Cost
       , sum(cost / (1+ (return_point / 100)))    as Cost_rebate
       , sum(impression)                          as Impression
       , sum(click)                               as Click
       , sum(content_impression)                  as Content_impression
       , sum(content_click)                       as Content_click
       , sum(app_download_start)                  as App_download_start
       , sum(app_download_complete)               as App_download_complete
       , sum(app_activation)                      as App_activation
       , sum(next_day_active_count)               as Next_day_active_count
       , sum(app_register)                        as App_register
       , sum(app_event_pay)                       as App_event_pay
       , sum(app_event_pay_amount)                as App_event_pay_amount
       , sum(app_event_next_day_stay)             as App_event_next_day_stay
       , sum(event_pay_first_day)                 as Event_pay_first_day
       , sum(event_pay_purchase_amount_first_day) as Event_pay_purchase_amount_first_day
       , sum(event_pay)                           as Event_pay
       , sum(form_count)                          as Form_count
       , sum(play_3s_count)                       as Play_3s_count
       , sum(play_5s_count)                       as Play_5s_count
       , sum(play_end_count)                      as Play_end_count
       , sum(play_25_feed_break) as Play_25_feed_break
       , sum(play_50_feed_break) as Play_50_feed_break
       , sum(play_75_feed_break) as Play_75_feed_break
       , sum(play_100_feed_break) as Play_100_feed_break
       , sum(total_play) as Total_play
       , sum(valid_play) as Valid_play
       , sum(share_count) as Share_count
       , sum(comment_count) as Comment_count
       , sum(like_count) as Like_count
       , sum(hate_count) as Hate_count
       , sum(add_follower_count) as Add_follower_count
       , sum(complain_count) as Complain_count
       , sum(negative_count) as Negative_count
       , sum(convert_count) as Convert_count
       , sum(deep_convert_count) as Deep_convert_count
       , sum(play_duration_sum) as Play_duration_sum
       , sum(wifi_play) as Wifi_play
from (
      select date
          , eva.company_id as Company_id
          , cr.vendor_id as Vendor_id
          , m_dims.video_account_id as Video_account_id
          , eva.subordinate_account_id as Subordinate_account_id
          , m_dims.video_url as Video_url
          , m_dims.video_name as Video_name
          , m_dims.material_market_creator_id as Material_market_creator_id
          , eva.id as Vendor_account_id
          ${isNotEmpty(project_id) ? ", dims.project_id as Project_id" : ""}
          , cost ,impression ,click ,content_impression , content_click
          , app_download_start , app_download_complete, app_activation
          , next_day_active_count, app_register, app_event_pay, app_event_pay_amount
          , app_event_next_day_stay, event_pay_first_day, event_pay_purchase_amount_first_day
          , event_pay, form_count, play_3s_count, play_5s_count, play_end_count
          , play_25_feed_break, play_50_feed_break, play_75_feed_break
          , play_100_feed_break, total_play, valid_play, share_count, comment_count 
          , like_count, hate_count, add_follower_count, complain_count
          , negative_count , convert_count, deep_convert_count, play_duration_sum, wifi_play
          , ifNull(eva.return_point, 0) as return_point
      from makepolo.vendor_creative_report cr 
      <%if(isNotEmpty(project_id)) {%>
      left join
      (
          select vendor_account_id
              ,  vendor_creative_id
              ,  project_id
          from makepolo.creative_report_dims_local 
          where 1=1 
          $current_role!='2' {isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
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
        and cr.date >= '${start_date}' and cr.date <= '${end_date}'
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
      union all
      
      select date
          , eva.company_id as Company_id
          , cr.vendor_id as Vendor_id
          , m_dims.video_account_id as Video_account_id
          , eva.subordinate_account_id as Subordinate_account_id
          , m_dims.video_url as Video_url
          , m_dims.video_name as Video_name
          , m_dims.material_market_creator_id as Material_market_creator_id
          , eva.id as Vendor_account_id
          ${isNotEmpty(project_id) ? ", dims.project_id as project_id" : ""}
          , cost ,impression ,click ,content_impression , content_click
          , app_download_start , app_download_complete, app_activation
          , next_day_active_count, app_register, app_event_pay, app_event_pay_amount
          , app_event_next_day_stay, event_pay_first_day, event_pay_purchase_amount_first_day
          , event_pay, form_count, play_3s_count, play_5s_count, play_end_count
          , play_25_feed_break, play_50_feed_break, play_75_feed_break
          , play_100_feed_break, total_play, valid_play, share_count, comment_count 
          , like_count, hate_count, add_follower_count, complain_count
          , negative_count , convert_count, deep_convert_count, play_duration_sum, wifi_play
          , ifNull(eva.return_point, 0) as return_point
      from makepolo.vendor_creative_report cr final
      <%if(isNotEmpty(project_id)) {%>
      left join
      (
          select vendor_account_id
              ,  vendor_creative_id
              ,  project_id
          from makepolo.creative_report_dims_local 
          where 1=1 
          $current_role!='2' {isNotEmpty(vendor_account_id) ? "and vendor_account_id in (" + vendor_account_id + ")" : ""}
          ${isNotEmpty(params_vendor_account_id) ? "and vendor_account_id in (" + params_vendor_account_id + ")" : ""}
          ${isNotEmpty(company_id)? "and company_id in (" + company_id + ")" : ""}
          ${isNotEmpty(project_id)? "and project_id in (" + project_id + ")" : ""}
      )dims 
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
      where  cr.date >= today()-1 
        and cr.date >= '${start_date}' and cr.date <= '${end_date}'
          ${current_role == '2' ? " and video_account_id in ("+account_id+")": isNotEmpty(vendor_account_id) ? "and cr.vendor_account_id in ("+vendor_account_id+")" : "and cr.vendor_account_id =-1" }
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
    ) cr group by date, Company_id, Vendor_id, Video_account_id, Subordinate_account_id, Video_url, Video_name, Material_market_creator_id, Vendor_account_id ${isNotEmpty(project_id)? ", Project_id" : ""}
) cr
         left join tidb_makepolo_common.vendor ev on cr.Vendor_id = ev.vendor_id
         ${isNotEmpty(project_id) ? "left join makepolo.project pro on toInt64(cr.Project_id) = toInt64(pro.id)" : ""}
         left join tidb_makepolo_common.account_user au on cr.Subordinate_account_id = au.id
         left join tidb_makepolo_common.account_user vau on cr.Video_account_id = vau.id
         left join tidb_makepolo_common.account_admin mcau on toInt64(cr.Material_market_creator_id) = toInt64(mcau.id)
group by video_url

