
-- 根据近 7 天的“引流款”和“热销款”主商品，洞察出与主商品有同时访问、同时收藏加购和同时段支付的 top30 宝贝
CREATE TABLE IF NOT EXISTS ads_product_relation_top30 AS
    WITH recent_7_days_data AS (
        SELECT
        main_item_id,
        related_item_id,
        relation_type,
        total_views,
        total_collect_cart,
        total_pays,
        update_time
        FROM
        dws_product_relation_stat
        WHERE
        update_time >= CURDATE() - INTERVAL 7 DAY
    ),
    top_drainage_products AS (
    SELECT
    main_item_id
    FROM
    recent_7_days_data
    GROUP BY
    main_item_id
    ORDER BY
    SUM(total_views) DESC
    LIMIT 30
    ),
    top_hot_products AS (
    SELECT
    main_item_id
    FROM
    recent_7_days_data
    GROUP BY
    main_item_id
    ORDER BY
    SUM(total_pays) DESC
    LIMIT 30
    ),
    all_top_products AS (
    SELECT main_item_id
    FROM top_drainage_products
    UNION ALL
    SELECT main_item_id
    FROM top_hot_products
                        ),
    related_products AS (
                            SELECT
                            rrd.related_item_id,
                            SUM(rrd.total_views) AS total_views,
    SUM(rrd.total_collect_cart) AS total_collect_cart,
    SUM(rrd.total_pays) AS total_pays
    FROM
    recent_7_days_data rrd
    JOIN
    all_top_products atp ON rrd.main_item_id = atp.main_item_id
    GROUP BY
    rrd.related_item_id
    )
SELECT
    related_item_id,
    total_views,
    total_collect_cart,
    total_pays
FROM
    related_products
ORDER BY
        total_views + total_collect_cart + total_pays DESC
    LIMIT 30;



-- 根据宝贝详情页的引导能力，默认提供 TOP10 引导能力最强宝贝，且可查看对应的关联宝贝明细清单
CREATE TABLE IF NOT EXISTS ads_guide_capacity_top10 AS
    WITH guideability_metrics AS (
        SELECT
        main_item_id,
        related_item_id,
        relation_type,
        total_views,
        total_collect_cart,
        total_pays,
        update_time,
        total_views * 0.2 + total_collect_cart * 0.3 + total_pays * 0.5 AS guideability_score
        FROM
        dws_product_relation_stat
        ),
    top_10_main_items AS (
    SELECT
    main_item_id
    FROM
    guideability_metrics
    GROUP BY
    main_item_id
    ORDER BY
    SUM(guideability_score) DESC
    LIMIT 10
    )
SELECT
    gm.*
FROM
    guideability_metrics gm
        JOIN
    top_10_main_items t10 ON gm.main_item_id = t10.main_item_id
ORDER BY
    gm.main_item_id, gm.guideability_score DESC;
