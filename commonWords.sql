CREATE OR REPLACE FUNCTION public.uniq_common_words(
	a character varying,
	b character varying)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
    commonWords double precision:= 0;
    totalUniqueWords double precision:= 1;
BEGIN
    commonWords = (SELECT count(distinct x) FROM unnest(string_to_array(a,' ')) x,  unnest(string_to_array(b,' ')) y where x = y);
	totalUniqueWords = ( SELECT count(distinct x) FROM unnest(string_to_array(a,' ')) x);
	if(totalUniqueWords = 0) then return 0;
    else RETURN (commonWords/totalUniqueWords)*100;
	end if;
END
$BODY$;