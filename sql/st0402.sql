
-- 最近上新商品表
CREATE TABLE ads_new_product_daily (
                                       product_id          VARCHAR(64),
                                       product_name        VARCHAR(255),
                                       main_image_url      VARCHAR(512),
                                       total_pay_amount    DECIMAL(18,2),
                                       update_date         DATE,
                                       update_timestamp    INT,
                                       PRIMARY KEY (product_id, update_timestamp)
);

-- 插入数据到 ads_new_product_daily 表
INSERT INTO ads_new_product_daily (
    product_id,
    product_name,
    main_image_url,
    total_pay_amount,
    update_date,
    update_timestamp
)
SELECT
    npi.product_id,
    npi.product_name,
    npi.main_image_url,
    SUM(CASE WHEN td.refund_flag = 0 THEN td.pay_amount ELSE 0 END) AS total_pay_amount,
    DATE(td.pay_time) AS update_date,
    UNIX_TIMESTAMP(DATE(td.pay_time)) AS update_timestamp
FROM
    dws_new_product_info npi
    JOIN
    dws_transaction_detail td ON npi.product_id = td.product_id
WHERE
    td.pay_time >= DATE_SUB('2025-04-02', INTERVAL 30 DAY)
GROUP BY
    npi.product_id,
    npi.product_name,
    npi.main_image_url,
    DATE(td.pay_time),
    UNIX_TIMESTAMP(DATE(td.pay_time));

select *
from ads_new_product_daily
where total_pay_amount != 0;

-- 新品监控表
CREATE TABLE ads_new_product_monitor (
                                         monitor_date        DATE,
                                         product_count       INTEGER,
                                         total_pay_amount    DECIMAL(18,2),
                                         avg_pay_amount      DECIMAL(18,2),
                                         category_id         INTEGER,
                                         period_type         VARCHAR(10) NOT NULL
);

-- 插入每日监控数据
INSERT INTO ads_new_product_monitor (
    monitor_date,
    product_count,
    total_pay_amount,
    avg_pay_amount,
    category_id,
    period_type
)
SELECT
    DATE(td.pay_time) AS monitor_date,
    COUNT(DISTINCT npi.product_id) AS product_count,
    SUM(CASE WHEN td.refund_flag = 0 THEN td.pay_amount ELSE 0 END) AS total_pay_amount,
    AVG(CASE WHEN td.refund_flag = 0 THEN td.pay_amount ELSE 0 END) AS avg_pay_amount,
    npi.category_id,
    'day' AS period_type
FROM
    dws_new_product_info npi
    JOIN
    dws_transaction_detail td ON npi.product_id = td.product_id
GROUP BY
    DATE(td.pay_time),
    npi.category_id;
