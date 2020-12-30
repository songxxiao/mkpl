/*-- ---------------------------
创建中间表的sql语句
-------------------------------*/


-- 实验
create table mkpl_creative_test
(
    dat              varchar(255) null comment '创建日期',
    vendor_id        int          null comment '媒体',
    company_id       int          null comment '客户id',
    ctv_cnt          int          null comment '创意数',
    ad_cnt           int          null comment '广告数',
    ctv_cnt_api      int          null comment '通过api创建创意数',
    pass_cnt_api     int          null comment '通过api过审创意数',
    pass_cnt_api_div int          null comment '通过api过审创意数(分母)',
    pass_cnt         int          null comment '过审创意数',
    pass_cnt_div     int          null comment '过审创意数(分母)',
    ad_fail_cnt      int          null comment '同步失败广告数',
    ctv_fail_cnt     int          null comment '同步失败创意数'
)
    comment 'makepolo新建创意数查询-测试'
    charset = utf8mb4;

create index idx_date
    on mkpl_creative_test (dat);








































