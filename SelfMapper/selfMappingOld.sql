-- map products with A as base channel and B as mapped channel
update products set flipkart_self = mapped.self
	FROM
	(
	SELECT A.sku , B.sku as self FROM products as A inner join products as B
		ON (A.sku != B.sku
		and A.channel ~ '(Grofer)'
		and B.channel ~ '(Flipkart)'
		and (
                case when (LENGTH(A.variant) > LENGTH(B.variant)) then (STRICT_WORD_SIMILARITY(B.variant, A.variant) >= 0.5)
                else (STRICT_WORD_SIMILARITY(A.variant, B.variant) >= 0.5)
                end
			)
			
		and (
                case when (LENGTH(A.brand) > LENGTH(B.brand)) then (STRICT_WORD_SIMILARITY(B.brand, A.brand) > 0.5)
                else (STRICT_WORD_SIMILARITY(A.brand, B.brand) > 0.5)
                end
			)
			and (A.grammage is null or B.grammage is null or abs(A.grammage - B.grammage) <= 0.2*A.grammage )
			and ((A.mrp is null or B.mrp is null or abs(A.mrp - B.mrp) <= 0.82*A.mrp ) or (A.price is null or B.price is null or abs(A.price - B.price) <= 0.88*A.price ))
		)
		order by (A.mrp - B.mrp)
	) as mapped
	WHERE products.sku = mapped.sku and products.channel ~ '(Grofer)';



-- map products with A as base channel and B as mapped channel
update products set amazon_self = mapped.self
	FROM
	(
	SELECT A.sku , B.sku as self FROM products as A inner join products as B
		ON (A.sku != B.sku
		and A.channel ~ '(Grofer)'
		and B.channel ~ '(Amazon)'
		and (
                case when (LENGTH(A.variant) > LENGTH(B.variant)) then (STRICT_WORD_SIMILARITY(B.variant, A.variant) >= 0.5)
                else (STRICT_WORD_SIMILARITY(A.variant, B.variant) >= 0.5)
                end
			)
			
		and (
                case when (LENGTH(A.brand) > LENGTH(B.brand)) then (STRICT_WORD_SIMILARITY(B.brand, A.brand) > 0.5)
                else (STRICT_WORD_SIMILARITY(A.brand, B.brand) > 0.5)
                end
			)
			and (A.grammage is null or B.grammage is null or abs(A.grammage - B.grammage) <= 0.2*A.grammage )
			and ((A.mrp is null or B.mrp is null or abs(A.mrp - B.mrp) <= 0.82*A.mrp ) or (A.price is null or B.price is null or abs(A.price - B.price) <= 0.88*A.price ))
		)
		order by (A.mrp - B.mrp)
	) as mapped
	WHERE products.sku = mapped.sku and products.channel ~ '(Grofer)';

-- map products with A as base channel and B as mapped channel
update products set jiomart_self = mapped.self
	FROM
	(
	SELECT A.sku , B.sku as self FROM products as A inner join products as B
		ON (A.sku != B.sku
		and A.channel ~ '(Grofer)'
		and B.channel ~ '(Jio)'
		and (
                case when (LENGTH(A.variant) > LENGTH(B.variant)) then (STRICT_WORD_SIMILARITY(B.variant, A.variant) >= 0.5)
                else (STRICT_WORD_SIMILARITY(A.variant, B.variant) >= 0.5)
                end
			)
			
		and (
                case when (LENGTH(A.brand) > LENGTH(B.brand)) then (STRICT_WORD_SIMILARITY(B.brand, A.brand) > 0.5)
                else (STRICT_WORD_SIMILARITY(A.brand, B.brand) > 0.5)
                end
			)
			and (A.grammage is null or B.grammage is null or abs(A.grammage - B.grammage) <= 0.2*A.grammage )
			and ((A.mrp is null or B.mrp is null or abs(A.mrp - B.mrp) <= 0.82*A.mrp ) or (A.price is null or B.price is null or abs(A.price - B.price) <= 0.88*A.price ))
		)
		order by (A.mrp - B.mrp)
	) as mapped
	WHERE products.sku = mapped.sku and products.channel ~ '(Grofer)';

