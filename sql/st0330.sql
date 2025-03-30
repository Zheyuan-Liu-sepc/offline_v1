create database if not exists sales_06_v1;
use sales_06_v1;
-- 创建产品信息表
CREATE TABLE product_info (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    listing_date DATE NOT NULL,
    original_price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL,
    supplier VARCHAR(255) NOT NULL,
    shelf_life INT NOT NULL,
    stock_warning_threshold INT NOT NULL
);

-- 创建销售记录表
CREATE TABLE sales_record (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    sales_date DATE NOT NULL,
    sales_quantity INT NOT NULL,
    sales_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    sales_channel ENUM('online', 'offline') NOT NULL,
    promotion_activity_id INT,
    FOREIGN KEY (product_id) REFERENCES product_info(product_id),
    FOREIGN KEY (promotion_activity_id) REFERENCES promotion_activity(activity_id)
);

-- 创建库存表
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock_quantity INT NOT NULL,
    stock_location VARCHAR(255) NOT NULL,
    in_date DATE NOT NULL,
    out_date DATE,
    replenishment_cycle INT NOT NULL,
    supplier_name VARCHAR(255) NOT NULL,
    stock_status ENUM('normal', 'slow_moving', 'near_expiry') NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);

-- 创建客户反馈表
CREATE TABLE customer_feedback (
    product_id INT NOT NULL,
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    review_content TEXT,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    feedback_date DATE NOT NULL,
    feedback_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);

-- 创建促销活动表
CREATE TABLE promotion_activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    activity_name VARCHAR(255) NOT NULL,
    activity_type ENUM('full_reduction', 'discount', 'gift') NOT NULL,
    activity_time VARCHAR(255) NOT NULL,
    applicable_product_ids TEXT NOT NULL,
    budget DECIMAL(10, 2) NOT NULL,
    actual_cost DECIMAL(10, 2) NOT NULL,
    participant_count INT NOT NULL
);

-- 创建退货记录表
CREATE TABLE return_record (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL,
    return_reason VARCHAR(255) NOT NULL,
    processing_status ENUM('processed', 'unprocessed') NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);

-- 创建市场趋势表
CREATE TABLE market_trend (
    date DATE PRIMARY KEY,
    industry_keyword_search_volume INT NOT NULL,
    competitor_sales_volume INT NOT NULL,
    consumer_preference_keyword VARCHAR(100) NOT NULL,
    market_price_index DECIMAL(5, 2) NOT NULL
);

-- 创建竞品对比表
CREATE TABLE competitor_comparison (
    competitor_name VARCHAR(255) PRIMARY KEY,
    price DECIMAL(10, 2) NOT NULL,
    sales_volume INT NOT NULL,
    promotion_strategy VARCHAR(255) NOT NULL,
    user_review_keywords VARCHAR(255) NOT NULL,
    market_share DECIMAL(5, 2) NOT NULL
);

-- 创建销售趋势分析表
CREATE TABLE sales_trend_analysis (
    time_dimension VARCHAR(10) NOT NULL,
    product_id INT NOT NULL,
    cumulative_sales_volume INT NOT NULL,
    sales_amount_monthly_growth_rate DECIMAL(5, 2),
    gross_profit_margin DECIMAL(5, 2),
    inventory_turnover_rate DECIMAL(5, 2),
    PRIMARY KEY (time_dimension, product_id),
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);

-- 创建地域 / 门店分析表
CREATE TABLE region_store_analysis (
    store_id INT PRIMARY KEY AUTO_INCREMENT,
    region VARCHAR(100) NOT NULL,
    product_id INT NOT NULL,
    sales_volume INT NOT NULL,
    customer_profile VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);



-- 创建数据库
CREATE DATABASE IF NOT EXISTS sales_analysis;

-- 使用数据库
USE sales_analysis;

-- 创建商品销售记录表
CREATE TABLE IF NOT EXISTS product_sales_record (
    product_id INT,
    sales_date DATE,
    sales_volume INT,
    sales_amount DECIMAL(10, 2),
    inventory_status VARCHAR(50),
    PRIMARY KEY (product_id, sales_date)
);

-- 创建商品流量数据表
CREATE TABLE IF NOT EXISTS product_traffic_data (
    product_id INT,
    visit_date DATE,
    page_views INT,
    click_volume INT,
    visit_duration INT,
    PRIMARY KEY (product_id, visit_date)
);

-- 创建订单明细表
CREATE TABLE IF NOT EXISTS order_detail (
    order_id INT,
    product_id INT,
    purchase_quantity INT,
    order_time DATETIME,
    user_id INT,
    PRIMARY KEY (order_id, product_id)
);

-- 创建商品信息表
CREATE TABLE IF NOT EXISTS product_info (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2),
    brand VARCHAR(100),
    shelf_time DATETIME
);

-- 创建用户行为记录表
CREATE TABLE IF NOT EXISTS user_behavior_record (
    user_id INT,
    behavior_type ENUM('浏览', '加购', '购买'),
    product_id INT,
    behavior_time DATETIME,
    PRIMARY KEY (user_id, behavior_type, product_id, behavior_time)
);

-- 创建时间维度表
CREATE TABLE IF NOT EXISTS time_dimension (
    date DATE PRIMARY KEY,
    week VARCHAR(20),
    holiday VARCHAR(100),
    promotion_activity_flag VARCHAR(50)
);
