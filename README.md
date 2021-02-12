# ProductMappingAutomationPaxcom

* schema for products table
```
CREATE TABLE products
(
    id integer NOT NULL,
    sku character varying COLLATE pg_catalog."default" NOT NULL,
    channel character varying COLLATE pg_catalog."default",
    title character varying COLLATE pg_catalog."default",
    brand character varying COLLATE pg_catalog."default",
    category character varying COLLATE pg_catalog."default",
    mrp double precision,
    price double precision,
    subtitle character varying COLLATE pg_catalog."default",
    variant character varying COLLATE pg_catalog."default",
    si character varying COLLATE pg_catalog."default",
    units integer,
    grammage double precision,
    weight character varying COLLATE pg_catalog."default",
    packaging character varying COLLATE pg_catalog."default"
)
```

## Data Formatting steps:
* convert title, brand, subtitle to lower case
* remove all characters from title, brand, subtitle except alhanumerics, and dot
* extract packaging type for the product
* extract packaging type if any from products
* extract weight from subtitle and if not present then from title
* extract si unit and then convert grammage to stadard litre, kg, and meters
* convert si to standard
* remove brand from title
* extract variant by removing all digits, duplicate words and single letters from title
* extract units from title
* extract size as in small, medium etc. if any from title

### pass all the details to self mapper function and comp mapper function along with passing criteria

## default values are as follows:

* for self
```
logic_choice integer DEFAULT 1
title_match double precision DEFAULT 50
brand_match double precision DEFAULT 65
mrp_match double precision DEFAULT 75
price_match double precision DEFAULT 75
overall_criteria double precision DEFAULT 75
```
* for competition
```
title_match DOUBLE PRECISION DEFAULT 50
brand_match DOUBLE PRECISION DEFAULT 45
grammage_match DOUBLE PRECISION DEFAULT 30
overall_criteria DOUBLE PRECISION DEFAULT 75
```

### A doesn't need overall_criteria and B uses overall_criteria
* 0 B
* 1 A
* 2 A or B
* 3 A AND B
