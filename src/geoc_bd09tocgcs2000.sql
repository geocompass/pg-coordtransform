CREATE OR REPLACE FUNCTION "public"."geoc_bd09tocgcs2000"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return st_transform(st_setsrid(geoc_bd09towgs84(geom),4326),4490);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;