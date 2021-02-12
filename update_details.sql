CREATE OR REPLACE FUNCTION app.update_product_mapper_detail(
	table_name CHARACTER VARYING,
	column_to_update CHARACTER VARYING,
	to_val CHARACTER VARYING,
  using_table CHARACTER VARYING,
	using_column CHARACTER VARYING,
	using_pattern CHARACTER VARYING)
  RETURNS VOID
  LANGUAGE plpgsql AS
$body$
BEGIN
	EXECUTE FORMAT('UPDATE %I SET %s = %s FROM %I WHERE %s ~ %L', table_name, column_to_update, to_val, using_table, using_column, using_pattern);
END
$body$;

CREATE TABLE app.update_product_mapper_info{
    id SERIAL,
    column_to_update CHARACTER VARYING,
    using_column CHARACTER VARYING,
    to_val CHARACTER VARYING,
    using_pattern CHARACTER VARYING
};