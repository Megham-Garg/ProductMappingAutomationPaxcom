CREATE OR REPLACE FUNCTION public.compare_promo_offer(
    live text,
    planned text,
    price double precision,
    mrp double precision
)
RETURNS text
LANGUAGE 'plpgsql'
as $BODY$
    DECLARE
        string1      TEXT := live;
        string2      TEXT := planned;
        pattern1     TEXT := '\d+\.?\d*%';
        pattern2     TEXT := 'Rs\.?\s*\d+\.?\d*|₹\s*\d+\.?\d*';
        Result       TEXT := '';
        lpv double precision :=-1;  --live_promo_value
        ppv double precision :=-1;  --planned_promo_value
        lpp double precision :=-1;  --live_promo_percent
        ppp double precision :=-1;  --planned_promo_percent

    BEGIN
        if (((string1 !~ pattern1) and (string1 !~ pattern2))
                 or ((string2 !~ pattern1) and (string2 !~ pattern2) and (not isnumeric(string2)))
                 or string1 is null or string2 is null) then
            RETURN 'Missing';
        else
            if (string1 ~ pattern2) then
                lpv = ROUND(regexp_replace(SUBSTRING(string1, pattern2), 'Rs\.?\s*|₹\s*', ''):: double precision);
            elsif (string1 ~ pattern1) then
                lpp = ROUND*(((regexp_replace(SUBSTRING(string1, pattern1), '%', ''):: double precision )* mrp)/100);
            elsif isnumeric(string1) then
                lpp = ROUND(((string1:: double precision )* mrp)/100);
            end if;

            if (string2 ~ pattern2) then
                ppv = ROUND(regexp_replace(SUBSTRING(string2, pattern2), 'Rs\.?\s*|₹\s*', ''):: double precision);
            elsif (string2 ~ pattern1) then
                ppp = ROUND(((regexp_replace(SUBSTRING(string2, pattern1), '%', ''):: double precision )* mrp)/100);
            elsif isnumeric(string2) then
                ppp = ROUND(((string2:: double precision )* mrp)/100);
            end if;

            -- RAISE  NOTICE 'live discount    = %',lpv;
            -- RAISE  NOTICE 'offered discount = %',ppv;

            if lpv = ppv then
                Result = 'Match';
            else
                Result = 'Not Match';
            end if;
            
        end if;
        RETURN Result;
        END;
$BODY$;

-- CREATE OR REPLACE FUNCTION isnumeric(text) RETURNS BOOLEAN AS $$
-- DECLARE x NUMERIC;
-- BEGIN
--     x = $1::NUMERIC;
--     RETURN TRUE;
-- EXCEPTION WHEN others THEN
--     RETURN FALSE;
-- END;
-- $$
-- STRICT
-- LANGUAGE plpgsql IMMUTABLE;