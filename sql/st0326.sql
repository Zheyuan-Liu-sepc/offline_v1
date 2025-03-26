
with
    tmp_order as
        (
            select
                user_id,
                sum(oc.total_amount) order_amount,
                count(*)  order_count
            from dwd_order_info  oc
            where date_format(oc.create_time,'yyyy-MM-dd')='2020-04-01'
            group by user_id
        )  ,
    tmp_payment as
        (
            select
                user_id,
                sum(pi.total_amount) payment_amount,
                count(*) payment_count
            from dwd_payment_info pi
            where date_format(pi.payment_time,'yyyy-MM-dd')='2020-04-01'
            group by user_id
        ),
    tmp_comment as
        (
            select
                user_id,
                count(*) comment_count
            from dwd_comment_log c
            where date_format(c.create_time,'yyyy-MM-dd')='2020-04-01'
            group by user_id
        )

insert overwrite table dws_user_action partition(dt='2025-03-25')
select
    user_actions.user_id,
    sum(user_actions.order_count),
    sum(user_actions.order_amount),
    sum(user_actions.payment_count),
    sum(user_actions.payment_amount),
    sum(user_actions.comment_count)
from
    (
        select
            user_id,
            order_count,
            order_amount,
            0 payment_count ,
            0 payment_amount,
            0 comment_count
        from tmp_order
        union all
        select
            user_id,
            0,
            0,
            payment_count,
            payment_amount,
            0
        from tmp_payment
        union all
        select
            user_id,
            0,
            0,
            0,
            0,
            comment_count
        from tmp_comment
    ) user_actions
group by user_id
;


with
    tmp_detail as
        (
            select
                user_id,
                sku_id,
                sum(sku_num) sku_num ,
                count(*) order_count ,
                sum(od.order_price*sku_num)  order_amount
            from ods_order_detail od
            where od.dt='2025-03-25' and user_id is not null
            group by user_id, sku_id
        )
insert overwrite table  dws_sale_detail_daycount partition(dt='2025-03-25')
select
    tmp_detail.user_id,
    tmp_detail.sku_id,
    u.gender,
    months_between('2025-03-25', u.birthday)/12  age,
    u.user_level,
    price,
    sku_name,
    tm_id,
    category3_id ,
    category2_id ,
    category1_id ,
    category3_name ,
    category2_name ,
    category1_name ,
    spu_id,
    tmp_detail.sku_num,
    tmp_detail.order_count,
    tmp_detail.order_amount
from tmp_detail
         left join dwd_user_info u on u.id=tmp_detail.user_id  and u.dt='2025-03-25'
         left join dwd_sku_info s on tmp_detail.sku_id =s.id  and s.dt='2025-03-25'
;


insert into table ads_sale_tm_category1_stat_mn
select
    mn.sku_tm_id,
    mn.sku_category1_id,
    mn.sku_category1_name,
    sum(if(mn.order_count>=1,1,0)) buycount,
    sum(if(mn.order_count>=2,1,0)) buyTwiceLast,
    sum(if(mn.order_count>=2,1,0))/sum( if(mn.order_count>=1,1,0)) buyTwiceLastRatio,
    sum(if(mn.order_count>3,1,0))  buy3timeLast  ,
    sum(if(mn.order_count>=3,1,0))/sum( if(mn.order_count>=1,1,0)) buy3timeLastRatio ,
    date_format('2025-03-25' ,'yyyy-MM') stat_mn,
    '2025-03-25' stat_date
from
    (
        select od.sku_tm_id,
               od.sku_category1_id,
               od.sku_category1_name,
               user_id ,
               sum(order_count) order_count
        from  dws_sale_detail_daycount  od
        where
                date_format(dt,'yyyy-MM')<=date_format('2025-03-25' ,'yyyy-MM')
        group by
            od.sku_tm_id, od.sku_category1_id, user_id, od.sku_category1_name
    ) mn
group by mn.sku_tm_id, mn.sku_category1_id, mn.sku_category1_name
;

insert into table ads_gmv_sum_day
select
    '2025-03-25' dt ,
    sum(order_count)  gmv_count ,
    sum(order_amount) gmv_amount ,
    sum(payment_amount) payment_amount
from dws_user_action
where dt ='2025-03-25'
group by dt
;