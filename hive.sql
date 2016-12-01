# hive shell
hive

# exit hive shell
hive> exit;

# hive command line
hive -e "SELECT * from table_name" > output_file

# common commands

SHOW DATABASES;
USE data_base_name;                   # use app;
SHOW TABLES;
DESC table_name;                      # desc dp_kvi_score;
SHOW PARTITIONS table_name;           # show partitions dp_kvi_score;
DROP TABLSE table_name;
LOAD DATA [LOCAL] INPATH file_path [OVERWRITE] INTO TABLE table_name [PARTITION value];


# create table

CREATE [EXTERNAL] TABLE table_name(
    col_name_1 INT,            # TINYINT, SMALLINT, BIGINT
    col_name_2 STRING,         # CHAR, VARCHAR
    col_name_3 DOUBLE,         # FLOAT, DECIMAL
    
    col_name_4 BOOLEAN,        # BINARY
    col_name_5 DATE            # TIMESTAMP
    ...
)
[PARTITIONED BY (col_name date_type)]
[ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t']
[STORED AS TEXTFILE]
[COMMENT your_comment];


####################
### query tips
####################

### 1. partition prune

SELECT
    item_sku_id
FROM
    gdm.gdm_m03_self_item_sku_da
WHERE
    dt='2016-10-13' AND item_third_cate_cd = 2676;


### 2. small table first

SELECT b.* 
FROM
    (SELECT item_sku_id
     FROM gdm.gdm_m03_self_item_sku_da
     WHERE
         dt='2016-10-13' AND item_third_cate_cd = 2676
     ) AS a
JOIN
    app.app_cis_jd_opp_price_history_da AS b
ON (a.item_sku_id = b.jdsku);

### 3. pruned before join

SELECT a.skuid, b.jdprice, b.oppname, b.oppprice 
FROM
    (SELECT item_third_cate_cd, brand_code, item_sku_id AS skuid
     FROM
         gdm.gdm_m03_self_item_sku_da 
     WHERE
         dt = sysdate(-1) AND sku_status_cd = 3001
    ) AS a
LEFT JOIN
    (SELECT jdsku, jdprice, oppname, oppprice
     FROM
         app.app_cis_jd_opp_price_history_da 
     WHERE
         dt = '2016-11-20'
    ) AS b
ON a.skuid = b.jdsku;

### 4. look cluster status
# http://bdp.jd.com/ide/yarn/job_list.html?_dc=1480579104221&m=51
