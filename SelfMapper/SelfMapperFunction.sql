CREATE OR REPLACE FUNCTION selfmapperproducts(
	base_sku character varying,
	base_channel character varying,
	base_variant character varying,
	base_brand character varying,
	base_mrp double precision,
	base_price double precision,
	base_units integer,
	base_grammage double precision,
	base_si character varying,
    base_packaging character varying,
	logic_choice integer DEFAULT 1,
	title_match double precision DEFAULT 50,
	brand_match double precision DEFAULT 65,
	mrp_match double precision DEFAULT 75,
	price_match double precision DEFAULT 75,
	overall_criteria double precision DEFAULT 75)
    RETURNS TABLE(mappedchannel character varying, mappedsku character varying, mappedtitle character varying, mappedbrand character varying, mappedmrp double precision, mappedprice double precision, mappedsubtitle character varying, mappedgrammage double precision, mappedsi character varying, mappedunits integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$
BEGIN
    RETURN QUERY SELECT
        DISTINCT ON (channel) channel,sku,title,brand,mrp,price,subtitle, grammage, si, units
    FROM
        products
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
                        )*0.35+
                        (
                            CASE
                                WHEN (brand is null or base_brand is null) then 1
                                WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                                ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
                            END
                        )*0.25+
                        (
                            CASE 
                                WHEN (mrp is null or base_mrp is null) then 1
                                WHEN (abs(mrp - base_mrp) < base_mrp) then (abs(mrp - base_mrp)/base_mrp)
                                ELSE 0
                            END
                        )*0.2+
                        (
                            CASE 
                                WHEN (price is null or base_price is null) then 1
                                WHEN (abs(price - base_price) < base_price) then (abs(price - base_price)/base_price)
                                ELSE 0
                            END
                        )*0.2
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
                        WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 >= brand_match
                        ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 >= brand_match
                        END
                    )AND(
                        CASE 
                            WHEN (price is not null and base_price is not null and (price = base_price)) then true
                            ELSE mrp IS NULL OR base_mrp IS NULL OR (abs(mrp - base_mrp)/base_mrp)*100 <= mrp_match
                        END
                    )AND(
                        CASE 
                            WHEN (mrp is not null and base_mrp is not null and (mrp = base_mrp)) then true
                            ELSE price IS NULL OR base_price IS NULL OR (abs(price - base_price)/base_price)*100 <= price_match
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
                        )*0.35+
                        (
                            CASE
                                WHEN (brand is null or base_brand is null) then 1
                                WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                                ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
                            END
                        )*0.25+
                        (
                            CASE 
                                WHEN (mrp is null or base_mrp is null) then 1
                                WHEN (abs(mrp - base_mrp) < base_mrp) then (abs(mrp - base_mrp)/base_mrp)
                                ELSE 0
                            END
                        )*0.2+
                        (
                            CASE 
                                WHEN (price is null or base_price is null) then 1
                                WHEN (abs(price - base_price) < base_price) then (abs(price - base_price)/base_price)
                                ELSE 0
                            END
                        )*0.2
                    )*100
                ) >= overall_criteria
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
                        WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 >= brand_match
                        ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 >= brand_match
                        END
                    )AND(
                        CASE 
                            WHEN (price is not null and base_price is not null and (price = base_price)) then true
                            ELSE mrp IS NULL OR base_mrp IS NULL OR (abs(mrp - base_mrp)/base_mrp)*100 <= mrp_match
                        END
                    )AND(
                        CASE 
                            WHEN (mrp is not null and base_mrp is not null and (mrp = base_mrp)) then true
                            ELSE price IS NULL OR base_price IS NULL OR (abs(price - base_price)/base_price)*100 <= price_match
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
                        WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)*100 >= brand_match
                        ELSE STRICT_WORD_SIMILARITY(base_brand, brand)*100 >= brand_match
                        END
                    )AND(
                        CASE 
                            WHEN (price is not null and base_price is not null and (price = base_price)) then true
                            ELSE mrp IS NULL OR base_mrp IS NULL OR (abs(mrp - base_mrp)/base_mrp)*100 <= mrp_match
                        END
                    )AND(
                        CASE 
                            WHEN (mrp is not null and base_mrp is not null and (mrp = base_mrp)) then true
                            ELSE price IS NULL OR base_price IS NULL OR (abs(price - base_price)/base_price)*100 <= price_match
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
                    )*0.35+
                    (
                        CASE
                            WHEN (brand is null or base_brand is null) then 1
                            WHEN (LENGTH(base_brand) >= LENGTH(brand)) THEN STRICT_WORD_SIMILARITY(brand, base_brand)
                            ELSE STRICT_WORD_SIMILARITY(base_brand, brand)
                        END
                    )*0.25+
                    (
                        CASE 
                            WHEN (mrp is null or base_mrp is null) then 1
                            WHEN (abs(mrp - base_mrp) < base_mrp) then (abs(mrp - base_mrp)/base_mrp)
                            ELSE 0
                        END
                    )*0.2+
                    (
                        CASE 
                            WHEN (price is null or base_price is null) then 1
                            WHEN (abs(price - base_price) < base_price) then (abs(price - base_price)/base_price)
                            ELSE 0
                        END
                    )*0.2
                )*100
            ) >= overall_criteria
        END AND(
            channel != base_channel
        )AND(
            (units IS NULL AND base_units IS NULL) OR base_units = units
        )AND(
            base_packaging IS NULL OR packaging IS NULL OR (packaging = base_packaging)
        )AND(
            grammage IS NULL OR base_grammage IS NULL OR (grammage = base_grammage and SI = base_SI)
        )ORDER BY channel, ABS(mrp - base_mrp)/2 ASC, uniq_common_words(base_variant, variant) DESC;	
END;
$BODY$;