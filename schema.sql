CREATE TABLE temp_products
(
    id SERIAL,
    channel_sku CHARACTER VARYING NOT NULL,
    title CHARACTER VARYING,
    channel CHARACTER VARYING,
    brand CHARACTER VARYING,
    category CHARACTER VARYING,
    mrp DOUBLE PRECISION,
    price DOUBLE PRECISION,
    subtitle CHARACTER VARYING,
    variant CHARACTER VARYING,
    weight CHARACTER VARYING,
    SI CHARACTER VARYING,
    units INTEGER,
    grammage DOUBLE PRECISION,
    packaging CHARACTER VARYING,
    product_size CHARACTER VARYING
);

CREATE TABLE tpm_temp
(
    sku CHARACTER VARYING,
    mapped_id INTEGER,
    CONSTRAINT unique_tpm_temp_sku UNIQUE (sku)
);

CREATE TABLE product_name_regex
(
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING,
    regex CHARACTER VARYING
);

CREATE TABLE update_details(
    id SERIAL,
    update_column CHARACTER VARYING,
    using_column CHARACTER VARYING,
    to_val CHARACTER VARYING,
    using_pattern CHARACTER VARYING
);
