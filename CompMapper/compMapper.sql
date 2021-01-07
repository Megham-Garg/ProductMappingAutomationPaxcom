-- mapper function
CREATE OR REPLACE FUNCTION compMapperProducts(
	base_sku CHARACTER VARYING,
	base_channel CHARACTER VARYING,
    base_variant CHARACTER VARYING,
    base_brand CHARACTER VARYING,
    base_mrp DOUBLE PRECISION,
    base_price DOUBLE PRECISION,
    base_units INTEGER,
    base_grammage DOUBLE PRECISION,
    base_SI CHARACTER VARYING,
    base_size CHARACTER VARYING,
    logic_choice INTEGER DEFAULT 1,
    -- A doesn't need overall_criteria and B uses overall_criteria
    -- 0 B
    -- 1 A
    -- 2 A or B
    -- 3 A AND B
    title_match DOUBLE PRECISION DEFAULT 50,
    brand_match DOUBLE PRECISION DEFAULT 45,
    grammage_match DOUBLE PRECISION DEFAULT 30,
    overall_criteria DOUBLE PRECISION DEFAULT 75
    )
    RETURNS TEXT[]
    LANGUAGE 'plpgsql'
    COST 100 VOLATILE PARALLEL UNSAFE
AS $BODY$    
BEGIN
    RETURN ARRAY
    (
        SELECT concat(channel, ' : ', sku, ' : ' , title, ' : ' , brand, ' : ', mrp, ' : ', price, ' : ', weight, ' : ', units, ' : ', size) FROM compproducts
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
                                    WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                                    ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
                                END
                            )*0.4
                        )*100
                    ) <= overall_criteria
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
                                    WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                                    ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
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
                                WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                                ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
                            END
                        )*0.4
                    )*100
                ) <= overall_criteria
            END AND(
                (units IS NULL AND base_units IS NULL) OR base_units = units
            )AND(
                size IS NULL OR base_size IS NULL OR base_size = size
            )AND(
                grammage IS NULL OR base_grammage IS NULL OR ((abs(grammage - base_grammage)/base_grammage)*100 <= grammage_match and SI = base_SI)
            )ORDER BY channel
    );
END;
$BODY$;