CREATE OR REPLACE FUNCTION "public"."geoc_is_in_china_bbox"("lon" numeric, "lat" numeric)
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
BEGIN
    
    return lon >= 72.004 and lon <= 137.8347 and lat >= 0.8293 and lat <= 55.8271;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;