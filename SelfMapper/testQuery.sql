-- extension for similarity
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE EXTENSION IF NOT EXISTS tablefunc;

-- set encoding
-- SET CLIENT_ENCODING TO 'utf8';

SELECT * 
FROM CROSSTAB
(
	$$
	select *, sku, selfMapperProducts(sku, channel, variant, brand, mrp, price, units, grammage, si)
	from products where sku = '14627'
	$$
)AS T (sku character varying, am record, cs record, sc record, sas record)
select * from products where sku = '204629';


select *, 
    selfMapperProducts(sku, channel, variant, brand, mrp, price, units, grammage, si, packaging)
    from products where sku = '43';

insert into products values(
'104864',
'Bigbasket',
'amul butter pasteurised 500 g carton',
'amul',
235,
227,
null,
'butter pasteurised carton',
'kg',
1,
.5,
'500g'
);