import warnings, re, json
warnings.filterwarnings('ignore')
import numpy as np
import pandas as pd
from sqlalchemy.engine import create_engine
pd.set_option('display.max_colwidth', 300)

def kuaishou_video_img(company_id, start_time, end_time):
    '''查询快手平台下的视频、封面url'''
    doris_engine = create_engine("mysql+pymysql://wukong:ryAwwsB2q@192.168.28.111:9030/ftx_report?charset=utf8")
    makepolo_engine = create_engine("mysql+pymysql://wukong:ryAwwsB2q@rm-2zei36s193d6h0es6.mysql.rds.aliyuncs.com:3306/makepolo?charset=utf8")
    sql_cmd = '''
    select id as creative_id
            , date
            , 创建渠道
            , vendor_creative_raw
            , cost
    from
    (
    select id
        , date_format(create_time,'%%Y-%%m-%%d') as date
        , if(create_channel=1,'智投api','快手后台') as '创建渠道'
        , vendor_creative_raw
        , description
    from makepolo.ad_creative
    where  company_id = {}
    and material_assemble_type = 4
    and create_time between '{} 00:00:00' and '{} 23:59:59'
    and create_channel <> 1
    and vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003)) a
    left join (select creative_id
            , sum(cost) / 10000 as cost
        from makepolo.creative_report
        group by 1
    ) b on b.creative_id = a.id
    order by cost desc
            '''.format(company_id, start_time, end_time)
    sample_dt = pd.read_sql(sql_cmd, doris_engine)
    sample_dt['vendor_creative_raw'] = sample_dt['vendor_creative_raw'].apply(lambda x: json.loads(x))
    sample_dt['photo_id'] = sample_dt['vendor_creative_raw'].apply(lambda x: x['photo_id'])
    sample_dt['cover_url'] = sample_dt['vendor_creative_raw'].apply(lambda x: x['cover_url'])

    sql_cmd = '''
    select vendor_material_id
            , local_id
    from makepolo.vendor_material
    where company_id = {}
    and create_time  between '{} 00:00:00' and '{} 23:59:59'
    '''.format(company_id, start_time, end_time)
    vendor_dt = pd.read_sql(sql_cmd, makepolo_engine)
    sa_dt = pd.merge(sample_dt, vendor_dt, left_on='photo_id', right_on = 'vendor_material_id', how='inner')

    sql_cmd = '''
    select  id as local_id
        , video_url
            , cover_image
    from makepolo.local_material_video
    where company_id = {}
    and create_time between '{} 00:00:00' and '{} 23:59:59'
    '''.format(company_id, start_time, end_time)
    material_dt = pd.read_sql(sql_cmd, doris_engine)

    final_dt = pd.merge(sa_dt, material_dt, on='local_id', how='inner')
    final_dt.sort_values(['cost'], ascending=False, inplace=True)
    return final_dt

def zhitou_video_img(company_id, start_time, end_time):
    '''查询智投平台下的视频、封面url'''
    doris_engine = create_engine("mysql+pymysql://wukong:ryAwwsB2q@192.168.28.111:9030/ftx_report?charset=utf8")
    sql_cmd = '''
        select date
        , 创建渠道
        , description
        , video_url
        , cover_image
        , image_url
        , cost
    from
    (
    select id
        , date_format(create_time,'%Y-%m-%d') as date
        , if(create_channel=1,'智投api','快手后台') as '创建渠道'
        , vendor_creative_raw
        , description
        , local_video_id as video_id
        , local_image_id as image_id
    from makepolo.ad_creative
    -- where vendor_account_id in (select id as vendor_account_id
    --            from makepolo.entity_vendor_account
    --           where company_id = 137 and subordinate_account_id = 1391)
    where company_id = {}
    and create_time between '{} 00:00:00' and '{} 23:59:59'
    and create_channel = 1
    and vendor_status not in (0, 11, 12, 41, 42, 55, 10001, 10004, 10003)) a
    left join (select creative_id
            , sum(cost) / 10000 as cost
        from makepolo.creative_report
        group by 1
    ) b on b.creative_id = a.id
    left join ( select id
                , video_url
                , cover_image
        from makepolo.local_material_video
        where company_id = 137
       -- and create_time between '2020-11-11 00:00:00' and '2020-11-11 23:59:59'
    ) c on c.id = a.video_id
    left join ( select id
                , image_url
        from makepolo.local_material_image
        where company_id = 137
      --  and create_time between '2020-11-11 00:00:00' and '2020-11-11 23:59:59'
    ) d on d.id = a.image_id
    where cost is not null
    order by cost desc
        '''.format(company_id, start_time, end_time)
















