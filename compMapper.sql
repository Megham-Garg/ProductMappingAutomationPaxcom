CREATE OR REPLACE FUNCTION app.get_comp_mapper_data(
	base_sku CHARACTER VARYING,
	base_channel CHARACTER VARYING,
    base_variant CHARACTER VARYING,
    base_brand CHARACTER VARYING,
    base_mrp DOUBLE PRECISION,
    base_price DOUBLE PRECISION,
    base_grammage DOUBLE PRECISION,
    base_SI CHARACTER VARYING,
    base_size CHARACTER VARYING,
    base_packaging character varying,
    base_id integer,
    base_power character varying,
    base_memory character varying,
    base_color character varying,
    logic_choice INTEGER DEFAULT 1,
    title_match DOUBLE PRECISION DEFAULT 40,
    brand_match DOUBLE PRECISION DEFAULT 45,
    grammage_match DOUBLE PRECISION DEFAULT 30,
    overall_criteria DOUBLE PRECISION DEFAULT 75
    )
    RETURNS  SETOF json
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE new_id INTEGER:=base_id;
BEGIN
    IF EXISTS(SELECT 1 FROM MASTER_SKU_INFO WHERE channel_sku = base_sku AND channel_id = base_channel)
    THEN 
        new_id := (SELECT mapped_id FROM MASTER_SKU_INFO WHERE channel_sku = base_sku AND channel_id = base_channel);
    END IF;
    
    DROP TABLE IF EXISTS MAPPED_RESULT;
    CREATE TEMP TABLE MAPPED_RESULT  AS
    (
        SELECT channel_id, channel_sku, new_id as mapped_id, brand_id, category_id, mrp, price, title, product_url, image_url
        FROM TEMP_RAW_DATA
        WHERE
            CASE
                WHEN (logic_choice = 3) THEN 
                (
                    (
                        (
                            (
                                CASE
                                    WHEN (variant is null or base_variant is null) then 1
                                    WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)
                                    ELSE STRICT_WORD_SIMILARITY(base_variant, variant)
                                END
                            )*0.6+
                            (
                                CASE
                                    WHEN (brand is null or base_brand is null) then 1
                                    WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN 1 - STRICT_WORD_SIMILARITY(brand, base_brand)
                                    ELSE 1 - STRICT_WORD_SIMILARITY(base_brand, brand)
                                END
                            )*0.4
                        )*100
                    ) >= overall_criteria
                    AND
                    (
                        (
                            variant IS NULL OR base_variant IS NULL OR 
                            CASE
                            WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)*100 >= title_match
                            ELSE STRICT_WORD_SIMILARITY(base_variant, variant)*100 >= title_match
                            END
                        )AND(
                            brand IS NULL OR base_brand IS NULL OR
                            CASE
                            WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 <= brand_match
                            ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 <= brand_match
                            END
                        )
                    )
                )
                WHEN (logic_choice = 2) THEN 
                (
                    (
                        (
                            (
                                CASE
                                    WHEN (variant is null or base_variant is null) then 1
                                    WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)
                                    ELSE STRICT_WORD_SIMILARITY(base_variant, variant)
                                END
                            )*0.6+
                            (
                                CASE
                                    WHEN (brand is null or base_brand is null) then 1
                                    WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN 1-STRICT_WORD_SIMILARITY(brand, base_brand)
                                    ELSE 1-STRICT_WORD_SIMILARITY(base_brand, brand)
                                END
                            )*0.4
                        )*100
                    ) <= overall_criteria
                    OR
                    (
                        (
                            variant IS NULL OR base_variant IS NULL OR 
                            CASE
                            WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)*100 >= title_match
                            ELSE STRICT_WORD_SIMILARITY(base_variant, variant)*100 >= title_match
                            END
                        )AND(
                            brand IS NULL OR base_brand IS NULL OR
                            CASE
                            WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 <= brand_match
                            ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 <= brand_match
                            END
                        )
                    )
                )
                WHEN (logic_choice = 1) THEN 
                (
                    (
                        (
                            variant IS NULL OR base_variant IS NULL OR 
                            CASE
                            WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)*100 >= title_match
                            ELSE STRICT_WORD_SIMILARITY(base_variant, variant)*100 >= title_match
                            END
                        )AND(
                            brand IS NULL OR base_brand IS NULL OR
                            CASE
                            WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 <= brand_match
                            ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 <= brand_match
                            END
                        )
                    )
                )
                ELSE  
                (
                    (
                        (
                            CASE
                                WHEN (variant is null or base_variant is null) then 1
                                WHEN (LENGTH(base_variant) >= LENGTH(variant)) THEN STRICT_WORD_SIMILARITY(variant, base_variant)
                                ELSE STRICT_WORD_SIMILARITY(base_variant, variant)
                            END
                        )*0.6+
                        (
                            CASE
                                WHEN (brand is null or base_brand is null) then 1
                                WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN 1-STRICT_WORD_SIMILARITY(brand, base_brand)
                                ELSE 1-STRICT_WORD_SIMILARITY(base_brand, brand)
                            END
                        )*0.4
                    )*100
                ) >= overall_criteria
            END
            AND(
                product_size IS NULL OR base_size IS NULL OR base_size = product_size
            )AND(
                grammage IS NULL OR base_grammage IS NULL OR ((abs(grammage - base_grammage)/base_grammage)*100 <= grammage_match and SI = base_SI)
            )AND(
                base_packaging IS NULL OR packaging IS NULL OR (packaging = base_packaging)
            )AND(
                (power IS NULL AND base_power IS NULL) OR base_power = power
            )AND(
                (base_memory IS NULL AND memory IS NULL) OR base_memory = memory
            )AND(
                base_color IS NULL OR color IS NULL OR base_color = color
            )ORDER BY channel
    );
  
    -- insert base sku in maaped result
    INSERT INTO MAPPED_RESULT(channel_id, channel_sku, mapped_id,brand_id,category_id,mrp,price,title,product_url,image_url)
    SELECT base_channel, base_sku, new_id,base_brand_id,base_category_id,base_mrp,base_price,base_title,base_product_url,base_image_url;
   
    INSERT INTO MASTER_SKU_INFO(channel_sku,channel_id, mapped_id, brand_id,category_id,mrp,selling_price,title,product_url,image_url)
    SELECT  MR.channel_sku,MR.channel_id, MR.mapped_id , MR.brand_id,MR.category_id,MR.mrp,MR.price,MR.title,MR.product_url,MR.image_url
    FROM MAPPED_RESULT AS MR
    LEFT JOIN MASTER_SKU_INFO AS MSI
        ON MSI.channel_id = MR.channel_id
        AND MSI.channel_sku = MR.channel_sku
    WHERE MSI.* IS NULL;
    
    RETURN QUERY 
    SELECT row_to_json(t) FROM (select * from mapped_result)t;
END;
$BODY$;