CREATE OR REPLACE FUNCTION "public"."geoc_transform_lat"("x" numeric, "y" numeric)
  RETURNS "pg_catalog"."numeric" AS $BODY$
DECLARE
ret   numeric;
BEGIN
    ret := -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret := ret + (20 * sin(6 * x * PI()) + 20 * sin(2 * x * PI())) * 2 / 3;
    ret := ret +(20 * sin(y * PI()) + 40 * sin(y / 3 * PI())) * 2 / 3;
    ret := ret +(160 * sin(y / 12 * PI()) + 320 * sin(y * PI() / 30)) * 2 / 3;
    return ret;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;