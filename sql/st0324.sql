drop table if exists ods_order_info;
create table ods_order_info (
    `id` string COMMENT '订单编号',
    `total_amount` decimal(10,2) COMMENT '订单金额',
    `order_status` string COMMENT '订单状态',
    `user_id` string COMMENT '用户id' ,
    `payment_way` string COMMENT '支付方式',
    `out_trade_no` string COMMENT '支付流水号',
    `create_time` string COMMENT '创建时间',
    `operate_time` string COMMENT '操作时间'
) COMMENT '订单表'
PARTITIONED BY ( `dt` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/warehouse/db_gmall/ods/ods_order_info/'
TBLPROPERTIES (
'hive.exec.compress.output' = 'true',
'mapreduce.output.fileoutputformat.compress' = 'true',
'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
);


drop table if exists ods_order_detail;
create table ods_order_detail(
    `id` string COMMENT '订单编号',
    `order_id` string  COMMENT '订单号',
    `user_id` string COMMENT '用户id' ,
    `sku_id` string COMMENT '商品id',
    `sku_name` string COMMENT '商品名称',
    `order_price` string COMMENT '下单价格',
    `sku_num` string COMMENT '商品数量',
    `create_time` string COMMENT '创建时间'
) COMMENT '订单明细表'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_order_detail/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );



drop table if exists ods_sku_info;
create table ods_sku_info(
    `id` string COMMENT 'skuId',
    `spu_id` string  COMMENT 'spuid',
    `price` decimal(10,2) COMMENT '价格' ,
    `sku_name` string COMMENT '商品名称',
    `sku_desc` string COMMENT '商品描述',
    `weight` string COMMENT '重量',
    `tm_id` string COMMENT '品牌id',
    `category3_id` string COMMENT '品类id',
    `create_time` string COMMENT '创建时间'
) COMMENT '商品表'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_sku_info/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );


drop table if exists ods_user_info;
create table ods_user_info(
    `id` string COMMENT '用户id',
    `name`  string COMMENT '姓名',
    `birthday` string COMMENT '生日' ,
    `gender` string COMMENT '性别',
    `email` string COMMENT '邮箱',
    `user_level` string COMMENT '用户等级',
                              `create_time` string COMMENT '创建时间'
) COMMENT '用户信息'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_user_info/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );


drop table if exists ods_base_category1;
create table ods_base_category1(
    `id` string COMMENT 'id',
    `name`  string COMMENT '名称'
) COMMENT '商品一级分类'
        );


drop table if exists ods_base_category2;
create external table ods_base_category2(
    `id` string COMMENT ' id',
    `name`  string COMMENT '名称',
    category1_id string COMMENT '一级品类id'
) COMMENT '商品二级分类'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_base_category2/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );

drop table if exists ods_base_category3;
create table ods_base_category3(
    `id` string COMMENT ' id',
    `name`  string COMMENT '名称',
    category2_id string COMMENT '二级品类id'
) COMMENT '商品三级分类'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_base_category3/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );

drop table if exists `ods_payment_info`;
create table  `ods_payment_info`(
    `id`  bigint COMMENT '编号',
    `out_trade_no`   string COMMENT '对外业务编号',
    `order_id`  string COMMENT '订单编号',
    `user_id`  string COMMENT '用户编号',
    `alipay_trade_no` string COMMENT '支付宝交易流水编号',
    `total_amount`  decimal(16,2) COMMENT '支付金额',
    `subject`  string COMMENT '交易内容',
    `payment_type` string COMMENT '支付类型',
    `payment_time`  string COMMENT '支付时间'
)  COMMENT '支付流水表'
PARTITIONED BY ( `dt` string)
row format delimited  fields terminated by '\t'
location '/warehouse/db_gmall/ods/ods_payment_info/'
TBLPROPERTIES (
    'hive.exec.compress.output' = 'true',
    'mapreduce.output.fileoutputformat.compress' = 'true',
    'mapreduce.output.fileoutputformat.compress.codec' = 'org.apache.hadoop.io.compress.GzipCodec'
    );

load data inpath '/origin_data/db/order_info/2025-03-11/'  OVERWRITE into table ods_order_info partition(dt='2025-03-11');
load data inpath '/origin_data/db/order_detail/2025-03-11/'  OVERWRITE into table ods_order_detail partition(dt='2025-03-11');
load data inpath '/origin_data/db/sku_info/2025-03-11/'  OVERWRITE into table ods_sku_info partition(dt='2025-03-11');
load data inpath '/origin_data/db/user_info/2025-03-11/' OVERWRITE into table ods_user_info partition(dt='2025-03-11');
load data inpath '/origin_data/db/payment_info/2025-03-11/' OVERWRITE into table ods_payment_info partition(dt='2025-03-11');
load data inpath '/origin_data/db/base_category1/2025-03-11/' OVERWRITE into table ods_base_category1 partition(dt='2025-03-11');
load data inpath '/origin_data/db/base_category2/2025-03-11/' OVERWRITE into table ods_base_category2 partition(dt='2025-03-11');
load data inpath '/origin_data/db/base_category3/2025-03-11/' OVERWRITE into table ods_base_category3 partition(dt='2025-03-11');
