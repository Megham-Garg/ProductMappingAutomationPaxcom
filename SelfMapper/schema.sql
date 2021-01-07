-- schema
-- schema
CREATE TABLE public.products(
    sku CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
    channel CHARACTER VARYING COLLATE pg_catalog."default",
    title CHARACTER VARYING COLLATE pg_catalog."default",
    brand CHARACTER VARYING COLLATE pg_catalog."default",
    mrp double precision,
    price double precision,
    subtitle CHARACTER VARYING COLLATE pg_catalog."default",
	CONSTRAINT products_pkey PRIMARY KEY (sku)
);