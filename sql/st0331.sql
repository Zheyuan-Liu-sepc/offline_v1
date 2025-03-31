

# 查看店内引流能力最强、销量最高的店内 TOP 单品与店内其他商品的是否有关联关系
-- 步骤 1: 找出引流能力最强、销量最高的 TOP 单品
WITH top_product AS (
  SELECT product_id AS top_pid
  FROM product_sales_record
  GROUP BY product_id
  ORDER BY SUM(sales_volume) DESC
  LIMIT 1
),
user_view_top AS (
  SELECT user_id
  FROM user_behavior_record
  WHERE product_id = (SELECT top_pid FROM top_product)
    AND behavior_type = '浏览'
  GROUP BY user_id
),
user_purchase_after_view AS (
  SELECT uv.user_id, ub.product_id
  FROM user_view_top uv
  JOIN user_behavior_record ub ON uv.user_id = ub.user_id
  WHERE ub.behavior_type = '购买'
    AND ub.behavior_time > (
      SELECT MAX(behavior_time)
      FROM user_behavior_record
      WHERE user_id = uv.user_id
        AND product_id = (SELECT top_pid FROM top_product)
    )
)
SELECT
    product_id,
    COUNT(DISTINCT user_id) AS purchase_count,
    COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(*) FROM user_view_top) AS conversion_rate
FROM user_purchase_after_view
GROUP BY product_id
ORDER BY conversion_rate DESC;



# 根据近 7 天的“引流款”和“热销款”主商品，洞察出与主商品有同时访问、同时收藏加购和同时段支付的 top30 宝贝

-- 步骤1：找出近7天的引流款和热销款主商品
WITH TopProducts AS (
    -- 找出近7天的引流款（按页面浏览量排序）
    (SELECT
        p.product_id,
        p.product_name,
        SUM(pt.page_views) AS total_page_views
    FROM
        product_info p
    JOIN
        product_traffic_data pt ON p.product_id = pt.product_id
    WHERE
        pt.visit_date >= CURDATE() - INTERVAL 7 DAY
    GROUP BY
        p.product_id, p.product_name
    ORDER BY
        total_page_views DESC
    LIMIT 10)
    UNION ALL
    -- 找出近7天的热销款（按销售数量排序）
    (SELECT
        p.product_id,
        p.product_name,
        SUM(ps.sales_volume) AS total_sales_volume
    FROM
        product_info p
    JOIN
        product_sales_record ps ON p.product_id = ps.product_id
    WHERE
        ps.sales_date >= CURDATE() - INTERVAL 7 DAY
    GROUP BY
        p.product_id, p.product_name
    ORDER BY
        total_sales_volume DESC
    LIMIT 10)
),
-- 步骤2：找出与主商品有同时访问的宝贝
ConcurrentVisits AS (
    SELECT
        p1.product_id AS main_product_id,
        p2.product_id AS related_product_id,
        COUNT(DISTINCT pt1.visit_date) AS visit_count
    FROM
        TopProducts tp1
    JOIN
        product_info p1 ON tp1.product_id = p1.product_id
    JOIN
        product_traffic_data pt1 ON p1.product_id = pt1.product_id
    JOIN
        product_traffic_data pt2 ON pt1.visit_date = pt2.visit_date
    JOIN
        product_info p2 ON pt2.product_id = p2.product_id
    WHERE
        p1.product_id != p2.product_id
    GROUP BY
        p1.product_id, p2.product_id
),
-- 步骤3：找出与主商品有同时收藏加购的宝贝
ConcurrentAddToCart AS (
    SELECT
        p1.product_id AS main_product_id,
        p2.product_id AS related_product_id,
        COUNT(DISTINCT ubr1.behavior_time) AS add_to_cart_count
    FROM
        TopProducts tp1
    JOIN
        product_info p1 ON tp1.product_id = p1.product_id
    JOIN
        user_behavior_record ubr1 ON p1.product_id = ubr1.product_id AND ubr1.behavior_type IN ('加购', '收藏')
    JOIN
        user_behavior_record ubr2 ON ubr1.user_id = ubr2.user_id AND ubr1.behavior_time = ubr2.behavior_time
    JOIN
        product_info p2 ON ubr2.product_id = p2.product_id
    WHERE
        p1.product_id != p2.product_id
    GROUP BY
        p1.product_id, p2.product_id
),
-- 步骤4：找出与主商品有同时段支付的宝贝
ConcurrentPayment AS (
    SELECT
        p1.product_id AS main_product_id,
        p2.product_id AS related_product_id,
        COUNT(DISTINCT od1.order_time) AS payment_count
    FROM
        TopProducts tp1
    JOIN
        product_info p1 ON tp1.product_id = p1.product_id
    JOIN
        order_detail od1 ON p1.product_id = od1.product_id
    JOIN
        order_detail od2 ON od1.user_id = od2.user_id AND od1.order_time = od2.order_time
    JOIN
        product_info p2 ON od2.product_id = p2.product_id
    WHERE
        p1.product_id != p2.product_id
    GROUP BY
        p1.product_id, p2.product_id
),
-- 步骤5：合并上述结果并计算综合得分
CombinedResults AS (
    SELECT
        cv.main_product_id,
        cv.related_product_id,
        cv.visit_count,
        cat.add_to_cart_count,
        cp.payment_count,
        (cv.visit_count + cat.add_to_cart_count + cp.payment_count) AS total_score
    FROM
        ConcurrentVisits cv
    JOIN
        ConcurrentAddToCart cat ON cv.main_product_id = cat.main_product_id AND cv.related_product_id = cat.related_product_id
    JOIN
        ConcurrentPayment cp ON cv.main_product_id = cp.main_product_id AND cv.related_product_id = cp.related_product_id
)
-- 步骤6：找出综合得分最高的top30宝贝
SELECT
    p.product_name,
    cr.total_score
FROM
    CombinedResults cr
        JOIN
    product_info p ON cr.related_product_id = p.product_id
ORDER BY
    cr.total_score DESC
    LIMIT 30;
