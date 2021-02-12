CREATE OR REPLACE FUNCTION app.data_cleaning_for_product_mapping(
	transaction_id_arg integer)
    RETURNS SETOF json 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
BEGIN
	DROP TABLE IF EXISTS TEMP_RAW_DATA;
	CREATE TEMP TABLE TEMP_RAW_DATA  AS (
		SELECT  CP.id , CP.channel_sku  ,
			LOWER(CP.product_ext_json->>'productName') AS title,
			CP.channel_id , 
			CP.brand_id , 
			LOWER(B.name) AS brand_name , 
			CP.category_id,
			LOWER(CAT.name) AS category_name, 
			CP.mrp ,
			CP.selling_price as price, 
			null::CHARACTER VARYING AS packaging,
			null::CHARACTER VARYING AS variant ,
			null::CHARACTER VARYING As weight , 
			null::CHARACTER VARYING AS si , 
			null::INTEGER AS units , 
			null::DOUBLE PRECISION AS grammage ,
			null::CHARACTER VARYING AS power,
			null::CHARACTER VARYING AS memory,
			null::CHARACTER VARYING AS product_size,
			LOWER(CP.product_ext_json->>'productSubtitle') AS subtitle,
			CP.product_ext_json->>'productUrl' AS product_url,
			CP.product_ext_json->>'productImage' AS image_url
			FROM crawled_data.crawled_product_for_sku_mapping AS CP
			LEFT JOIN app.brands AS B
				ON B.id = CP.brand_id
			LEFT JOIN app.categories AS CAT
				ON CAT.id = CP.category_id
			WHERE 
			CP.group_auto_sku_transaction_mapping_id = transaction_id_arg 
			AND CP.crawl_date = current_date
			AND CP.is_active = TRUE 
			AND CP.stock_status IN (0,1)
	);
    
    UPDATE TEMP_RAW_DATA  SET title = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(title, brand_name, ' '), PNR.regex, ' ', 'g'), '\s+', ' ', 'g'))  
	FROM product_name_regex AS PNR where TEMP_RAW_DATA.title is not null and PNR.id = 1;
    
    UPDATE TEMP_RAW_DATA SET brand_name = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(brand_name, PNR.regex, ' ', 'g'), '\s+', ' ', 'g')) 
	FROM product_name_regex AS PNR
	WHERE TEMP_RAW_DATA.brand_name is not null and PNR.id = 1;
    
    UPDATE TEMP_RAW_DATA SET subtitle = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(subtitle, PNR.regex, ' ', 'g'), '\s+', ' ', 'g')) 
	FROM app.product_name_regex AS PNR
	WHERE TEMP_RAW_DATA.subtitle is not null and PNR.id = 1;
    
    UPDATE TEMP_RAW_DATA SET category_name = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(category_name, brand_name, ' '), PNR.regex, ' ', 'g'), '\s+', ' ', 'g')) 
	FROM app.product_name_regex AS PNR
	WHERE TEMP_RAW_DATA.category_name is not null and PNR.id = 1;
    
    -- extract weight from subtitle then title
    UPDATE TEMP_RAW_DATA SET weight = SUBSTRING(subtitle, PNR.regex) 
	FROM app.product_name_regex AS PNR
	where TEMP_RAW_DATA.subtitle is not null and PNR.id = 2;
    
    UPDATE TEMP_RAW_DATA SET weight = SUBSTRING(title, PNR.regex) 
	FROM app.product_name_regex AS PNR
	WHERE  TEMP_RAW_DATA.weight IS NULL and TEMP_RAW_DATA.title is not null and PNR.id = 2;
    
    -- change all units to standard kg, meter, litres
    UPDATE TEMP_RAW_DATA SET SI = SUBSTRING(weight, PNR.regex) 
	FROM app.product_name_regex AS PNR
	where TEMP_RAW_DATA.weight is not null and PNR.id = 3;
    
    -- extract grammage from weight and convert to standard kg, meter, litres
    UPDATE TEMP_RAW_DATA SET grammage = SUBSTRING(weight, PNR.regex)::DOUBLE PRECISION 
	FROM app.product_name_regex AS PNR
	where TEMP_RAW_DATA.weight is not null and PNR.id = 4;
    
    UPDATE TEMP_RAW_DATA SET grammage = grammage/PGC.conversion_val 
	FROM app.product_grammage_conversion AS PGC
	where SI ~ PGC.regex AND grammage is not null;
    
    -- remove redundant data
    update TEMP_RAW_DATA set mrp = null where mrp = 0;
    
    update TEMP_RAW_DATA set price = null where price = 0;
    
    update TEMP_RAW_DATA set grammage = null where grammage = 0;

    -- extract variant from title    
    -- remove duplicate words, single letter words, non-alphabetical characters
	UPDATE TEMP_RAW_DATA SET variant = uniq_words(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(title, '[^a-z ]', ' ', 'g'), '\s+', ' ', 'g')));
    
    update TEMP_RAW_DATA set variant = trim (regexp_replace(regexp_replace(variant, '\y[a-z]{1}\y', '', 'g'), '\s+', ' ', 'g'));
    
    -- extract no of items in that sku
    UPDATE TEMP_RAW_DATA SET units = SUBSTRING(SUBSTRING(subtitle, PNR.regex),'\d+')::integer 
	FROM app.product_name_regex AS PNR 
	WHERE subtitle ~ PNR.regex and PNR.id = 5;
    
    UPDATE TEMP_RAW_DATA SET units = SUBSTRING(SUBSTRING(title, PNR.regex),'\d+')::integer 
    FROM app.product_name_regex  AS PNR
	WHERE title ~ PNR.regex and PNR.id = 5 and units IS NULL;
    
    UPDATE TEMP_RAW_DATA SET units = 1 WHERE units IS NULL;
    
    -- extract size type
    update TEMP_RAW_DATA set product_size =  substring (subtitle, PNR.regex) 
	FROM app.product_name_regex  AS PNR
	WHERE PNR.id = 6 and subtitle ~ PNR.regex;
    
    update TEMP_RAW_DATA set product_size =  substring (title, PNR.regex) 
	FROM app.product_name_regex AS PNR 
	WHERE PNR.id = 6 and title ~ PNR.regex and product_size is null;
	
    select update_product_mapper_detail('TEMP_RAW_DATA', column_to_update, to_val, using_column, using_pattern) FROM app.update_product_mapper_info;

    UPDATE TEMP_RAW_DATA SET power = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(title, PNR.regex, ' ', 'g'), '\s+', ' ', 'g')) 
    FROM product_name_regex AS PNR WHERE PNR.id = 7;

    UPDATE TEMP_RAW_DATA SET memory = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(title, PNR.regex, ' ', 'g'), '\s+', ' ', 'g')) 
    FROM product_name_regex AS PNR WHERE PNR.id = 8;

    -- 	CREATE TEMP TABLE --
	DROP TABLE IF EXISTS MASTER_SKU_INFO;
	CREATE TEMP TABLE MASTER_SKU_INFO (
		channel_sku character varying, 
		channel_id integer,
		mapped_id integer,
		brand_id integer,
		category_id integer,
		mrp DOUBLE PRECISION,
		selling_price DOUBLE PRECISION,
		title character varying, 
		product_url character varying, 
		image_url character varying, 
		CONSTRAINT MASTER_SKU_INFO_UKEY UNIQUE (channel_sku, channel_id)
	);
	
    DROP TABLE IF EXISTS CTE_group_products;
	CREATE TEMP TABLE CTE_group_products  AS (
        select channel_sku , channel_id,brand_id , category_id, mrp, price, title,product_url,image_url ,
			   t1.data->>'mapped_id' AS mapped_id 
        FROM (
                select channel_sku , channel_id,brand_id , category_id, mrp, price, title,product_url,image_url ,
                    app.get_self_mapper_data(
                        channel_sku,
                        channel_id,
                        variant,
						brand_id,
                        brand_name,
						category_id,
                        mrp,
                        price,
                        units,
                        grammage,
                        si,
                        product_size,
                        packaging,
                        id,
						title,
						product_url,
						image_url,
                        power,
                        memory
                    ) AS data
                    FROM TEMP_RAW_DATA 
            )t1
	);

 	INSERT INTO app.auto_sku_mapping_computed_data(group_auto_sku_transaction_mapping_id, channel_sku , channel_id , brand_id , category_id , mrp , selling_price, product_mapping_id,
 												   title , product_url,image_url,is_checked, crawl_date , is_active, creation_time , updation_time)
	SELECT transaction_id_arg, channel_sku  ,channel_id ,brand_id , category_id ,mrp ,selling_price ,mapped_id ,
								title  ,product_url, image_url , FALSE, CURRENT_DATE, TRUE, now(), now() 
	FROM MASTER_SKU_INFO;
	
    RETURN QUERY
	
    SELECT NULL::JSON;
END;
$BODY$;
