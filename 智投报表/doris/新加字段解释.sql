           ${array.contain(dimArray,"cost")? ",sum(cr.cost)/10000 as cost" :""} 
           ${array.contain(dimArray,"cost_rebate")? ",sum((cr.cost/10000) / (1 + (eva.return_point/100))) as cost_rebate" :""} 
           ${array.contain(dimArray,"impression")? ",sum(cr.impression) as impression" :""} 
           ${array.contain(dimArray,"click")? ",sum(cr.click) as click" :""}
           ${array.contain(dimArray,"click_rate")? ",if(sum(impression)<>0,sum(click)/sum(impression),0) as click_rate" :""} 
           ${array.contain(dimArray,"content_impression")? ",sum(cr.content_impression) as content_impression" :""}
           ${array.contain(dimArray,"content_click")? ",sum(cr.content_click) as content_click" :""}  
           ${array.contain(dimArray,"content_click_rate")? ",if(sum(content_impression)<>0,sum(content_click)/sum(content_impression),0) as content_click_rate" :""} 
           ${array.contain(dimArray,"impression_cost")? ",if(sum(impression)<>0,sum(cost /10000) / sum(impression/1000),0) as impression_cost" :""}  
           ${array.contain(dimArray,"click_cost")? ",if(sum(click)<>0,sum(cost)/sum(click)/10000,0) as click_cost" :""}   
           ${array.contain(dimArray,"content_click_cost")? ",if(sum(content_click)<>0,sum(cost)/sum(content_click)/10000,0) as content_click_cost" :""} 
           ${array.contain(dimArray,"play_3s_rate")? ",if(sum(content_impression)<>0,sum(play_3s_count)/sum(content_impression),0) as play_3s_rate" :""}  
           ${array.contain(dimArray,"play_5s_rate")? ",if(sum(content_impression)<>0,sum(play_5s_count)/sum(content_impression),0) as play_5s_rate" :""}  
           ${array.contain(dimArray,"play_end_rate")? ",if(sum(content_impression)<>0,sum(play_end_count)/sum(content_impression),0) as play_end_rate" :""}  
           ${array.contain(dimArray,"convert_count")? ",sum(cr.convert_count) as convert_count" :""} 
           ${array.contain(dimArray,"convert_rate")? ",if(sum(cr.click)<>0,sum(cr.convert_count)/sum(cr.click),0) as convert_rate" :""}  
           ${array.contain(dimArray,"convert_cost")? ",if(sum(cr.convert_count)<>0,sum(cr.cost /10000)/sum(cr.convert_count),0) as convert_cost" :""} 
           ${array.contain(dimArray,"deep_convert_count")? ",sum(cr.deep_convert_count) as deep_convert_count" :""} 
           ${array.contain(dimArray,"deep_convert_rate")? ",if(sum(cr.click)<>0,sum(cr.deep_convert_count)/sum(cr.click),0) as deep_convert_rate" :""}
           ${array.contain(dimArray,"deep_convert_cost")? ",if(sum(cr.deep_convert_count)!=0,sum(cr.cost /10000)/sum(cr.deep_convert_count),0) as deep_convert_cost" :""} 
           ${array.contain(dimArray,"app_download_start")? ",sum(cr.app_download_start) as app_download_start" :""}  
           ${array.contain(dimArray,"app_download_complete")? ",sum(cr.app_download_complete) as app_download_complete" :""} 
           ${array.contain(dimArray,"app_activation")? ",sum(cr.app_activation) as app_activation" :""}
           ${array.contain(dimArray,"app_activation_cost")? ",if(sum(app_activation)<>0,sum(cost / 10000)/sum(app_activation),0) as app_activation_cost" :""} 
           ${array.contain(dimArray,"app_activation_rate")? ",if(sum(click)<>0,sum(app_activation)/sum(click),0) as app_activation_rate" :""} 
           ${array.contain(dimArray,"app_register")? ",sum(cr.app_register) as app_register" :""}
           ${array.contain(dimArray,"app_register_cost")? ",if(sum(app_register)<>0,sum(cost /10000)/sum(app_register),0) as app_register_cost" :""}
           ${array.contain(dimArray,"app_register_rate")? ",if(sum(app_activation)<>0,sum(app_register)/sum(app_activation),0) as app_register_rate" :""}
           ${array.contain(dimArray,"app_event_pay_amount")? ",sum(cr.app_event_pay_amount)/10000 as app_event_pay_amount" :""}
           ${array.contain(dimArray,"app_event_next_day_stay_rate")? ",if(sum(next_day_active_count)!=0,sum(app_event_next_day_stay)/sum(next_day_active_count),0) as app_event_next_day_stay_rate" :""}
           ${array.contain(dimArray,"event_pay_first_day")? ",sum(cr.event_pay_first_day) as event_pay_first_day" :""}
           ${array.contain(dimArray,"event_pay_purchase_amount_first_day")? ",sum(cr.event_pay_purchase_amount_first_day)/10000 as event_pay_purchase_amount_first_day" :""} 
           ${array.contain(dimArray,"first_day_roi")? ",if(sum(cr.cost)!=0,sum(cr.event_pay_purchase_amount_first_day)/sum(cr.cost),0) as first_day_roi" :""} 
           ${array.contain(dimArray,"event_pay")? ",sum(cr.event_pay) as event_pay" :""} 
           ${array.contain(dimArray,"event_pay_cost")? ",if(sum(cr.event_pay)!=0,sum(cr.cost /10000 )/sum(cr.event_pay),0) as event_pay_cost" :""} 
           ${array.contain(dimArray,"form_count")? ",sum(cr.form_count) as form_count" :""} 
           ${array.contain(dimArray,"form_count_click_rate")? ",if(sum(cr.content_click)!=0,sum(cr.form_count)/sum(cr.content_click),0) as form_count_click_rate" :""} 
           ${array.contain(dimArray,"form_count_unit_price")? ",if(sum(cr.form_count)!=0,sum(cr.cost /10000)/sum(cr.form_count),0) as form_count_unit_price" :""}
           ${array.contain(dimArray,"total_play")? ",sum(cr.total_play) as total_play" :""} 
           ${array.contain(dimArray,"valid_play")? ",sum(cr.valid_play) as valid_play" :""}
           ${array.contain(dimArray,"valid_play_rate")? ",if(sum(cr.total_play)!=0,sum(cr.valid_play)/sum(cr.total_play),0) as valid_play_rate" :""} 
           ${array.contain(dimArray,"valid_play_cost")? ",if(sum(cr.valid_play)!=0,sum(cr.cost /10000 )/sum(cr.valid_play),0) as valid_play_cost" :""} 
           ${array.contain(dimArray,"play_25_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_25_feed_break) /sum(cr.total_play)) as play_25_rate" :""} 
           ${array.contain(dimArray,"play_50_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_50_feed_break) /sum(cr.total_play))  as play_50_rate" :""} 
           ${array.contain(dimArray,"play_75_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_75_feed_break) /sum(cr.total_play))  as play_75_rate" :""} 
           ${array.contain(dimArray,"play_100_feed_break_rate")? ", if(sum(cr.total_play)=0,'_', sum(cr.play_100_feed_break) /sum(cr.total_play)) as play_100_feed_break_rate" :""} 
           ${array.contain(dimArray,"play_duration_per_play")? ",if(sum(cr.total_play)!=0,sum(cr.play_duration_sum)/sum(cr.total_play),0) as play_duration_per_play" :""}
           ${array.contain(dimArray,"event_new_user_pay  新增付费人数
           ${array.contain(dimArray,"event_new_user_pay_cost  新增付费人数成本
           ${array.contain(dimArray,"event_new_user_pay_ratio  当日行为数
           ${array.contain(dimArray,"event_jin_jian_app  完件数
           ${array.contain(dimArray,"event_jin_jian_app_cost  完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_app  新增完件人数
           ${array.contain(dimArray,"event_new_user_jinjian_app_cost  新增完件人数成本
           ${array.contain(dimArray,"event_new_user_jinjian_app_roi  新增完件人数成率
           ${array.contain(dimArray,"event_credit_grant_app  当日回传授信数
           ${array.contain(dimArray,"event_credit_grant_app_cost  授信成本
           ${array.contain(dimArray,"event_credit_grant_app_ratio  授信率
           ${array.contain(dimArray,"event_new_user_credit_grant_app  新增授信人数
           ${array.contain(dimArray,"event_new_user_credit_grant_app_cost  新增授信人数成本
           ${array.contain(dimArray,"event_new_user_credit_grant_app_roi  新增授信人数率
           ${array.contain(dimArray,"event_order_paid  订单支付数
           ${array.contain(dimArray,"event_order_paid_roi  订单支付率
           ${array.contain(dimArray,"event_order_paid_cost  订单支付成本
           ${array.contain(dimArray,"event_valid_clues  有效线索数
           ${array.contain(dimArray,"event_valid_clues_cost  有效线索成本
           ${array.contain(dimArray,"merchant_reco_fans  涨粉量
           ${array.contain(dimArray,"merchant_reco_fans_cost  涨粉成本
           ${array.contain(dimArray,"event_goods_view  商品访问数
           ${array.contain(dimArray,"event_goods_view_cost  商品访问成本
           ${array.contain(dimArray,"event_jin_jian_landing_page  落地页完件数
           ${array.contain(dimArray,"event_jin_jian_landing_page_cost  落地页完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_page  落地页新增完件数
           ${array.contain(dimArray,"event_new_user_jinjian_page_cost  落地页新增完件成本
           ${array.contain(dimArray,"event_new_user_jinjian_page_roi  落地页新增完件率
           ${array.contain(dimArray,"event_credit_grant_landing_page  落地页授信数
           ${array.contain(dimArray,"event_credit_grant_landing_page_cost  落地页授信成本
           ${array.contain(dimArray,"event_credit_grant_landing_page_ratio  落地页授信率
           ${array.contain(dimArray,"event_new_user_credit_grant_page  落地页新增授信数
           ${array.contain(dimArray,"event_new_user_credit_grant_page_cost  落地页新增授信成本
           ${array.contain(dimArray,"event_new_user_credit_grant_page_roi  落地页新增授信率
           ${array.contain(dimArray,"event_button_click  按钮点击数
           ${array.contain(dimArray,"event_button_click_rate  按钮点击率
           ${array.contain(dimArray,"event_button_click_cost  按钮点击成本
           ${array.contain(dimArray,"event_get_through  智能电话-确认接通数
           ${array.contain(dimArray,"event_get_through_cost  智能电话-确认接通率
           ${array.contain(dimArray,"event_get_through_ratio  智能电话-确认接通成本
           
           
           ${array.contain(dimArray,"event_get_through_ratio")? ",sum(event_get_through) / sum(content_click) as event_get_through_ratio" :""} 