-- map products with A as base channel and B as mapped channel
update products set bigbasket_self = mapped.self
	FROM
	(
	SELECT A.sku , B.sku as self FROM products as A inner join products as B
		ON (A.sku != B.sku
		and A.channel ~ '(Grofer)'
		and B.channel ~ '(Bigbasket)'
		and (
                case when (LENGTH(A.variant) > LENGTH(B.variant)) then (STRICT_WORD_SIMILARITY(B.variant, A.variant) >= 0.5)
                else (STRICT_WORD_SIMILARITY(A.variant, B.variant) >= 0.5)
                end
			)
			
		and (
                case when (LENGTH(A.brand) > LENGTH(B.brand)) then (STRICT_WORD_SIMILARITY(B.brand, A.brand) > 0.5)
                else (STRICT_WORD_SIMILARITY(A.brand, B.brand) > 0.5)
                end
			)
			and (A.grammage is null or B.grammage is null or abs(A.grammage - B.grammage) <= 0.2*A.grammage )
			and ((A.mrp is null or B.mrp is null or abs(A.mrp - B.mrp) <= 0.82*A.mrp ) or (A.price is null or B.price is null or abs(A.price - B.price) <= 0.88*A.price ))
		)
		order by (A.mrp - B.mrp)
	) as mapped
	WHERE products.sku = mapped.sku and products.channel ~ '(Grofer)';

-- **************************************************** --
UPDATE products as A SET amazon_title = (
	SELECT B.title FROM products as B
	WHERE A.amazon_self = B.sku
)
where amazon_self is not null;

UPDATE products as A SET amazon_brand = (
	SELECT B.brand FROM products as B
	WHERE A.amazon_self = B.sku
)
where amazon_self is not null;

UPDATE products as A SET amazon_price = (
	SELECT B.price FROM products as B
	WHERE A.amazon_self = B.sku
)
where amazon_self is not null;

UPDATE products as A SET amazon_mrp = (
	SELECT B.mrp FROM products as B
	WHERE A.amazon_self = B.sku
)
where amazon_self is not null;

UPDATE products as A SET flipkart_title = (
	SELECT B.title FROM products as B
	WHERE A.flipkart_self = B.sku
)
where flipkart_self is not null;

UPDATE products as A SET flipkart_brand = (
	SELECT B.brand FROM products as B
	WHERE A.flipkart_self = B.sku
)
where flipkart_self is not null;

UPDATE products as A SET flipkart_price = (
	SELECT B.price FROM products as B
	WHERE A.flipkart_self = B.sku
)
where flipkart_self is not null;

UPDATE products as A SET flipkart_mrp = (
	SELECT B.mrp FROM products as B
	WHERE A.flipkart_self = B.sku
)
where flipkart_self is not null;

UPDATE products as A SET bigbasket_title = (
	SELECT B.title FROM products as B
	WHERE A.bigbasket_self = B.sku
)
where bigbasket_self is not null;

UPDATE products as A SET bigbasket_brand = (
	SELECT B.brand FROM products as B
	WHERE A.bigbasket_self = B.sku
)
where bigbasket_self is not null;

UPDATE products as A SET bigbasket_price = (
	SELECT B.price FROM products as B
	WHERE A.bigbasket_self = B.sku
)
where bigbasket_self is not null;

UPDATE products as A SET bigbasket_mrp = (
	SELECT B.mrp FROM products as B
	WHERE A.bigbasket_self = B.sku
)
where bigbasket_self is not null;

UPDATE products as A SET jiomart_title = (
	SELECT B.title FROM products as B
	WHERE A.jiomart_self = B.sku
)
where jiomart_self is not null;

UPDATE products as A SET jiomart_brand = (
	SELECT B.brand FROM products as B
	WHERE A.jiomart_self = B.sku
)
where jiomart_self is not null;

UPDATE products as A SET jiomart_price = (
	SELECT B.price FROM products as B
	WHERE A.jiomart_self = B.sku
)
where jiomart_self is not null;

UPDATE products as A SET jiomart_mrp = (
	SELECT B.mrp FROM products as B
	WHERE A.jiomart_self = B.sku
)
where jiomart_self is not null;

select * from products where channel ~ '(Grofer)';