CREATE OR REPLACE FUNCTION "public"."geoc_transform_lon"("x" numeric, "y" numeric)
  RETURNS "pg_catalog"."numeric" AS $BODY$
DECLARE
    ret   numeric;
BEGIN
    ret := 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    ret :=ret + (20 * sin(6 * x * pi()) + 20 * sin(2 * x * pi())) * 2 / 3;
    ret :=ret + (20 * sin(x * pi()) + 40 * sin(x / 3 * pi())) * 2 / 3;
    ret :=ret + (150 * sin(x / 12 * pi()) + 300 * sin(x / 30 * pi())) * 2 / 3;
    return ret;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;