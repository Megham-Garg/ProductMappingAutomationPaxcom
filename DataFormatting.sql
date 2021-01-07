-- mapper SP
CREATE OR REPLACE procedure DataFormatting()
LANGUAGE plpgsql    
AS $$
BEGIN
    BEGIN
        ALTER TABLE products
        ADD COLUMN variant CHARACTER VARYING,
        ADD COLUMN weight CHARACTER VARYING,
        ADD COLUMN SI CHARACTER VARYING,
        ADD COLUMN units INTEGER,
        ADD COLUMN grammage DOUBLE PRECISION,
        ADD COLUMN packaging CHARACTER VARYING
        ADD COLUMN size CHARACTER VARYING;
        EXCEPTION
        WHEN duplicate_column THEN RAISE NOTICE 'columns already exists in products';
    END;
    
    -- modify to suit algo
    update products set title = lower(title) WHERE title IS NOT NULL;
    update products set brand = lower(brand) WHERE brand IS NOT NULL;
    update products set subtitle = lower(subtitle) WHERE subtitle IS NOT NULL;

    -- remove special characters
    UPDATE products SET title = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(title, brand, ' '), '[^a-zA-Z \d\.]', ' ', 'g'), '\s+', ' ', 'g')) WHERE title is not null;;
    UPDATE products SET brand = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(brand, '[^a-zA-Z \d]', ' ', 'g'), '\s+', ' ', 'g')) WHERE brand is not null;;
    UPDATE products SET subtitle = TRIM(REGEXP_REPLACE(REGEXP_REPLACE(subtitle, '[^a-zA-Z \d\.]', ' ', 'g'), '\s+', ' ', 'g')) WHERE subtitle is not null;

    -- add packaging type
    update products set packaging = 'bottle' where title ~ '\ybottle\y' and packaging is null;
    update products set packaging = 'pouch' where title ~ '\ypouch\y' and packaging is null;
    update products set packaging = 'carton' where title ~ '\ycarton\y' and packaging is null;
    update products set packaging = 'box' where title ~ '\ybox\y' and packaging is null;
    update products set packaging = 'jar' where title ~ '\yjar\y' and packaging is null;

    -- extract weight from subtitle then title
    UPDATE products SET weight = SUBSTRING(subtitle,
    '(\d+\.?\d*\s*(kg\y|kgs\y|kilo\y|kilos\y|kilogram\y|kilograms\y|kgram\y|kgrams\y|g\y|gm\y|gms\y|grams\y|gram\y|ltr\y|l\y|litre\y|litres\y|ml\y|millilitre\y|millilitres\y|inches\y|inch\y|m\y|meter\y|meters\y|centimeter\y|cm\y|cms\y|centimeters\y|mm\y|millimeter\y|millimeters\y))') where subtitle is not null;
    UPDATE products SET weight = SUBSTRING(title,
    '(\d+\.?\d*\s*(kg\y|kgs\y|kilo\y|kilos\y|kilogram\y|kilograms\y|kgram\y|kgrams\y|g\y|gm\y|gms\y|grams\y|gram\y|ltr\y|l\y|litre\y|litres\y|ml\y|millilitre\y|millilitres\y|inches\y|inch\y|m\y|meter\y|meters\y|centimeter\y|cm\y|cms\y|centimeters\y|mm\y|millimeter\y|millimeters\y))') WHERE weight IS NULL and title is not null;

    -- change all units to standard kg, meter, litres
    UPDATE products SET SI = SUBSTRING(weight, '(kg\y|kgs\y|kilo\y|kilos\y|kilogram\y|kilograms\y|kgram\y|kgrams\y|g\y|gm\y|gms\y|grams\y|gram\y|l\y|ltr\y|litre\y|litres\y|ml\y|millilitre\y|millilitres\y|inches\y|inch\y|m\y|meter\y|meters\y|centimeter\y|cm\y|cms\y|centimeters\y|mm\y|millimeter\y|millimeters\y)') where weight is not null;
    
    -- extract grammage from weight and convert to standard kg, meter, litres
    UPDATE products SET grammage = SUBSTRING(weight, '(\d+\.?\d*)')::DOUBLE PRECISION;
    UPDATE products SET grammage = grammage/1000 where SI ~ '(\yml\y|\ymillilitre\y|\ymillilitres\y)';
    UPDATE products SET grammage = grammage/1000 where SI ~ '(\yg\y|\ygm\y|\ygms\y|\ygrams\y|gram\y)';
    UPDATE products SET grammage = grammage/100 where SI ~ '(\ycentimeter\y|\ycm\y|\ycms\y|\ycentimeters\y)';
    UPDATE products SET grammage = grammage*0.0254 where SI ~ '(\yinches\y|\yinch\y)';
    UPDATE products SET grammage = grammage/1000 where SI ~ '(\ymm\y|\ymillimeter\y|\ymillimeters\y)';

    UPDATE products SET SI = 'litre' where SI ~ '(\yml\y|\ymillilitre\y|\ymillilitres\y|\yltr\y)';
    UPDATE products SET SI = 'kg' where SI ~ '(\yg\y|\ygm\y|\ygms\y|\ygrams\y|gram\y)';
    UPDATE products SET SI = 'meter' where SI ~ '(\ycentimeter\y|\ycm\y|\ycms\y|\ycentimeters\y|\yinches\y|\yinch\y|\ymm\y|\ymillimeter\y|\ymillimeters\y)';
    UPDATE products SET SI = 'litres' where si ~ '^l';
    UPDATE products SET SI = 'kg' where si ~ '^k';
    UPDATE products SET SI = 'meters' where si ~ '^m';
    
    -- remove redundant data
    update products set mrp = null where mrp = 0;
    update products set price = null where price = 0;
    update products set grammage = null where grammage = 0;

    -- extract variant from title
    UPDATE products SET variant = uniq_words(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(title, '[^a-z ]', ' '), '\s+', ' ', 'g')));
    update products set variant = trim (regexp_replace(regexp_replace(variant, '\y[a-z]{1}\y', '', 'g'), '\s+', ' ', 'g'));

    -- extract no of items in that sku
    UPDATE products SET units = SUBSTRING(SUBSTRING(subtitle,'(\d+\s*(unit|x|pc|pack|piece|count|box|carton|page)|(\ypack|\yset)\s*of\D*\d+)'),'\d+')::integer;
    UPDATE products SET units = SUBSTRING(SUBSTRING(title,'(\d+\s*(unit|x|pc|pack|piece|count|box|carton|page)|(\ypack|\yset)\s*of\D*\d+)'),'\d+')::integer WHERE units IS NULL;
    UPDATE products SET units = 1 WHERE units IS NULL;

    -- extract size type
    update products set size =  substring (title, '\yextra small\y|\ysmall\y|\yx large\y|\yextra large\y|\yxtra large\y|\ylarge\y|\ymedium\y|\yxl\y|\yxxl\y|\yxs\y|\ys\y|\yxxxl\y|\y4xl\y|\y3xl\y|\y5xl\y|\yxxxxxl\y|\ym\y|\yl\y');
    update products set size =  'xl' where size ~ '\yx large\y|\yextra large\y|\yxtra large\y';
    update products set size =  'xs' where size = 'extra small';
    update products set size =  's' where size = 'small';
    update products set size =  'l' where size = 'large';
    update products set size =  'm' where size = 'medium';
    update products set size =  'xxxl' where size = '3xl';
    update products set size =  'xxxxl' where size = '4xl';
    update products set size =  'xxxxxl' where size = '5xl';

END;$$