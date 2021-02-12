-- remove duplicate words from TEXT
CREATE OR REPLACE FUNCTION uniq_words(
	text)
    RETURNS text
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
SELECT array_to_string(ARRAY(SELECT DISTINCT trim(x) FROM unnest(string_to_array($1,' ')) x),' ')
$BODY$;